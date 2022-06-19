#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
scripts for getting input ready for running parcels

"""

from netCDF4 import Dataset,num2date,date2num
#%matplotlib inline
from matplotlib import pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
#import matplotlib.pyplot as plt
#from mpl_toolkits.mplot3d import Axes3D  # noqa
import numpy as np
from datetime import timedelta, date, datetime

def extend_uvpsi(lonp,latp,u,v):
    #
    # Note this function assumes that the first dimension for u and v is time
    #
    # We need to modify our croco grid, as described in the parcels documentation:
    #
    # Excerpt from https://nbviewer.jupyter.org/github/OceanParcels/parcels/blob/master/parcels/examples/documentation_indexing.ipynb
    #"Now, as you've noticed on the grid illustrated on the figure, there are 4x4 cells. 
    #The grid providing the cell corners is a 5x5 grid, but there are only 4x5 U nodes and 5x4 V nodes, 
    #since the grids are staggered. This implies that the first row of U data and the first column of V 
    #data is never used (and do not physically exist), but the U and V fields are correctly provided on 
    #a 5x5 table. If your original data are provided on a 4x5 U grid and a 5x4 V grid, 
    #you need to regrid your table to follow Parcels notation before creating a FieldSet!"
    #
    # This is our situation for the croco grid. The croco 'psi' grid is the one we want to use
    # however it doesn't cover all of our rho points. We could get around this in two ways.
    # We could either remove a row (column) from u (v), or we can add a column (row) to u (v). 
    # I am opting to add on as I'd prefer not to throw away valid u/v data. 
    # Also, at some point we may want to use tracers in the model, which are on the rho grid, 
    # and we want to preserve all of our rho points.
    #
    # So lets do that then using the grid spacing from the last two grid cells 
    # (I've plotted the generated grid cells to make sure this gives us the desired result- see check_grid.py)
    #
    # add both a row and a column to the psi grid, by using last grid step to extrapolate grid
    lonp=np.append(lonp, np.atleast_2d(lonp[:,-1]+lonp[:,-1]-lonp[:,-2]).T, axis=1)
    latp=np.append(latp, np.atleast_2d(latp[:,-1]+latp[:,-1]-latp[:,-2]).T, axis=1)
    lonp=np.append(lonp, np.atleast_2d(lonp[-1,:]+lonp[-1,:]-lonp[-2,:]), axis=0)
    latp=np.append(latp, np.atleast_2d(latp[-1,:]+latp[-1,:]-latp[-2,:]), axis=0)
       
    # add a row to v and a column to u to match our psi grid extension
    # just repeat the relevant row / column
    u_ext=np.atleast_3d(u[:,:,-1])
    u=np.append(u, u_ext, axis=2)
    v_ext=np.atleast_3d(v[:,-1,:])
    v_ext=np.transpose(v_ext, (0, 2, 1))
    v=np.append(v, v_ext, axis=1)
    
    # u and v remain on their original stagerred grids, but are now in the 
    # correct format to be ingested into parcels
    
    return lonp,latp,u,v
    
def write_parcels_input(time,date_ref,lonp,latp,maskr,u,v,angle,outfile):
        
    # Write the data we need to a netdcf file to be ingested by parcels
    #
    # create a netcdf file
    g=Dataset(outfile, 'w', format='NETCDF3_64BIT')
    #
    # create the dimensions
    g.createDimension('time',time.size)
    # note parcels only needs the psi grid, which defines the corners of the grid cells
    y,x=lonp.shape
    g.createDimension('y',y)
    g.createDimension('x',x)
    #
    # create the variables
    time_var=g.createVariable('time','f4',('time',))
    lat_var=g.createVariable('lat','f4',('y','x'))
    lon_var=g.createVariable('lon','f4',('y','x'))
    mask_var=g.createVariable('mask','f4',('y','x'))
    u_var=g.createVariable('u','f4',('time','y','x'))
    v_var=g.createVariable('v','f4',('time','y','x'))
    angle_var=g.createVariable('angle','f4',('y','x'))
    #
    # set the variable attributes
    # time
    time_var.standard_name='time'
    time_var.long_name=''
    time_var.units='seconds since '+str(date_ref)
    time_var.calendar='julian'
    # lat
    lat_var.standard_name='lat'
    lat_var.long_name='latitude of curvilinear grid'
    lat_var.units='degrees_north'
    # lon
    lon_var.standard_name='long'
    lon_var.long_name='longitude of curvilinear grid'
    lon_var.units='degrees_east'
    # mask
    mask_var.standard_name='mask'
    mask_var.long_name='land mask (0=land, 1=ocean)'
    mask_var.units='-'
    # u
    u_var.standard_name='u'
    u_var.long_name='grid aligned u component of velocity'
    u_var.units='m s-1'
    # v
    v_var.standard_name='v'
    v_var.long_name='grid aligned v component of velocity'
    v_var.units='m s-1'
    # angle
    angle_var.standard_name='angle'
    angle_var.long_name='angle of curvilinear grid'
    angle_var.units='radians'
    #
    # assign the data to the variables
    g.variables['time'][:]=time
    g.variables['lat'][:]=latp
    g.variables['lon'][:]=lonp
    g.variables['mask'][:]=maskr
    g.variables['u'][:]=u
    g.variables['v'][:]=v
    g.variables['angle'][:]=angle
    #
    g.close()
    
def make_curr_surf(grdfile,avgfile,outfile,date_ref):
    # make a netcdf input file to be ingested by parcels from a croco surface output file
    
    # Extract grid data
    nc_id_grd = Dataset(grdfile, 'r')
    latp = nc_id_grd.variables['lat_psi'][:]
    lonp = nc_id_grd.variables['lon_psi'][:]
    maskr = nc_id_grd.variables['mask_rho'][:]
    masku = nc_id_grd.variables['mask_u'][:]
    maskv = nc_id_grd.variables['mask_v'][:]   
    angle = nc_id_grd.variables['angle'][:]
    
    # note we are using the rho mask to denote land, but the psi grid is what 
    # we give parcels as the input C-grid. My reading of the tutorials is that 
    # this is what we need to do. "in a C-grid, the tracer grid cell is on the top-right corner"
    # In other words, we give parcels only one grid, the psi grid, and it knows 
    # that the tracer values are actually shifted relative to the input grid
    # e.g. see "https://nbviewer.jupyter.org/github/OceanParcels/parcels/blob/master/parcels/examples/tutorial_interpolation.ipynb"
    
    # Grab the data from the croco surface output file
    nc_id_avg = Dataset(avgfile, 'r')
    time = nc_id_avg.variables['time'][:]
    # check these times by generating a list of dates
    #dates=[]
    #for t in time:
    #    date_now=date_ref + timedelta(seconds=np.float64(t))
    #    dates.append(date_now)
    
    # get the u,v data
    u = nc_id_avg.variables['surf_u'][:]
    v = nc_id_avg.variables['surf_v'][:]
    
    # mask using nans
    # (first repeat the mask in time to make it easier to apply)
    masku=np.tile(masku, (len(time),1,1))
    maskv=np.tile(maskv, (len(time),1,1))
    u[masku==0]=np.nan
    v[maskv==0]=np.nan
    
    # get u,v onto a common extended psi grid to be fed to parcels
    lonp,latp,u,v=extend_uvpsi(lonp,latp,u,v)
    
    write_parcels_input(time,date_ref,lonp,latp,maskr,u,v,angle,outfile)

def make_wind_blk(grdfile,blkfile,outfile,date_ref,frac,rot):
    # make a netcdf input file to be ingested by parcels from a croco blk input file
    #
    # frac= fraction of wind speed to be used to advect particles
    # rot= angle to rotate winds, in an anticlockwise direction, due to Ekman drift (in degrees)
    
    # Extract grid data
    nc_id_grd = Dataset(grdfile, 'r')
    latp = nc_id_grd.variables['lat_psi'][:]
    lonp = nc_id_grd.variables['lon_psi'][:]
    maskr = nc_id_grd.variables['mask_rho'][:]
    masku = nc_id_grd.variables['mask_u'][:]
    maskv = nc_id_grd.variables['mask_v'][:] 
    angle = nc_id_grd.variables['angle'][:]
    
    # Grab the data from the croco blk input file
    nc_id_blk = Dataset(blkfile, 'r')
    time = nc_id_blk.variables['bulk_time'][:]
    time=time*24*3600 # converting to seconds since date_ref
    # check these times by generating a list of dates
    # dates=[]
    # for t in time:
    #     date_now=date_ref + timedelta(seconds=np.float64(t))
    #     dates.append(date_now)
    
    # get the u,v data
    u = nc_id_blk.variables['uwnd'][:]
    v = nc_id_blk.variables['vwnd'][:]
    
    # mask using nans
    # (first repeat the mask in time to make it easier to apply)
    masku=np.tile(masku, (len(time),1,1))
    maskv=np.tile(maskv, (len(time),1,1))
    u[masku==0]=np.nan
    v[maskv==0]=np.nan
    
    # get u,v onto a common extended psi grid to be fed to parcels
    lonp,latp,u,v=extend_uvpsi(lonp,latp,u,v)
    
    # get the fraction of the wind speed used to advect surface particles
    u=u*frac
    v=v*frac
    
    # rotate the currents due to Ekman drift
    rot=rot*np.pi/180
    cosa = np.cos(rot);
    sina = np.sin(rot);
    ur = u*cosa - v*sina;
    vr = v*cosa + u*sina;
    
    write_parcels_input(time,date_ref,lonp,latp,maskr,ur,vr,angle,outfile)

def extend_grid_algoa(infile):
    # this is a hack to extend the Algoa Bay grid at the northern boundary
    # as our grid has a few missing land points along the northern boundary.
    # In croco this is fine as it is a closed boundary, but in parcels the particles
    # escape through here. So we'll just pad it with some missing data
    nc_id = Dataset(infile, 'r')
    time = nc_id.variables['time'][:]
    t_unit_in = nc_id.variables['time'].units
    t_cal_in = nc_id.variables['time'].calendar
    date_ref=num2date(0,t_unit_in,calendar=t_cal_in) #i.e. date_ref is the reference datetime in the input file
    lon = nc_id.variables['lon'][:]
    lat = nc_id.variables['lat'][:]
    mask = nc_id.variables['mask'][:]
    angle = nc_id.variables['angle'][:]
    u = nc_id.variables['u'][:]
    v = nc_id.variables['v'][:]
    del nc_id
    
    Nt,Ny,Nx=np.shape(u)    
    for i in range(5): # loop over the number of rows to add (1 wasn't enough!, so just doing 5 to be safe)
        # extent the lon lat grid by using the grid step for the last row
        lon=np.append(lon, np.atleast_2d(lon[-1,:]+lon[-1,:]-lon[-2,:]), axis=0)
        lat=np.append(lat, np.atleast_2d(lat[-1,:]+lat[-1,:]-lat[-2,:]), axis=0)
        # fill the mask with zeros
        mask=np.append(mask,np.zeros((1,Nx)),axis=0)
        # the angle with the value in the last row
        angle=np.append(angle,np.atleast_2d(angle[-1,:]),axis=0)
        # and u,v with nans
        u=np.append(u,np.empty((Nt,1,Nx))*np.nan,axis=1)
        v=np.append(v,np.empty((Nt,1,Nx))*np.nan,axis=1)
    
    # note infile gets over-written
    write_parcels_input(time,date_ref,lon,lat,mask,u,v,angle,infile)


def common_time_axis(infile1,infile2,date_ref,outfile):
    # infile2 parcels data gets interpolated on the infile1 time axis
    # and written to outfile
    from scipy.interpolate import interp1d
    
    # get the data
    nc_id1 = Dataset(infile1, 'r')
    time1 = nc_id1.variables['time'][:]
    del nc_id1
    nc_id2 = Dataset(infile2, 'r')
    time2 = nc_id2.variables['time'][:]
    lon = nc_id2.variables['lon'][:]
    lat = nc_id2.variables['lat'][:]
    mask = nc_id2.variables['mask'][:]
    angle = nc_id2.variables['angle'][:]
    u2 = nc_id2.variables['u'][:]
    v2 = nc_id2.variables['v'][:]
    del nc_id2
    
    # do the interpolation
    f_u = interp1d(time2, u2, axis=0)
    f_v = interp1d(time2, v2, axis=0)
    #
    u1=f_u(np.ma.getdata(time1))
    v1=f_v(np.ma.getdata(time1))
        
    write_parcels_input(time1,date_ref,lon,lat,mask,u1,v1,angle,outfile)
    
def define_particles(infile,date_start,date_end,dt_part,npart_dt,lon_part,lat_part):
    
    # infile - input file used to define the fieldset for the run - this is what defines the ref time for the particle simulation
    nc_id = Dataset(infile, 'r')
    time0 = nc_id.variables['time'][0]
    t_unit_in = nc_id.variables['time'].units # carried over from original croco netcdf
    t_cal_in = nc_id.variables['time'].calendar
    del nc_id
    
    # get the particle release start and end times in seconds since time0 - units for the parcels output netcdf
    date0=num2date(time0,t_unit_in,calendar=t_cal_in)
    t_unit_part='seconds since '+str(date0) # units for the parcels output netcdf
    time_start=date2num(date_start,units=t_unit_part,calendar=t_cal_in)
    time_end=date2num(date_end,units=t_unit_part,calendar=t_cal_in)
    
    # generate arrays of lon,lat,time
    lon_out=[]
    lat_out=[]
    time_out=[]
    time_now=time_start
    while(time_now<=time_end):
        lon_out=np.append(lon_out,lon_part* np.ones(npart_dt))
        lat_out=np.append(lat_out,lat_part* np.ones(npart_dt))
        time_out=np.append(time_out,time_now* np.ones(npart_dt))
        time_now += dt_part.total_seconds()
        
    return lon_out,lat_out,time_out

def define_Kh(infile,Kh):
    # create a (tdim,ydim,xdim) array filled with Kh
    # We make Kh over land zero to prevent diffusion of particles inland,
    # which is clearly undesirable (this ocurred in initial tests)
    nc_id = Dataset(infile, 'r')
    mask = nc_id.variables['mask'][:]
    #ydim,xdim=np.shape(mask)
    tdim = nc_id.dimensions['time'].size
    del nc_id
    Kh=Kh*mask
    Kh=np.tile(Kh, (tdim,1,1))
    return Kh

#if __name__ == "__main__":
    
    # # time origin (not written to the croco output file)
    # date_ref=datetime(2000,1,1,0,0,0)
    # # define file names
    # grdfile='../grd.nc'
    # avgfile='../avg_surf_20210113.nc'
    # blkfile='../blk_GFS_20210113.nc'
    
    # # generate the file to force parcels using croco output surface currents
    # outfile_curr='parcels_input_curr.nc'
    # #make_curr_surf(grdfile,avgfile,outfile_curr,date_ref)
    
    # # generate the file to force parcels using croco input winds
    # outfile_wind='parcels_input_wind.nc'
    # frac=0.03 # 3% of the wind speed used to advect surface particles
    # rot=10 # particle advection due to wind is at an angle of 10 deg to the 10 m wind direction
    #        # positive angle is anticlockwise rotation i.e. to the left which is what we want in the southern hemisphere
    # make_wind_blk(grdfile,blkfile,outfile_wind,date_ref,frac,rot)
    
    # #outfile_wind_commontime='parcels_input_wind_commontime.nc'
    # common_time_axis(outfile_curr,outfile_wind,date_ref,outfile_wind)
    
