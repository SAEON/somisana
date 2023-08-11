#!/usr/bin/env python
"""
some functions for processing raw opendrift output, including:
    gridding particles to a regular grid 
        (and getting surface thickness, stranded mass/m2, subsurface concentrations)
    getting the oil mass budget
    processessing a set og stochastic opendrift simulations

Some of this stuff is specific to OpenOil runs, so we may need to move to separate files
if we want to run other OpenDrift modules e.g leeway

"""

import sys, os, glob
import numpy as np
from datetime import datetime, timedelta
import xarray as xr
import opendrift
from copy import copy
import xarray as xr
from xhistogram.xarray import histogram
import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import pandas as pd
from bottleneck import push

def get_lonlat_bins(extents, dx_m):
    # code copied from opendrift/models/basemodel.py    
    lonmin = extents[0]
    lonmax = extents[1]
    latmin = extents[2]
    latmax = extents[3]
    deltalat = dx_m / 111000.0  # m to degrees
    deltalon = deltalat / np.cos(np.radians((latmin + latmax) / 2))
    latbin = np.arange(latmin - deltalat, latmax + deltalat, deltalat)
    lonbin = np.arange(lonmin - deltalon, lonmax + deltalon, deltalon)
    return lonbin, latbin

def get_stranded_flag(ds):
    # identify stranded particles
    flag_meanings=ds.status.flag_meanings
    if not 'stranded' in flag_meanings:
        # if no stranded particles, add this flag manually - 
        # just so we can use this to do subsetting on stranded particles later 
        flag_meanings=flag_meanings+' stranded'
    stranded_flag=flag_meanings.split().index('stranded')
    return stranded_flag

def interp_time(ds,time_factor):
    # interpolate data onto a higher frequency time axis before doing the gridding
    #
    # having a higher frequency time-series might be important in some cases where the 
    # model output skips grid cells, and our output is 'patchy'
    #
    time=ds.time.data
    time_interp=pd.date_range(time[0],time[-1],periods=(len(time)-1)*time_factor+1) # might look like a bit of a weird way of getting the number of periods but it does work
    ds=ds.interp(time=time_interp)
    return ds

def grid_surface(iteration_dir,dx_m=25000,extents=[16,34,-40,-28],time_factor=1):
    
    os.chdir(iteration_dir)
    lonbin, latbin = get_lonlat_bins(extents,dx_m)

    outfile = 'trajectories.nc'
    # use xarray to grid the particles onto a regular grid
    oa = opendrift.open_xarray(outfile)
    ds=oa.ds
    
    # interpolate in time to 'densify' points
    ds=interp_time(ds,time_factor=time_factor)
    
    # identify stranded particles
    stranded_flag = get_stranded_flag(ds)

    # get data for computing surface thickness
    #
    # maybe use a threshold of say -0.1 m?
    ds_surf=ds.where(ds.z==0.0) # could use drop=True to reduce the size of the data, but should make no difference to end result
    # remove stranded data
    ds_surf=ds_surf.where(~(ds_surf.status==stranded_flag)) 
    #
    # compute the weights input to the histogram function which will tell us 
    # the oil volume (m3) per surface particle
    # it will be multipled by the histogram (which computes the number of particles per grid cell)
    # therefore providing us with oil volume per grid cell
    # note we are using mass of the oil emulsion into account (see openoil.get_oil_budget)
    # mass_emulsion = mass_oil / (1 - water_fraction)
    surf_volume=(ds_surf.mass_oil / (1 - ds_surf.water_fraction))/ds_surf.density  
    #
    # compute surface thickness histogram
    h_surf = histogram(ds_surf.lon,
                  ds_surf.lat,
                  bins=[lonbin, latbin],
                  dim=['trajectory'],
                  weights=surf_volume,
                  density=False)
    # convert oil volume per grid cell into oil thickness in micron
    h_surf = h_surf/(np.power(dx_m,2))*1e6
    #
    # TODO: add minimum time to oiling like we do for the stranding?
    #
    # compute the maximum surface thickness over the run
    # TODO: MAYBE WE WANT TO KEEP THE SURFACE THICKNESS AT EACH TIME-STEP? same applies for stranded and subsurface 
    h_surf_max=h_surf.max(('time'))
    h_surf_max=h_surf_max.rename('maximum')
    h_surf_max.attrs["standard_name"] = 'maximum_surface_oil_thickness'
    h_surf_max.attrs["units"] = 'micron'
    # add the bin edges of the histogram so we can use pcolormesh plot properly
    # just adding it as an attribute
    h_surf_max.attrs["lon_bin_edges"] = lonbin
    h_surf_max.attrs["lat_bin_edges"] = latbin
    h_surf_max.to_netcdf('surface_dx'+str(dx_m)+'m.nc')

def grid_stranded(iteration_dir,dx_m=25000,extents=[16,34,-40,-28],time_factor=1):
    
    os.chdir(iteration_dir)
    lonbin, latbin = get_lonlat_bins(extents,dx_m)

    outfile = 'trajectories.nc'
    # use xarray to grid the particles onto a regular grid
    oa = opendrift.open_xarray(outfile)
    ds=oa.ds
    
    # fill deactivated particles with data from the last active time-step
    # this will allow stranded particles to accumulate instead of being deactivated after stranding
    ds=fill_deactivated(ds)
    
    # interpolate in time to 'densify' points
    ds=interp_time(ds,time_factor=time_factor)
    
    # identify stranded particles
    stranded_flag = get_stranded_flag(ds)
    
    # compute the stranded concentration
    ds_strand=ds.where(ds.status==stranded_flag)
    # stranded volume in the same way as surface volume
    strand_mass=(ds_strand.mass_oil / (1 - ds_strand.water_fraction)) 
    h_strand = histogram(ds_strand.lon,
                  ds_strand.lat,
                  bins=[lonbin, latbin],
                  dim=['trajectory'],
                  weights=strand_mass,
                  density=False)
    # convert oil volume per grid cell into g/m2
    beach_width_m=30 # m 1.5 m tidal range and 1:20 beach slope
    h_strand = h_strand*1000/dx_m/beach_width_m
    # compute the minimum time to stranding
    days_since_start = (h_strand.time.data-h_strand.time.data[0]).astype('timedelta64[s]').astype(np.int32)/3600/24 # seriously convoluted but it works. Timedelta64 is not ideals
    h_strand_time=xr.full_like(h_strand, 10e6) # using 10e6 as an arbitrary large number
    # loop through time and replace stranded grid cells with time in days since spill start
    for ii, days in enumerate(days_since_start):
        # h_strand_time.data[ii,:,:] = np.where(np.array(h_strand.data[ii,:,:])>0,days,10e6)
        h_strand_time.data[ii,:,:]=xr.where(h_strand.data[ii,:,:]>0,days,10e6)
    # compute the minimum stranding time
    h_strand_time_min=h_strand_time.min(('time'))
    h_strand_time_min=h_strand_time_min.rename('minimum_time')
    h_strand_time_min.attrs["standard_name"] = 'minimum_time_to_stranding'
    h_strand_time_min.attrs["units"] = '_days_' # using underscores to avoid xarray reading this variable as a timedelta64 later
    # compute the maximum stranded concentration over the run
    h_strand_max=h_strand.max(('time'))
    h_strand_max=h_strand_max.rename('maximum')
    h_strand_max.attrs["standard_name"] = 'maximum_stranded_oil_density'
    h_strand_max.attrs["units"] = 'g/m2'
    # add the bin edges of the histogram so we can use pcolormesh plot properly
    # just adding it as an attribute
    h_strand_max.attrs["lon_bin_edges"] = lonbin
    h_strand_max.attrs["lat_bin_edges"] = latbin
    #
    h_strand_merge=xr.merge([h_strand_max, h_strand_time_min])
        
    h_strand_merge.to_netcdf('stranded_dx'+str(dx_m)+'m.nc')

def grid_subsurface(iteration_dir,dx_m=25000,extents=[16,34,-40,-28],dz_m = 100, z0 = -3000, time_factor=1):
    
    os.chdir(iteration_dir)
    lonbin, latbin = get_lonlat_bins(extents,dx_m)

    outfile = 'trajectories.nc'
    # use xarray to grid the particles onto a regular grid
    oa = opendrift.open_xarray(outfile)
    ds=oa.ds
    
    # interpolate in time to 'densify' points
    ds=interp_time(ds,time_factor=time_factor)
    
    # identify stranded particles
    stranded_flag = get_stranded_flag(ds)
    
    # maybe use a threshold of say -0.1 m?
    ds_sub=ds.where(ds.z<0.0) 
    # remove stranded data (in case subsurface particles intersected with land - it can happen especially with hz diffusion)
    ds_sub=ds_sub.where(~(ds_sub.status==stranded_flag)) 
    # sub_mass=ds_sub.mass_oil
    # sub_z=ds_sub.z
    # need to create z bins for computing concentrations
    # define the bin edges
    # this does 100 m spacing and 25 m in the top 100 m
    # z_bin_edges=np.concatenate((np.arange(-3000,0,100),np.arange(-75,25,25)))
    # using constant spacing based on user input
    z_bin_edges=np.arange(z0,dz_m,dz_m) # from z0 to zero in increments of dz_m
    # from this get the bin centres and thickness
    z_bin_centres=0.5*(z_bin_edges[0:-1]+z_bin_edges[1:])
    z_bin_dz=np.diff(z_bin_edges)
    #
    # Xarray Dataset to store concentrations per z_bin
    # get a temporary 2D histogram so we can initialise the shape of the 3D one
    h_2D = histogram(ds_sub.lon,
                  ds_sub.lat,
                  bins=[lonbin, latbin],
                  dim=['trajectory'],
                  weights=None,
                  density=False)
    Ntime,Nlon,Nlat=np.shape(h_2D)
    # initialise the 3D histogram
    h_sub = xr.DataArray(np.zeros(
        (Ntime, Nlon, Nlat, len(z_bin_centres))),
                        name='maximum',
                        dims=('time', 'lon_bin', 'lat_bin', 'depth'))                           
    h_sub.coords['time'] = ds.coords['time']
    h_sub.coords['depth'] = z_bin_centres
    h_sub.coords['lon_bin'] = h_2D.lon_bin
    h_sub.coords['lat_bin'] = h_2D.lat_bin
    #        
    # loop through the z bins and compute the 2D subsurface histogram for each
    for k,z_bin_centre in enumerate(z_bin_centres):
        # subset the data to this depth bin
        # ds_sub_z=ds_sub.where(ds_sub.z>=z_bin_edges[k]&ds_sub.z<z_bin_edges[k+1]) # I don't have the energy right now to work out why this doesn't work
        ds_sub_z=ds_sub.where(ds_sub.z>=z_bin_edges[k]) 
        ds_sub_z=ds_sub_z.where(ds_sub_z.z<z_bin_edges[k+1]) 
        h_sub_z = histogram(ds_sub_z.lon,
                      ds_sub_z.lat,
                      bins=[lonbin, latbin],
                      dim=['trajectory'],
                      weights=ds_sub_z.mass_oil, # using oil mass for this
                      density=False)
        # convert oil mass per grid cell into oil concentration in ug/l (kg/m3*10^6)
        h_sub_z = h_sub_z/(np.power(dx_m,2))/z_bin_dz[k]*1e6
        h_sub[:, :, :, k] = h_sub_z
    #
    # compute the maximum subsurface concentrations over the run
    h_sub_maxt=h_sub.max(('time'))
    # Now get max concentration over depth 
    h_sub_maxt_maxd=h_sub_maxt.max(('depth'))
    # check these
    # oa.plot(background=h_sub_maxt_maxd.where(h_sub_maxt_maxd>0), bgalpha=1,
    #                 #corners=[4.0, 6, 59.5, 61], 
    #                 fast=False, 
    #                 show_elements=False, 
    #                 vmin=0, 
    #                 vmax=100,
    #                 clabel='max subsurface concentration ($\mu g/l $)',
    #                 filename='run_oil_sub_conc_max.jpg'
    #                 )
    h_sub_maxt_maxd.attrs["standard_name"] = 'maximum_subsurface_concentration'
    h_sub_maxt_maxd.attrs["units"] = 'ug/l'
    # add the bin edges of the histogram so we can use pcolormesh plot properly
    # just adding it as an attribute
    h_sub_maxt_maxd.attrs["lon_bin_edges"] = lonbin
    h_sub_maxt_maxd.attrs["lat_bin_edges"] = latbin
    #
    # now get the depth of max concentration
    h_sub_maxt_maxd_depth=h_sub_maxt.idxmax(('depth')) 
    h_sub_maxt_maxd_depth=h_sub_maxt_maxd_depth.where(h_sub_maxt_maxd) # filter out grid cells where no data
    # oa.plot(background=h_sub_maxt_maxd_depth, bgalpha=1,
    #                 #corners=[4.0, 6, 59.5, 61], 
    #                 fast=False, 
    #                 show_elements=False, 
    #                 vmin=-100, 
    #                 vmax=0,
    #                 clabel='depth of max concentration (m)',
    #                 )
    h_sub_maxt_maxd_depth=h_sub_maxt_maxd_depth.rename('depth_of_maximum')
    h_sub_maxt_maxd_depth.attrs["standard_name"]='depth_of_maximum_subsurface_concentration'
    h_sub_maxt_maxd_depth.attrs["units"]= 'm'
    # merge the max concentration and depth of max concentration into a single data array 
    # and write it to a netcdf 
    h_sub_merged=xr.merge([h_sub_maxt_maxd,h_sub_maxt_maxd_depth])
    h_sub_merged.to_netcdf('subsurface_dx'+str(dx_m)+'m_dz'+str(dz_m)+'m.nc')

def fill_deactivated(ds):
    # use valid longitude values to mask deactivated particles
    ds_masked = ds.where(ds.lon < 361.)
    # use ffill to fill in data using the last valid time-step
    # this won't fill missing data at the start of the file if a particle isn't yet activated
    # but will fill once it has been deactivated
    ds_filled=ds_masked.ffill('time')
    return ds_filled

def get_trajectories_oil_budget(iteration_dir):
    os.chdir(iteration_dir)
    outfile = 'trajectories.nc'
    
    # # read the data
    oa = opendrift.open_xarray(outfile)
    ds=oa.ds
    
    # fill deactivated particles with data from the last active time-step (NB for mass budgets)
    ds=fill_deactivated(ds)
    
    # identify stranded particles
    stranded_flag = get_stranded_flag(ds)
    
    # subsurface mass
    #
    # maybe use a threshold of say -0.1 m?
    ds_sub=ds.where(ds.z<0.0) 
    # remove stranded data (in case subsurface particles intersected with land - it can happen especially with hz diffusion)
    ds_sub=ds_sub.where(~(ds_sub.status==stranded_flag))
    sub_mass=ds_sub.mass_oil.sum(dim='trajectory').rename('subsurface')

    # stranded mass
    #
    ds_strand=ds.where(ds.status==stranded_flag)
    strand_mass=ds_strand.mass_oil.sum(dim='trajectory').rename('stranded')
    
    # surface mass
    #
    # maybe use a threshold of say -0.1 m?
    ds_surf=ds.where(ds.z==0.0) # could use drop=True to reduce the size of the data, but should make no difference to end result
    # remove stranded data
    ds_surf=ds_surf.where(~(ds_surf.status==stranded_flag)) 
    surf_mass=ds_surf.mass_oil.sum(dim='trajectory').rename('surface')
    
    evap_mass=ds.mass_evaporated.sum(dim='trajectory').rename('evaporated')
    
    budget=xr.merge([evap_mass, surf_mass, sub_mass, strand_mass])
    budget.attrs["units"] = 'kg'
    
    budget.to_netcdf('trajectories_oil_budget.nc')

class stochastic_mass_balance:
    """object used to compute the sstochastic mass balance from stochastic iterations
    """
    def __init__(self, out_dir,
                 run_dir, 
                 date_start, 
                 run_id, 
                 run_id_end, 
                 increment_days 
    ):
        self.out_dir                = out_dir # dir where output will be written
        self.run_dir                = run_dir # root dir where stochastic iterations were run
        self.date_start             = date_start
        self.run_id                 = run_id
        self.run_id_end             = run_id_end
        self.increment_days         = increment_days
        self.num_it                 = 0 # number of iterations initialised as zero
        
        # use a template file to initialise the 2D count where threshold is exceeded
        date_now = date_start+timedelta(days=(run_id-1)*increment_days)
        template_dir = run_dir+'run'+str(run_id).zfill(3)+'_'+date_now.strftime("%Y%m%d_%H%M%S")+'/'
        template_file = template_dir+'trajectories_oil_budget.nc'
        ds = xr.open_dataset(template_file)
        days_since_start = (ds.time.data-ds.time.data[0]).astype('timedelta64[s]').astype(np.int32)/3600/24 # seriously convoluted but it works. Timedelta64 is not ideals
        ds = ds.assign(time = days_since_start)
        self.budget = ds
        
    def update(self, run_id):
        self.run_id = run_id
        date_now = self.date_start+timedelta(days=(run_id-1)*self.increment_days)
        # update the number of iterations
        self.num_it += 1 # count how many iterations have gone into computing the stochastic mass balance
        # add data for generating the stochastic budget
        if self.num_it>1:
            # but only if we're not on the first iteration (that was already added in __ini__)
            iteration_dir = self.run_dir+'run'+str(run_id).zfill(3)+'_'+date_now.strftime("%Y%m%d_%H%M%S")+'/'
            iteration_file = iteration_dir+'trajectories_oil_budget.nc'
            ds = xr.open_dataset(iteration_file)
            days_since_start = (ds.time.data-ds.time.data[0]).astype('timedelta64[s]').astype(np.int32)/3600/24 # seriously convoluted but it works. Timedelta64 is not ideals
            ds = ds.assign(time = days_since_start)
            self.budget=xr.concat([self.budget, ds], dim="iteration")

    def __to_netcdf__(self):
        fname = self.out_dir+'trajectories_oil_budget.nc'
        self.budget.to_netcdf(fname)

class stochastic_prob:
    """object used to compute the probability of oiling over defined threshold from stochastic iterations
    """
    def __init__(self, out_dir, 
                 run_dir, 
                 date_start, 
                 run_id, 
                 run_id_end, 
                 increment_days, 
                 dx=25000, 
                 threshold = 1.,
                 posttype='surface',
                 dz = 100 
    ):
        self.out_dir                = out_dir # dir where output will be written
        self.run_dir                = run_dir # root dir where stochastic iterations were run
        self.date_start             = date_start
        self.run_id                 = run_id
        self.run_id_end             = run_id_end
        self.increment_days         = increment_days
        self.dx                     = dx # in m 
        self.threshold              = threshold # units depends on posttype
        self.num_it                 = 0 # number of iterations initialised as zero
        self.posttype               = posttype
        # get the standard filename for this type of postprocessing
        if 'surface' == posttype:
            self.filename_gridded = 'surface_dx'+str(dx)+'m.nc'
        elif 'stranded' == posttype:
            self.filename_gridded = 'stranded_dx'+str(dx)+'m.nc'
        elif 'subsurface' == posttype:
            self.filename_gridded = 'subsurface_dx'+str(dx)+'m_dz'+str(dz)+'m.nc'
            self.dz = dz
        else:
            print(posttype + ' is not valid')
        # use a template file to initialise the 2D count where threshold is exceeded
        date_now = date_start+timedelta(days=(run_id-1)*increment_days)
        template_dir = run_dir+'run'+str(run_id).zfill(3)+'_'+date_now.strftime("%Y%m%d_%H%M%S")+'/'
        template_file = template_dir+self.filename_gridded
        ds_template = xr.open_dataset(template_file)
        lon_bin = ds_template.lon_bin.data
        lat_bin = ds_template.lat_bin.data
        self.lon_bin = lon_bin
        self.lat_bin = lat_bin
        self.lon_bin_edges=ds_template.maximum.attrs['lon_bin_edges']
        self.lat_bin_edges=ds_template.maximum.attrs['lat_bin_edges']
        
        # initialise the dataset used for counting exceedance of threshold
        data_zeros=np.zeros((len(lon_bin), len(lat_bin)))
        data_nans=data_zeros.copy(); data_nans[data_nans==0]=np.nan
        self.stats = xr.Dataset(
            data_vars=dict(
                count_exceed=(["lon_bin","lat_bin"], data_zeros, {'units':'Number_of_times_threshold_is_exceeded'}),
                probability=(["lon_bin","lat_bin"], data_zeros, {'units':'Probability_threshold_is_exceeded'}),
                maximum=(["lon_bin","lat_bin"], data_zeros, {'units':'Maximum_over_all_runs'}),
                run_id_of_max=(["lon_bin","lat_bin"], data_nans, {'units':'Run_id_of_maximum'}),
                minimum_time=(["lon_bin","lat_bin"], data_zeros+10e6, {'units':'Minimum_time_over_all_runs'}),
            ),
            coords=dict(
                lon_bin=(["lon_bin"],lon_bin),
                lat_bin=(["lat_bin"],lat_bin)
            )
        )
        self.stats.attrs["lon_bin_edges"] = self.lon_bin_edges
        self.stats.attrs["lat_bin_edges"] = self.lat_bin_edges
        
        self.no_grid_cells_over_threshold = []
        self.stats.attrs["no_grid_cells_over_threshold"] = []
        self.run_ids = []
        self.stats.attrs["run_ids"] = []
        
        if self.posttype == 'stranded':
            self.count_strand = 0
            self.stats.attrs["probability_stranding"] = 0
            self.stats.attrs["minimum_time_stranding"] = 10e6
        
        
    def update(self, run_id):
        self.run_id = run_id
        date_now = self.date_start+timedelta(days=(run_id-1)*self.increment_days)
        # update the number of iterations
        self.num_it += 1 # count how many iterations have gone into computing the probability
        # read data from this file
        iteration_dir = self.run_dir+'run'+str(run_id).zfill(3)+'_'+date_now.strftime("%Y%m%d_%H%M%S")+'/'
        iteration_file = iteration_dir+self.filename_gridded
        ds = xr.open_dataset(iteration_file)
        iteration_max = ds.maximum.data # 'maximum' is the standard variable name for all posttypes
        # update maximum if data from this iteration is greater
        previous_max=self.stats.maximum.data
        self.stats.maximum.data=np.maximum(iteration_max,previous_max)
        # save the run_id where this iteration is the overall maximum
        run_id_max=self.stats.run_id_of_max.data
        run_id_max[iteration_max>previous_max]=run_id
        self.stats.run_id_of_max.data=run_id_max
        # check where iteration max exceeds threshold and assign a value of 1
        iteration_exceed = np.zeros_like(iteration_max)
        iteration_exceed[iteration_max>self.threshold]=1
        # add up all the grid cells where the threshold is exceeded
        if len(self.no_grid_cells_over_threshold)==0:
            self.no_grid_cells_over_threshold=np.atleast_1d(np.sum(iteration_exceed))
            self.run_ids=np.atleast_1d(run_id)
        else:
            self.no_grid_cells_over_threshold=np.concatenate((self.no_grid_cells_over_threshold,np.atleast_1d(np.sum(iteration_exceed))),axis=0)
            self.run_ids=np.concatenate((self.run_ids,np.atleast_1d(run_id)),axis=0)
        self.stats.attrs["no_grid_cells_over_threshold"] = self.no_grid_cells_over_threshold # so that it is accessible in the output netcdf file we save later
        self.stats.attrs["run_ids"] =  self.run_ids
        # update count where threshold is exceeded
        self.stats.count_exceed.data += iteration_exceed
        # update probability of exceedance
        prob=self.stats.count_exceed.data/self.num_it
        # prob[prob==0]=np.nan
        self.stats.probability.data = prob
        
        if self.posttype == 'stranded':
            
            # update the minimum time
            # for now I've only done minimum time for stranded oil, but could also extend this to surface 
            # and move this block of code out of this if statements
            iteration_minimum_time = xr.where(iteration_exceed==1,ds.minimum_time.data,10e6) # only considering minimum time to oiling for this threshold 
            # update minimum time if data from this iteration is smaller
            previous_minimum_time=self.stats.minimum_time.data
            self.stats.minimum_time.data=np.minimum(iteration_minimum_time,previous_minimum_time)
    
    def __to_netcdf__(self):
        fname = self.out_dir+self.filename_gridded.split('.')[0]+'_threshold'+str(self.threshold)
        self.stats.to_netcdf(fname + '.nc')
    
if __name__ == "__main__":
    
    iteration_dir='/path/to/dir/'
    dx=7500
    
    get_trajectories_oil_budget(iteration_dir)
        
