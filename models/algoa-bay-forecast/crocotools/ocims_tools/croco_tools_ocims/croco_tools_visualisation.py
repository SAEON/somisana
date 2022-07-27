#! /usr/bin/env python
#
# functions to view croco output
#

import numpy as np
from netCDF4 import Dataset

def get_var_surf(hisfile,gridfile,tindex,var):
    # get a variable on the rho grid from a croco surface output file
    nc_id_grd = Dataset(gridfile, 'r')
    latr = nc_id_grd.variables['lat_rho'][:]
    lonr = nc_id_grd.variables['lon_rho'][:]
    maskr = nc_id_grd.variables['mask_rho'][:]
    del nc_id_grd
    # get the data
    nc_id_avg = Dataset(hisfile, 'r')
    var_data = nc_id_avg.variables[var][tindex,:,:]
    del nc_id_avg
    var_data[maskr==0]=np.nan
    
    return latr,lonr,var_data

def get_uv_surf(hisfile,gridfile,tindex,skp):
    # extract the u,v vector field from a croco surface output file
    #
    # hisfile - history or average surface output from croco
    # gridfile - grid file input to croco
    # tindex - time index to extract
    # skp - output is thinned to extract only every skp'th point
    
    # Extract the grid data
    # note we will write out the vector data to the psi grid
    # (this requires less interpolation of the u and v fields to get them onto 
    # a common grid than interpolating onto the rho grid. This is also the grid
    # provided to Parcels)
    nc_id_grd = Dataset(gridfile, 'r')
    latp = nc_id_grd.variables['lat_psi'][:]
    lonp = nc_id_grd.variables['lon_psi'][:]
    masku = nc_id_grd.variables['mask_u'][:]
    maskv = nc_id_grd.variables['mask_v'][:]
    angle = nc_id_grd.variables['angle'][:]
    del nc_id_grd
    #
    # get the u,v data
    nc_id_avg = Dataset(hisfile, 'r')
    u = nc_id_avg.variables['surf_u'][tindex,:,:]
    v = nc_id_avg.variables['surf_v'][tindex,:,:]
    del nc_id_avg
    #
    u[masku==0]=np.nan
    v[maskv==0]=np.nan
    #
    # interpolate u and v onto the psi grid
    up = 0.5*(u[:-1,:]+u[1:,:])
    vp = 0.5*(v[:,:-1]+v[:,1:])
    #
    # interpolate angle (on the rho grid), onto the psi grid
    angle = 0.5*(angle[:-1,:]+angle[1:,:]) # this gets it onto the v grid
    angle = 0.5*(angle[:,:-1]+angle[:,1:]) # and then onto the psi grid
    #
    # use angle to rotate the vectors to get them relative to TN
    cosa = np.cos(angle);
    sina = np.sin(angle);
    u = up*cosa - vp*sina;
    v = vp*cosa + up*sina;
    #
    # thin out the vectors
    latp=latp[0::skp,0::skp]
    lonp=lonp[0::skp,0::skp]
    u=u[0::skp,0::skp]
    v=v[0::skp,0::skp]
    #
        
    return latp,lonp,u,v
