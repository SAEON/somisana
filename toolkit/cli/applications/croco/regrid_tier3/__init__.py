import xarray as xr
import numpy as np
from lib.log import log
import os
from datetime import timedelta, datetime
import cli.applications.croco.postprocess as post
import subprocess
from scipy import interpolate
import matplotlib.path as mplPath

def regrid_tier3(args):
    
    input = os.path.abspath(args.input)
    output = os.path.abspath(args.output)
    spacing = args.spacing
    log("Running CROCO output re-gridding (tier3)")
    log("CONFIG::input", input)
    log("CONFIG::spacing", spacing)
    log("CONFIG::output", output)
    
    log("Extracting the tier 2 re-gridded model output")
    ds = xr.open_dataset(input)   
    zeta_in=ds.zeta.values     
    temp_in=ds.temp.values
    salt_in=ds.salt.values
    u_in=ds.u.values
    v_in=ds.v.values
    depth=ds.depth.values
    lon_rho=ds.lon_rho.values
    lat_rho=ds.lat_rho.values  
    Nt,Nz,Ny,Nx=np.shape(temp_in)
    lon_rho_1d=np.ravel(lon_rho)
    lat_rho_1d=np.ravel(lat_rho)
    lonlat_input=np.array([lon_rho_1d,lat_rho_1d]).T # input for griddata function later
    
    log("Generating the regular horizontal output grid")
    # get the model boundary polygon
    lon_boundary = np.hstack((lon_rho[0:, 0], lon_rho[-1, 1:-1],
                     lon_rho[-1::-1, -1], lon_rho[0, -2::-1]))
    lat_boundary = np.hstack((lat_rho[0:, 0], lat_rho[-1, 1:-1],
                     lat_rho[-1::-1, -1], lat_rho[0, -2::-1]))
    #
    # find the corners of the output regular grid (just big enough to cover the model domain)
    spacing=float(spacing)
    lon_min=np.floor(np.min(lon_boundary)/spacing)*spacing
    lon_max=np.ceil(np.max(lon_boundary)/spacing)*spacing
    lat_min=np.floor(np.min(lat_boundary)/spacing)*spacing
    lat_max=np.ceil(np.max(lat_boundary)/spacing)*spacing
    #
    # generate the regular grid
    Nlon=int(np.rint((lon_max-lon_min)/spacing))+1
    Nlat=int(np.rint((lat_max-lat_min)/spacing))+1
    lon_out=np.linspace(lon_min,lon_max,num=Nlon,endpoint=True)
    lat_out=np.linspace(lat_min,lat_max,num=Nlat,endpoint=True)
    lon_out_grd,lat_out_grd=np.meshgrid(lon_out,lat_out) 
    #
    # get a mask for the output grid which tells us which points are inside the CROCO model grid
    poly_boundary=mplPath.Path(np.array([lon_boundary,lat_boundary]).T)
    mask_out=np.zeros_like(lon_out_grd)
    for y in np.arange(Nlat):
        for x in np.arange(Nlon):
            if poly_boundary.contains_point((lon_out_grd[y,x],lat_out_grd[y,x])):
                mask_out[y,x]=1
            else:
                mask_out[y,x]=np.nan
    
    log("Interpolating the model output onto the regular horizontal output grid")
    # set up output arrays
    zeta_out=np.zeros((Nt,Nlat,Nlon))
    temp_out=np.zeros((Nt,Nz,Nlat,Nlon))
    salt_out=np.zeros((Nt,Nz,Nlat,Nlon))
    u_out=np.zeros((Nt,Nz,Nlat,Nlon))
    v_out=np.zeros((Nt,Nz,Nlat,Nlon))
    
    # interpolate data onto regular grid for every depth level
    # specifically using 'nearest' method to make it easier to work with missing values
    # the output grid should be sufficiently high resolution for this
    # but this output is purely for visual effect anyway so no biggy
    for t in np.arange(Nt):
        zeta_out[t,::] = interpolate.griddata(lonlat_input, np.ravel(zeta_in[t,::]) , (lon_out_grd, lat_out_grd), method='nearest')*mask_out
        for n in np.arange(Nz):
            temp_out[t,n,::] = interpolate.griddata(lonlat_input, np.ravel(temp_in[t,n,::]) , (lon_out_grd, lat_out_grd), method='nearest')*mask_out
            salt_out[t,n,::] = interpolate.griddata(lonlat_input, np.ravel(salt_in[t,n,::]) , (lon_out_grd, lat_out_grd), method='nearest')*mask_out
            u_out[t,n,::] = interpolate.griddata(lonlat_input, np.ravel(u_in[t,n,::]) , (lon_out_grd, lat_out_grd), method='nearest')*mask_out
            v_out[t,n,::] = interpolate.griddata(lonlat_input, np.ravel(v_in[t,n,::]) , (lon_out_grd, lat_out_grd), method='nearest')*mask_out
            
    # Create new xarray dataset with selected variables
    log("Generating dataset")
    data_out = xr.Dataset(
        attrs={
            "description": "subset of CROCO output interpolated to constant depth levels (as per regrid_tier2) and also a constant horizontal grid. u,v data are rotated to be east,north components (as per regrid_tier1).",
            "model_name": ds.model_name,
            "run_date": ds.run_date,
        },
        data_vars={
            "zeta": xr.Variable(
                ["time", "latitude", "longitude"],
                zeta_out,
                {
                    "long_name": "averaged free-surface",
                    "units": "meter",
                    "standard_name": "sea_surface_height",                 
                },                
            ),
            "temp": xr.Variable(
                ["time", "depth", "latitude", "longitude"],
                temp_out,
                {
                    "long_name": "averaged potential temperature",
                    "units": "Celsius",
                    "standard_name": "sea_water_potential_temperature",                  
                },
            ),
            "salt": xr.Variable(
                ["time", "depth", "latitude", "longitude"],
                salt_out,
                {
                    "long_name": "averaged salinity",
                    "units": "PSU",
                    "standard_name": "sea_water_salinity",                  
                },
            ),
            "u": xr.Variable(
                ["time", "depth", "latitude", "longitude"],
                u_out,
                {
                    "long_name": "Eastward velocity",
                    "units": "meters per second",
                    "standard_name": "eastward_sea_water_velocity",
                },
            ),
            "v": xr.Variable(
                ["time", "depth", "latitude", "longitude"],
                v_out,
                {
                    "long_name": "Northward velocity",
                    "units": "meters per second",
                    "standard_name": "northward_sea_water_velocity",
                },
            ),
        },
        coords={
            "longitude": xr.Variable(
                ["longitude"],
                lon_out,
                {
                    "long_name": "Longitude",
                    "units": "degrees_east" ,
                    "standard_name": "longitude",
                },
            ),            
            "latitude": xr.Variable(
                ["latitude"],
                lat_out,
                {
                    "long_name": "Latitude",
                    "units": "degrees_west" ,
                    "standard_name": "latitude",
                },
            ),
            "time": xr.Variable(
                ["time"],
                ds.time.values,
                {"description": "time"},
            ),
            "depth": xr.Variable(
                ["depth"],
                ds.depth.values,
                {
                    "long_name": "water depth from free surface",
                    "units": "meter",
                    "postive": "down",
                    "standard_name": "depth",
                },
            ),
        },
    )

    encoding = {
        "zeta": {"dtype": "float32"},
        "temp": {"dtype": "float32"},
        "salt": {"dtype": "float32"},
        "u": {"dtype": "float32"},
        "v": {"dtype": "float32"},
        "depth": {"dtype": "float32"},
        "longitude": {"dtype": "float32"},
        "latitude": {"dtype": "float32"},
        "time": {"dtype": "i4"},
        
    }

    log("Writing NetCDF file")
    data_out.to_netcdf(output, encoding=encoding, mode="w")

    subprocess.call(["chmod", "-R", "775", output])
    
    ds.close()
    
    log("Done!")
