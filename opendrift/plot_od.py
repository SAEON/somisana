#!/usr/bin/env python
"""
functions for plotting / animating opendrift output
(there are some plotting methods as part of opendrift source code
 but we'd like to do our own tailor made ones)
"""

import sys, os, glob
import numpy as np
from datetime import datetime, timedelta
import xarray as xr
import opendrift
from opendrift.readers import reader_netCDF_CF_generic
from opendrift.readers import reader_ROMS_native
from opendrift.models.openoil import OpenOil
from opendrift.readers import reader_global_landmask
import matplotlib.pyplot as plt
import matplotlib.colors as mplc
import matplotlib.cm as cm
from matplotlib.animation import FuncAnimation
from copy import copy
import xarray as xr
from xhistogram.xarray import histogram
import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import pandas as pd
import post_od as post
import matplotlib.path as mplPath

def get_croco_boundary(fname):
    '''
    Return lon,lat of perimeter around a CROCO grid (i.e. coordinates of bounding cells)
    '''
    with xr.open_dataset(fname) as ds:
        lon_rho = ds.lon_rho.values
        lat_rho = ds.lat_rho.values

    lon = np.hstack((lon_rho[0:, 0], lon_rho[-1, 1:-1],
                     lon_rho[-1::-1, -1], lon_rho[0, -2::-1]))
    lat = np.hstack((lat_rho[0:, 0], lat_rho[-1, 1:-1],
                     lat_rho[-1::-1, -1], lat_rho[0, -2::-1]))
    return lon, lat

def extents_2_polygon(extents):
    extents_poly = mplPath.Path(np.array([[extents[0], extents[2]],
                                    [extents[1], extents[2]],
                                    [extents[1], extents[3]],
                                    [extents[0], extents[3]]]))
    return extents_poly

def standard_plots(iteration_dir,traj_depths=False,traj_profile=False,budget=False):
    # standard debugging plots that come with opendrift
    print('doing plots for '+iteration_dir+'\n')
    os.chdir(iteration_dir)
    # read the data
    o = OpenOil(loglevel=0)
    o.io_import_file('trajectories.nc')
    if traj_depths:
        o.animation(fast=False, color='z', filename='trajectories_z.gif')
    if traj_profile:
        o.animation_profile(filename='trajectories_profile.gif')
    if budget:
        o.plot_oil_budget(filename='trajectories_oil_budget.jpg')
    
    del(o)

def plot_budget(iteration_dir,
                figsize=(12,6)):
    
    filename='trajectories_oil_budget'
    os.chdir(iteration_dir)
    ds = xr.open_dataset(filename+'.nc')
    
    time=ds.time.data
    evaporated=ds.evaporated.data
    surface=ds.surface.data
    subsurface=ds.subsurface.data
    stranded=ds.stranded.data
    total=evaporated+surface+subsurface+stranded
    
    fig, ax = plt.subplots(figsize=figsize)
    
    ax.plot(time, evaporated, label='evaporated')
    ax.plot(time, surface, label='surface')
    ax.plot(time, subsurface, label='subsurface')
    ax.plot(time, stranded, label='stranded')
    ax.plot(time, total, label='total')
    
    ax.grid(linestyle='-', linewidth=0.3)
    
    ax.set_xlabel('time',fontsize=12)
    # ax.set_xlim(0, 100)
    # xticks=np.arange(0,100,5)
    # ax.set_xticks(xticks)
    
    ax.legend(loc="upper left")
    
    ax.set_ylabel('oil mass (kg)',fontsize=12)

    plt.savefig(filename+'.jpg',dpi=500,bbox_inches = 'tight')
    
def plot_stochastic_budget(nc_dir,plot_dir,fname,
                figsize=(12,6),
                xlims=[0,90],
                ylims=[0,1.375e7],
                ttl=[]):
    
    ds = xr.open_dataset(nc_dir+fname+'.nc')
    
    ds_mean = ds.mean(dim='iteration')
    ds_std = ds.std(dim='iteration')
    ds_5ptile = ds.quantile(0.05,dim='iteration')
    ds_25ptile = ds.quantile(0.25,dim='iteration')
    ds_50ptile = ds.quantile(0.5,dim='iteration')
    ds_75ptile = ds.quantile(0.75,dim='iteration')
    ds_95ptile = ds.quantile(0.95,dim='iteration')
    
    ds_total = ds.subsurface+ds.surface+ds.stranded+ds.evaporated
    # the total mass should be exactly the same in all iterations so just calculating mean and std as a check
    ds_total_mean = ds_total.mean(dim='iteration')
    ds_total_std = ds_total.std(dim='iteration')
    ds_total_5ptile = ds_total.quantile(0.05,dim='iteration')
    ds_total_95ptile = ds_total.quantile(0.95,dim='iteration')
    
    fig, ax = plt.subplots(figsize=figsize)
    
    ax.plot(ds.time, ds_mean.subsurface, label='subsurface', color = 'blue')
    plt.fill_between(ds.time,
                     ds_5ptile.subsurface,
                     ds_95ptile.subsurface,
                     alpha = 0.2, color = 'blue', label='_nolegend_')
    
    ax.plot(ds.time, ds_mean.surface, label='surface', color = 'green')
    plt.fill_between(ds.time,
                     ds_5ptile.surface,
                     ds_95ptile.surface,
                     alpha = 0.2, color = 'green', label='_nolegend_')
    
    ax.plot(ds.time, ds_mean.evaporated, label='evaporated', color = 'orange')
    plt.fill_between(ds.time,
                     ds_5ptile.evaporated,
                     ds_95ptile.evaporated,
                     alpha = 0.2, color = 'orange', label='_nolegend_')
    
    ax.plot(ds.time, ds_mean.stranded, label='stranded', color = 'red')
    plt.fill_between(ds.time,
                     ds_5ptile.stranded,
                     ds_95ptile.stranded,
                     alpha = 0.2, color = 'red', label='_nolegend_')
    
    ax.plot(ds.time, ds_total_mean, label='total', color = 'purple')
    # total oil should have no variability - this is just a check:
    # plt.fill_between(ds.time,
    #                  ds_total_5ptile,
    #                  ds_total_95ptile,
    #                  alpha = 0.2, color = 'red', label='_nolegend_')
    
    ax.set_xlabel('time (days since start of spill)',fontsize=12)
    ax.set_xlim(xlims[0], xlims[1])
    ax.set_ylabel('mass of oil (kg)',fontsize=12)
    ax.set_ylim(ylims[0], ylims[1])
    ax.grid(linestyle='-', linewidth=0.3)
    ax.legend(loc="upper right", frameon=False)
    
    if ttl:
        plt.title(ttl,fontsize=12)
    
    ds.close()
    
    plt.savefig(plot_dir+fname+'.jpg',dpi=500,bbox_inches = 'tight')

def iteration_plot_grid(iteration_dir,
                            dx=25000, 
                            figsize=(12,6),
                            levels = [0.01,0.1,1.,10.],
                            posttype='surface',
                            dz = 100,
                            extents=[20,34,-40,-28],
                            lon_release=31.779959,
                            lat_release=-30.539622,
                            col_spill='k', # text colour for marking spill location
                            plot_cbar=True,
                            cbar_loc=(0.75, 0.15, 0.01, 0.7),
                            strand_scat_size=20,
                            ttl = []
                            ):
    
    # get the standard filename for this type of postprocessing
    if 'surface' == posttype:
        filename_gridded = 'surface_dx'+str(dx)+'m'
        label = 'max surface oil thickness ($\mu$m)'
        cmap = copy(cm.get_cmap('viridis'))
        # cmap.set_over('darkred')
    elif 'stranded' == posttype:
        filename_gridded = 'stranded_dx'+str(dx)+'m'
        label = 'max shoreline oil (g m$^{-2}$)'
        cmap = copy(cm.get_cmap('autumn_r'))
        cmap.set_over('darkred')
    elif 'subsurface' == posttype:
        filename_gridded = 'subsurface_dx'+str(dx)+'m_dz'+str(dz)+'m'
        label = 'max subsurface concentration ($\mu g/l $)'
        cmap = copy(cm.get_cmap('viridis'))
        # cmap.set_over('darkred')
    cmap.set_under('white')
    
    # print('doing grid plot for '+iteration_dir.split('/')[-2]+'\n')
    os.chdir(iteration_dir)
    ds = xr.open_dataset(filename_gridded+'.nc')
    
    lon=ds.lon_bin.data
    lat=ds.lat_bin.data
    maximum=np.transpose(ds.maximum.data) # transpose because we need (lat,lon) for plotting but data are saved as (lon,lat)?
    # maximum[maximum==0]=np.nan
    maximum[maximum<min(levels)]=np.nan
        
    lon_edges=ds.maximum.attrs['lon_bin_edges']
    lat_edges=ds.maximum.attrs['lat_bin_edges']

    fig = plt.figure(figsize=figsize)
    ax = plt.axes(projection=ccrs.Mercator())

    plot_generic(ax,extents)
    
    # add a box showing extent of where subsurface concentrations are computed
    # (considered as a special case as subsurface not typically computed over entire domain)
    if posttype == 'subsurface':
        ax.plot([lon_edges[0],lon_edges[-1],lon_edges[-1],lon_edges[0],lon_edges[0]],
                [lat_edges[0],lat_edges[0],lat_edges[-1],lat_edges[-1],lat_edges[0]],
                transform=ccrs.PlateCarree(),
                color='k')
        
    n_levels = len(levels); vmin = min(levels); vmax = max(levels)
    levels = np.array(levels)
    cmap_norm = mplc.BoundaryNorm(boundaries=levels, ncolors=256)
    #cmap_norm = mplc.BoundaryNorm(levels, cmap.N)
    #cmap_ScMappable = cm.ScalarMappable(cmap=cmap, norm=cmap_norm)
    
    # plot the data
    if posttype == 'stranded':
        lon,lat=np.meshgrid(lon,lat)
        pcm = ax.scatter(lon.flatten(),lat.flatten(), s=strand_scat_size, c=maximum.flatten(), 
                          transform=ccrs.PlateCarree(),
                          cmap=cmap,
                          norm=cmap_norm)
    else:
        pcm = ax.pcolormesh(lon_edges,lat_edges,maximum,
                            cmap=cmap,
                            norm=cmap_norm,
                            transform=ccrs.PlateCarree())
    
    if ttl:
        # add a title
        ax.text(0.5*(extents[0]+extents[1]), extents[3]+0.03*(extents[3]-extents[2]), ttl,
                transform=ccrs.PlateCarree(),ha='center', fontsize=12)
        
    if plot_cbar:
        # add a colorbar
        cax = plt.gcf().add_axes(cbar_loc) # [left, bottom, width, height] 
        cbar = plt.colorbar(
            pcm,
            cax=cax,
            extend='both'
        )
        cbar.set_label(label, fontsize=12)
        cbar.ax.tick_params(labelsize=12)
    
    # mark the spill location
    plot_release_loc(ax,lon_release,lat_release,col=col_spill)
    
    plt.savefig(filename_gridded+'.jpg',dpi=500,bbox_inches = 'tight')
    
def plot_generic(ax, extents):
    # generic stuff applicable to all plots
    ax.set_extent(extents)
    ax.add_feature(cfeature.LAND, zorder=0, edgecolor='black')
    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                      linewidth=1, color='dimgrey', alpha=0.5, linestyle=':')
    gl.right_labels = False
    gl.top_labels = False

def plot_release_loc(ax,lon_release,lat_release,col='k'):
    ax.scatter(lon_release,lat_release, 50, transform=ccrs.PlateCarree(),marker='X',color=col)
    # ax.text(lon_release+0.5, lat_release+0.25, 'spill location',color=col,
    #           ha='center', fontsize=10, va='center', #backgroundcolor='w', 
    #           transform=ccrs.PlateCarree())

def get_time_txt(ax,ds,time_plot):
    # compute how long this time-step is from the start of the run
    time_start = ds.time.data[0]
    days_since_start = (time_plot-time_start).astype('timedelta64[s]').astype(np.int32)/3600/24 # days
    days_since_start_int = np.floor(days_since_start).astype('int')
    hours_since_start = np.round((days_since_start-days_since_start_int)*24,0).astype('int')
    time_plot=time_plot+np.timedelta64(2,'h') # show local time UTC+2 in plot
    time_str = str(time_plot)[:10]+' '+str(time_plot)[11:19] # hack to get rid of the 'T' in the output of str(time_plot) - np.datetime64 is not great but is what our output comes as
    tx_time = time_str+'\n'+'('+str(days_since_start_int)+' days, '+str(hours_since_start)+' hours after start of spill)'
    return tx_time

def iteration_plot_tstep(iteration_dir,
                         days_from_start=7,
                         figsize=(12,6),
                         extents=[20,34,-40,-28],
                         lon_release=31.779959,
                         lat_release=-30.539622,
                         time_x=0.1, 
                         time_y=0.9,
                         vmin=-2800,
                         vmax=0,
                         plot_cbar=True,
                         cbar_loc=(0.78, 0.15, 0.01, 0.7),
                         ttl=[]
                         ):
    # print('doing iteration plot for '+iteration_dir.split('/')[-2]+', time '+time_plot+'\n')
    os.chdir(iteration_dir)
    
    # oa = opendrift.open_xarray('trajectories.nc')
    # ds=oa.ds
    ds = xr.open_dataset('trajectories.nc')
    
    # extract data for the time-step we want to plot
    time_plot = ds.time.data[0] + np.timedelta64(days_from_start,'D')
    ds_tstep=ds.sel(time=time_plot)
    lon=ds_tstep.lon
    lat=ds_tstep.lat
    dep = ds_tstep.z.data

    # set up the plot
    fig = plt.figure(figsize=figsize)
    ax = plt.axes(projection=ccrs.Mercator())
    ax.set_position(  (0, 0, 1, 0.8))
    plot_generic(ax,extents)

    # show the time
    tx_time = get_time_txt(ax, ds, time_plot)
    tx=ax.text(time_x, time_y, tx_time,
             ha='left', fontsize=10,
             transform=ax.transAxes)
             #transform=ccrs.PlateCarree())
    
    # add the particles
    scat = ax.scatter(lon,lat, s=10, c=dep, 
                      transform=ccrs.PlateCarree(),
                      cmap='Spectral_r', #'viridis',
                      vmin = vmin,
                      vmax = vmax)

    # mark the spill location
    plot_release_loc(ax,lon_release,lat_release)
    
    if plot_cbar:
        # add a colorbar for the scatter data
        cbarax = plt.gcf().add_axes(cbar_loc) 
        cbar = plt.colorbar(scat, cbarax)
        cbar.set_label('depth (m)', fontsize=12)
    
    if ttl:
        # add a title
        ax.text(0.5*(extents[0]+extents[1]), extents[3]+0.03*(extents[3]-extents[2]), ttl,
                transform=ccrs.PlateCarree(),ha='center', fontsize=12)
        # plt.title(ttl)
    
    plt.savefig('trajectories_'+str(days_from_start)+'days.jpg',dpi=500,bbox_inches = 'tight')

def iteration_animate(iteration_dir,
                      figsize=(12,6),
                      time_fraction = 4,
                      extents=[20,34,-40,-28],
                      lon_release=31.779959,
                      lat_release=-30.539622,
                      time_x=0.1, 
                      time_y=0.9,
                      vmin=-2800,
                      vmax=0,
                      cmap='Spectral_r',
                      plot_cbar=True,
                      cbar_loc=(0.78, 0.15, 0.01, 0.7),
                      croco_dirs=None,
                      croco_run_date=None,
                      ):

    os.chdir(iteration_dir)
    
    ds = xr.open_dataset('trajectories.nc')
   
    # if you want to animate only the surface particles
    # maybe use a threshold of say -0.1 m?
    # ds=ds.where(ds.z==0.0) 

    ds = post.fill_deactivated(ds)
    
    # identify stranded particles
    stranded_flag = post.get_stranded_flag(ds)
    ds_strand=ds.where(ds.status==stranded_flag)
    
    time_all = ds.time.data

    # extract data for the time-step we want to plot
    indx=0 # start with the first time-step
    time_plot = time_all[indx]
    ds_tstep=ds.sel(time=time_plot)
    #
    ds_strand_tstep=ds_strand.sel(time=time_plot)
    
    lon=ds_tstep.lon.data
    lat=ds_tstep.lat.data
    dep = ds_tstep.z.data
    #
    lon_strand=ds_strand_tstep.lon.data
    lat_strand=ds_strand_tstep.lat.data

    fig = plt.figure(figsize=figsize)
    ax = plt.axes(projection=ccrs.Mercator())

    plot_generic(ax,extents)

    # show the time stamp somewhere
    tx_time = get_time_txt(ax, ds, time_plot) # correcting for UTC+2
    tx=ax.text(time_x, time_y, tx_time,
             ha='left', fontsize=10,
             transform=ax.transAxes)
             #transform=ccrs.PlateCarree())

    # add the particles
    scat = ax.scatter(lon,lat, s=10, c=dep, 
                      transform=ccrs.PlateCarree(),
                      cmap=cmap, #'viridis',
                      vmin = vmin,
                      vmax = vmax)
    
    # add the stranded particles
    scat_strand = ax.scatter(lon_strand,lat_strand, s=10, color='r', 
                      transform=ccrs.PlateCarree())

    # mark the spill location
    plot_release_loc(ax,lon_release,lat_release)
    
    if plot_cbar:
        # add a colorbar for the scatter data
        cbarax = plt.gcf().add_axes(cbar_loc) 
        cbar = plt.colorbar(scat, cbarax)
        cbar.set_label('depth (m)', fontsize=12)
    
    # add the boundaries of the croco domains
    # in future, the loop below could be nested in a loop on levels so file extension would be nc.level
    if croco_dirs:
        for croco_dir in croco_dirs:
            croco_file = croco_dir+'stable/'+croco_run_date+'/croco/forecast/hourly-avg-'+croco_run_date+'.nc'
            lon_bry,lat_bry=get_croco_boundary(croco_file)
            #repeat the first point to create a 'closed loop'
            lon_bry=np.append(lon_bry,lon_bry[0])
            lat_bry=np.append(lat_bry,lat_bry[0])
            ax.plot(lon_bry,lat_bry,color='k',transform=ccrs.PlateCarree())

    def animate(i):
        
        # get the data for this time-step
        time_plot = time_all[i*time_fraction]
        ds_tstep=ds.sel(time=time_plot)
        lon=ds_tstep.lon.data
        lat=ds_tstep.lat.data
        dep = ds_tstep.z   
        #
        ds_strand_tstep=ds_strand.sel(time=time_plot)
        lon_strand=ds_strand_tstep.lon.data
        lat_strand=ds_strand_tstep.lat.data
        
        # update the time label
        tx_time = get_time_txt(ax, ds, time_plot)
        tx.set_text(tx_time)
        
        # update the scatter data
        scat.set_offsets(np.c_[lon,lat])
        scat.set_array(dep)
        scat_strand.set_offsets(np.c_[lon_strand,lat_strand])
        
    anim = FuncAnimation(
        fig, animate, interval=100, frames=range(0,int(len(time_all)/time_fraction)-1)) 

    anim_file='trajectories_anim.gif'
    anim.save(anim_file, writer='imagemagick')

def plot_prob(nc_dir,plot_dir,fname,
              figsize=(12,6),
              extents=[15.2,33,-35,-27.2], # x0,x1,y0,y1
              levels=[0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0],
              label = 'probability threshold is exceeded',
              lon_release=31.779959,
              lat_release=-30.539622,
              plot_cbar=True,
              cbar_loc=(0.75, 0.15, 0.01, 0.7),
              ttl=[],
              table_font=10
              ):
    
    ds = xr.open_dataset(nc_dir+fname+'.nc')
    
    lon_edges=ds.attrs['lon_bin_edges']
    lat_edges=ds.attrs['lat_bin_edges']
    
    prob = np.transpose(ds.probability.data) # transpose because we need (lat,lon) for plotting but data are saved as (lon,lat)?
    # prob[prob==0]=np.nan
    prob[prob<min(levels)]=np.nan
    ds.close()
    
    fig = plt.figure(figsize=figsize)
    ax = plt.axes(projection=ccrs.Mercator())
    
    plot_generic(ax,extents)
    
    # add a box showing extent of where subsurface concentrations are computed
    # (considered as a special case as subsurface not typically computed over entire domain)
    if 'subsurface' in label:
        ax.plot([lon_edges[0],lon_edges[-1],lon_edges[-1],lon_edges[0],lon_edges[0]],
                [lat_edges[0],lat_edges[0],lat_edges[-1],lat_edges[-1],lat_edges[0]],
                transform=ccrs.PlateCarree(),
                color='k')
    
    n_levels = len(levels); vmin = min(levels); vmax = max(levels)
    levels = np.array(levels)
    cmap_norm = mplc.BoundaryNorm(boundaries=levels, ncolors=256)
    
    # plot the data
    if fname[0:8] == 'stranded':
        # stranded data gets plotted really small depending on the zoom extent
        # so plotting as points rather to control the size of the points
        lon=ds.lon_bin.data
        lat=ds.lat_bin.data
        lon,lat=np.meshgrid(lon,lat)
        mappable = ax.scatter(lon.flatten(),lat.flatten(), s=7, c=prob.flatten(), 
                          transform=ccrs.PlateCarree(),
                          cmap='jet',
                          # vmin=0,
                          # vmax=1,
                          norm=cmap_norm
                          )
    else:
        mappable = ax.pcolormesh(lon_edges,
                                 lat_edges,
                                 prob,
                                 # vmin=0,
                                 # vmax=1,
                                 cmap='jet',
                                 norm=cmap_norm,
                                 transform=ccrs.PlateCarree())
    
    plot_release_loc(ax,lon_release,lat_release,col='k')
    
    if ttl:
        # add a title
        ax.text(0.5*(extents[0]+extents[1]), extents[3]+0.03*(extents[3]-extents[2]), ttl,
                transform=ccrs.PlateCarree(),ha='center', fontsize=12)
        
    # add a legend
    if plot_cbar:
        cbarax = plt.gcf().add_axes(cbar_loc) # [left, bottom, width, height] 
        cbar = plt.colorbar(mappable, cbarax, ticks=levels)
        cbar.set_label(label, fontsize=12)
    
    plt.savefig(plot_dir+fname+'.jpg',dpi=500,bbox_inches = 'tight')

def plot_exceedance(nc_dir,plot_dir,dx,
                        posttype = 'surface',
                        thresholds = [0.01,1,10],
                        figsize=(8,5),
                        ylim_max=150000,
                        ttl = [],
                        scilimits = []
                        ):
    
    if 'surface' == posttype:
        units = '$\mu$m'
        ylab = 'Area swept (km$^2$)'
        factor = dx*dx/1e6, # factor which no. grid cells is multiplied by (area of grid cell)
    elif 'stranded' == posttype:
        units = 'g m$^{-2}$'
        ylab = 'Length of coastline (km)'
        factor = dx/1e3, # factor which no. grid cells is multiplied by (length of grid cell)
    elif 'subsurface' == posttype:
        print('subsurface exceedance plots not implemented yet')
        exit()
    else:
        print('posttype must be either surface or stranded')
        exit()
    
    fig, ax = plt.subplots(figsize=figsize)
    # fig = plt.figure(figsize=figsize)
    # ax = plt.axes()
    
    for threshold in thresholds:
        fname = nc_dir+posttype+'_dx'+str(dx)+'m_threshold'+str(threshold)+'.nc'
        ds = xr.open_dataset(fname)
        my_data=np.sort(ds.attrs['no_grid_cells_over_threshold']*factor)
        ds.close()
        ptile = np.linspace(0,100,len(my_data),endpoint=True)
        ax.plot(ptile, my_data, label='threshold = '+str(threshold)+' '+units)
    
    ax.grid(linestyle='-', linewidth=0.3)
    
    ax.set_xlabel('Percentile',fontsize=12)
    ax.set_xlim(0, 100)
    xticks=np.arange(0,100,5)
    ax.set_xticks(xticks)
    
    ax.set_ylabel(ylab,fontsize=12)
    if ylim_max:
        ax.set_ylim(0, ylim_max)

    if scilimits:
        ax.ticklabel_format(axis='y',scilimits=scilimits)

    ax.legend(loc="upper left")
    
    if ttl:
        # plt.title(ttl,fontsize=12)
        # rather do it like this to extend plot on top rather than make it smaller
        # so we can patch plots together better
        ax.text(50, ylim_max+0.03*ylim_max, ttl,
                ha='center', fontsize=12)
    
    plt.savefig(plot_dir+posttype+'_dx'+str(dx)+'m_exceedance.jpg',dpi=500,bbox_inches = 'tight')
    
if __name__ == "__main__":
    
    iteration_dir='/path/to/dir/'
    dx=7500
    lon_release=31.779959
    lat_release=-30.539622
    
    plot_budget(iteration_dir)
    
    
