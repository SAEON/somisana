import xarray as xr
import numpy as np
from lib.log import log
import os
from datetime import timedelta, datetime
import cli.applications.croco.postprocess as post
import subprocess

def regrid_tier2(args):
    
    input = os.path.abspath(args.input)
    output = os.path.abspath(args.output)
    depths = args.depths
    log("Running CROCO output re-gridding (tier2)")
    log("CONFIG::input", input)
    log("CONFIG::depths", depths)
    log("CONFIG::output", output)
    
    log("Extracting the tier 1 re-gridded model output")
    ds = xr.open_dataset(input)    
    depth_in=ds.depth.values    
    temp_in=ds.temp.values
    salt_in=ds.salt.values
    u_in=ds.u.values
    v_in=ds.v.values
    T,N,M,L=np.shape(depth_in)
    
    # set up the output arrays
    depth_out = np.array(depths.split(',')).astype(float)
    temp_out=np.zeros((T,len(depth_out),M,L))
    salt_out=temp_out.copy()
    u_out=temp_out.copy()
    v_out=temp_out.copy()
    
    log("Doing the vertical interpolation to the constant depth levels")
    for d, depth in enumerate(depth_out):
        if depth==0: # surace layer
            temp_out[:,d,:,:]=temp_in[:,N-1,:,:]
        elif depth==9999: # bottom layer
            temp_out[:,d,:,:]=temp_in[:,0,:,:]
        else:
            log("Depth = ", depth, " m")
            for t in np.arange(T):
                temp_out[t,d,:,:]=post.hlev(temp_in[t,::], depth_in[t,::], -1*depth)
                salt_out[t,d,:,:]=post.hlev(salt_in[t,::], depth_in[t,::], -1*depth)
                u_out[t,d,:,:]=post.hlev(u_in[t,::], depth_in[t,::], -1*depth)
                v_out[t,d,:,:]=post.hlev(v_in[t,::], depth_in[t,::], -1*depth)
    
    # Create new xarray dataset with selected variables
    log("Generating dataset")
    data_out = xr.Dataset(
        attrs={
            "description": "subset of CROCO output interpolated to constant depth levels. u,v data are regridded to the rho grid and rotated to be east,north components (as per regrid_tier1).",
            "model_name": ds.model_name,
            "run_date": ds.run_date,
        },
        data_vars={
            "zeta": xr.Variable(
                ["time", "eta_rho", "xi_rho"],
                ds.zeta.values,
                {
                    "long_name": "averaged free-surface",
                    "units": "meter",
                    "standard_name": "sea_surface_height",                 
                },                
            ),
            "temp": xr.Variable(
                ["time", "depth", "eta_rho", "xi_rho"],
                temp_out,
                {
                    "long_name": "averaged potential temperature",
                    "units": "Celsius",
                    "standard_name": "sea_water_potential_temperature",                  
                },
            ),
            "salt": xr.Variable(
                ["time", "depth", "eta_rho", "xi_rho"],
                salt_out,
                {
                    "long_name": "averaged salinity",
                    "units": "PSU",
                    "standard_name": "sea_water_salinity",                  
                },
            ),
            "u": xr.Variable(
                ["time", "depth", "eta_rho", "xi_rho"],
                u_out,
                {
                    "long_name": "Eastward velocity",
                    "units": "meters per second",
                    "standard_name": "eastward_sea_water_velocity",
                },
            ),
            "v": xr.Variable(
                ["time", "depth", "eta_rho", "xi_rho"],
                v_out,
                {
                    "long_name": "Northward velocity",
                    "units": "meters per second",
                    "standard_name": "northward_sea_water_velocity",
                },
            ),
            "h": xr.Variable(
                ["eta_rho", "xi_rho"],
                ds.h.values,
                {
                    "long_name": "bathymetry at RHO-points",
                    "units": "meter",
                    "standard_name": "model_sea_floor_depth_below_geoid",
                },
            ),
        },
        coords={
            "lon_rho": xr.Variable(
                ["eta_rho", "xi_rho"],
                ds.lon_rho.values,
                {
                    "long_name": "longitude of RHO-points",
                    "units": "degree_east" ,
                    "standard_name": "longitude",
                },
            ),            
            "lat_rho": xr.Variable(
                ["eta_rho", "xi_rho"],
                ds.lat_rho.values,
                {
                    "long_name": "latitude of RHO-points",
                    "units": "degree_west" ,
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
                depth_out,
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
        "h": {"dtype": "float32"},
        "lon_rho": {"dtype": "float32"},
        "lat_rho": {"dtype": "float32"},
        "time": {"dtype": "i4"},
        
    }

    log("Writing NetCDF file")
    data_out.to_netcdf(output, encoding=encoding, mode="w")

    subprocess.call(["chmod", "-R", "775", output])
    
    ds.close()
    
    log("Done!")

    