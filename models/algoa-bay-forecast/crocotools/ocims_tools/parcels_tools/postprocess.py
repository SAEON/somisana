#! /usr/bin/env python
#
# a script to animate croco surface currents with parcels particles
#

from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
from matplotlib.animation import FuncAnimation
from netCDF4 import Dataset,num2date,date2num
import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
from datetime import timedelta, date, datetime
import sys

def get_uv_parcels_input(infile,tindex,skp):
    # extract the u,v vector field from a croco surface output file
    #
    # infile - parcels input file
    # gridfile - grid file input to croco
    # tindex - time index to extract
    # skp - output is thinned to extract only every skp'th point
    
    # Extract the grid data
    # note we will write out the vector data to the psi grid
    # (this requires less interpolation of the u and v fields to get them onto 
    # a common grid than interpolating onto the rho grid. This is also the grid
    # provided to Parcels)
    nc_id = Dataset(infile, 'r')
    latp = nc_id.variables['lat'][:]
    lonp = nc_id.variables['lon'][:]
    angle = nc_id.variables['angle'][:]
    # get the u,v data
    u = nc_id.variables['u'][tindex,:,:]
    v = nc_id.variables['v'][tindex,:,:]
    del nc_id
    #
    #u[masku==0]=np.nan
    #v[maskv==0]=np.nan
    #
    # use angle to rotate the vectors to get them relative to TN
    cosa = np.cos(angle);
    sina = np.sin(angle);
    ur = u*cosa - v*sina;
    vr = v*cosa + u*sina;
    #
    # thin out the vectors
    latp=latp[0::skp,0::skp]
    lonp=lonp[0::skp,0::skp]
    u=ur[0::skp,0::skp]
    v=vr[0::skp,0::skp]
    #
    return latp,lonp,u,v

def do_anim_algoa(infile1,infile2,parcels_file,lon_spill,lat_spill,fnames_lines,anim_file,anim_dates):
    
    # get the time of the parcels file
    nc_id = Dataset(parcels_file, 'r')
    times_part = nc_id.variables['time'][:]
    t_unit_part = nc_id.variables['time'].units
    t_cal_part = nc_id.variables['time'].calendar
    #dates_part=num2date(times_part,t_unit_part,calendar=t_cal_part)
    #
    # get the lon,lat data from the parcels file
    # hopefully reading this into memory isn't going to be a problem
    lons_part=nc_id.variables['lon'][:]
    lats_part=nc_id.variables['lat'][:]
    #
    del nc_id
        
    # get the time (should be the same for both infile1 and infile2)
    nc_id = Dataset(infile1, 'r')
    times_in = nc_id.variables['time'][:]
    t_unit_in = nc_id.variables['time'].units
    t_cal_in = nc_id.variables['time'].calendar
    dates_in=num2date(times_in,t_unit_in,calendar=t_cal_in)
    # convert these dates to seconds since the parcels file reference time
    times_in=date2num(dates_in,units=t_unit_part,calendar=t_cal_part)
    #
    del nc_id
    
    # convert the animation dates to seconds since the parcels file reference time
    times_anim = date2num(anim_dates,units=t_unit_part,calendar=t_cal_part)
    # now we have times_part, times_in and times_anim all in seconds since 
    # reference time of parcels output file
    
    # get the data for the first time-step to initiate the animation
    #
    # particle locations - using a hard equal to here which works as long as 
    # you line up the animation times with the defined parcels output times
    lon_part = lons_part[times_part == times_anim[0]]
    lat_part = lats_part[times_part == times_anim[0]]
    
    # get the current data
    step=4
    # find the appropraite first timestep (get the nearest index as it is not 
    # guarenteed that the current times are the same as the animation times)
    indx_curr=min(range(len(times_in)), key=lambda i: abs(times_anim[0]-times_in[i]))
    latp,lonp,u1,v1=get_uv_parcels_input(infile1,indx_curr,step)
    _,_,u2,v2=get_uv_parcels_input(infile2,indx_curr,step) # again, infile1 and infile2 are assumed to have the same time axis
    
    # # setup figure object
    fig = plt.figure(figsize=(12,6))
    ax = plt.axes(projection=ccrs.Mercator())
    ax.set_extent([25.55,26.55,-34.1,-33.65])
    ax.add_feature(cfeature.LAND, zorder=0, edgecolor='black')
    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                      linewidth=1, color='gray', alpha=0.5, linestyle=':')
    gl.left_labels = False
    gl.top_labels = False
    # add the vectors
    col_curr='b'
    col_wind='r'
    qv1=ax.quiver(lonp, latp, u1, v1, scale=10, transform=ccrs.PlateCarree(), color=col_curr)
    qv2=ax.quiver(lonp, latp, u2, v2, scale=10, transform=ccrs.PlateCarree(), color=col_wind)
    ax.quiverkey(qv1,0.8, 0.8, -0.5, '0.5 m s$^{-1}$', coordinates = 'figure', transform=ccrs.PlateCarree(), color=col_curr)
    ax.quiverkey(qv1,0.8, 0.75, -0.5, '', coordinates = 'figure', transform=ccrs.PlateCarree(), color=col_wind)
    ax.text(26.42, -33.705, 'surface current', fontsize=15, horizontalalignment='right', transform=ccrs.PlateCarree(), color=col_curr)
    ax.text(26.42, -33.735, 'wind drift', fontsize=15, horizontalalignment='right', transform=ccrs.PlateCarree(), color=col_wind) 
    
    # plot the anchorage areas
    for fname in fnames_lines:
        anchorage = pd.read_csv(fname)
        ax.plot(anchorage.lon,anchorage.lat, transform=ccrs.PlateCarree(),
                 color='k', linewidth=2, linestyle='dotted',)
        
    # add the particles
    scat = ax.scatter(lon_part,lat_part, transform=ccrs.PlateCarree(),color='k')
    # show the time
    time_lon=25.6; time_lat=-33.7
    tx=ax.text(time_lon, time_lat, str(anim_dates[0]),
             horizontalalignment='left', fontsize=15,
             transform=ccrs.PlateCarree())
    
    # plot the position of the spill

    ax.scatter(lon_spill,lat_spill, 150, transform=ccrs.PlateCarree(),marker='X',color='g')
    ax.text(lon_spill+0.018, lat_spill, 'spill location',color='g',
              horizontalalignment='left', fontsize=15, backgroundcolor='w', va='center',
              transform=ccrs.PlateCarree())
    
    def animate(i):
        indx_curr=min(range(len(times_in)), key=lambda j: abs(times_anim[i]-times_in[j]))
        _,_,u1,v1=get_uv_parcels_input(infile1,indx_curr,step)
        _,_,u2,v2=get_uv_parcels_input(infile2,indx_curr,step)
        qv1.set_UVC(u1,v1)
        qv2.set_UVC(u2,v2)
        tx.set_text(str(anim_dates[i]))
        
        lon_part = lons_part[times_part == times_anim[i]]
        lat_part = lats_part[times_part == times_anim[i]]
        scat.set_offsets(np.c_[lon_part,lat_part])
    
    anim = FuncAnimation(
        fig, animate, interval=100, frames=range(0,len(times_anim)-1)) 
    
    anim.save(anim_file, writer='imagemagick')

    plt.close(fig)

def date_array(date_start,date_end,dt):
    dates=[]
    date_now=date_start
    while date_now<=date_end:
        dates.append(date_now)
        date_now=date_now+dt
    return dates

if __name__ == "__main__":
    
    # summed advection from two files
    infile1='parcels_input_curr_20210222.nc'
    infile2='parcels_input_wind_20210222.nc'
    parcels_file='parcels_output_20210222.nc'
    anim_file='anim_particles_20210222_test.gif'
        
    anim_start = datetime(2021,2,22,0,0,0)
    anim_end = datetime(2021,2,26,0,0,0)
    anim_dt = timedelta(hours=1)
    #
    anim_dates=date_array(anim_start,anim_end,anim_dt)
    
    lon_spill = 25.75143
    lat_spill = -33.82751
    
    do_anim_algoa(infile1,infile2,parcels_file,lon_spill,lat_spill,anim_file,anim_dates)

