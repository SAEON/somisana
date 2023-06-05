import xarray as xr
import numpy as np
from lib.log import log
import os
from datetime import timedelta, datetime
from cli.applications.croco.postprocess import (
    z_levels,
    hour_rounder,
    uv2rho
)
import subprocess

# All dates in the CROCO output are represented
# in seconds from 1 Jan 2000 (i.e. the reference date)
REFERENCE_DATE = datetime(2000, 1, 1, 0, 0, 0)


# Model variables use the dimensions time (time from reference date),
# eta_rho (lat) and xi_rho (lon). We are changing eta_rho and xi_rho
# from grid points to real lat and lon data.


def regrid_tier1(args):
    id = args.id
    grid = os.path.abspath(args.grid)
    input = os.path.abspath(args.input)
    output = os.path.abspath(args.output)

    log("Running CROCO output re-gridding (tier1)")
    log("CONFIG::id", id)
    log("CONFIG::input", input)
    log("CONFIG::grid", grid)
    log("CONFIG::output", output)

    # Ensure the directory for the specified output exists
    os.makedirs(os.path.dirname(output), exist_ok=True)

    data = xr.open_dataset(input)
    data_grid = xr.open_dataset(grid)
    # Dimensions that need to be transformed
    time = data.time.values  # Time steps
    lon_rho = data.lon_rho.values  # Longitude (4326)
    lat_rho = data.lat_rho.values  # Latitude (4326)
    
    # get the land-sea mask
    mask_rho = data_grid.mask_rho.values
    mask_rho[np.where(mask_rho == 0)] = np.nan
    mask_u = data_grid.mask_u.values
    mask_u[np.where(mask_u == 0)] = np.nan
    mask_v = data_grid.mask_v.values
    mask_v[np.where(mask_v == 0)] = np.nan

    # Convert time to human readable
    time_steps = []
    for t in time:
        date_now = REFERENCE_DATE + timedelta(seconds=np.float64(t))
        # date_round = hour_rounder(date_now) # GF: I'd rather keep the croco dates as they are saved in the raw output
        time_steps.append(date_now)

    # Get the run_date from the CROCO output NetCDF file
    run_date = time_steps[119].strftime("%Y%m%d")
    log("CONFIG::run_date", run_date)

    # Variables used in the visualisations
    temperature = data.temp.values*mask_rho # it looks like numpy is clever enough to use the 2D mask on a 4D variable!
    salt = data.salt.values*mask_rho 
    ssh = data.zeta.values*mask_rho  # Sea-surface height
    u = data.u.values*mask_u  # grid-aligned u-velocity
    v = data.v.values*mask_v  # grid-aligned v-velocity 
    
    angle = data_grid.angle.values
    h = data_grid.h.values
    
    # Convert u and v current components to the rho grid and rotate to be eastward and northward components
    log("Regridding and rotating u/v model output variables")
    u_rho,v_rho = uv2rho(u,v,angle)
    
    # Variables used to calculate depth levels
    # CROCO uses these params to determine how to deform the grid
    s_rho = data.s_rho.values  # Vertical levels
    theta_s = data.theta_s
    theta_b = data.theta_b
    
    # Variables hard coded set during model configuration
    # Relative to each model
    # Critical depth. Convergence of surface layers with bottom layers due to grid squeezing
    hc = data.hc.values
    N = np.shape(data.s_rho)[0]
    type_coordinate = "rho"
    vtransform = (
        2 if data.VertCoordType == "NEW" else 1 if data.VertCoordType == "OLD" else -1
    )

    if vtransform == -1:
        raise Exception("Unexpected value for vtransform (" + vtransform + ")")

    # m_rho refers to the depth level in meters
    log("Converting sigma levels to depth in meters")
    m_rho = np.zeros(np.shape(temperature))
    for x in np.arange(np.size(temperature, 0)):
        depth_temp = z_levels(
            h, ssh[x, :, :], theta_s, theta_b, hc, N, type_coordinate, vtransform
        )
        m_rho[x, ::] = depth_temp

    # Create new xarray dataset with selected variables
    log("Generating dataset")
    data_out = xr.Dataset(
        attrs={
            "description": "CROCO output from algoa Bay model transformed lon/lat/depth/time",
            "model_name": id,
            "run_date": run_date,
        },
        data_vars={
            "temperature": xr.Variable(
                ["time", "depth", "lat", "lon"],
                temperature,
                {
                    "long_name": data.temp.long_name,
                    "units": data.temp.units,
                    "description": "Temperature at grid points",
                },
            ),
            "salt": xr.Variable(
                ["time", "depth", "lat", "lon"],
                salt,
                {
                    "long_name": data.salt.long_name,
                    "units": data.salt.units,
                    "description": "Salinity at grid points",
                },
            ),
            "u": xr.Variable(
                ["time", "depth", "lat", "lon"],
                u_rho,
                {
                    "long_name": "Eastward velocity",
                    "units": data.u.units,
                    "description": "Eastward component of horizontal velocity vector at grid points",
                },
            ),
            "v": xr.Variable(
                ["time", "depth", "lat", "lon"],
                v_rho,
                {
                    "long_name": "Northward velocity",
                    "units": data.v.units,
                    "description": "Northward component of horizontal velocity vector at grid points",
                },
            ),
            "m_rho": xr.Variable(
                ["time", "depth", "lat", "lon"],
                m_rho,
                {
                    "description": "Depth level of grid points in meters, centred in grid cells"
                },
            ),
            "h": xr.Variable(
                ["lat", "lon"],
                h,
                {
                    "long_name": data.h.long_name,
                    "units": data.h.units,
                    "description": "Bathymetry elevation at grid XY points",
                },
            ),
        },
        coords={
            "lon_rho": xr.Variable(
                ["lat", "lon"],
                lon_rho,
                {
                    "long_name": data.lon_rho.long_name,
                    "units": data.lon_rho.units,
                    "description": "Longitude coordinate values of curvilinear grid cells",
                },
            ),
            "lat_rho": xr.Variable(
                ["lat", "lon"],
                lat_rho,
                {
                    "long_name": data.lat_rho.long_name,
                    "units": data.lat_rho.units,
                    "description": "Latitude coordinate values of curvilinear grid cells",
                },
            ),
            "depth": xr.Variable(
                ["depth"], s_rho, {"description": "Depth levels (grid levels)"}
            ),
            "time": xr.Variable(
                ["time"],
                time_steps,
                {"description": "Time steps in hours"},
            ),
        },
    )

    encoding = {
        "temperature": {"dtype": "float32"},
        "salt": {"dtype": "float32"},
        "u": {"dtype": "float32"},
        "v": {"dtype": "float32"},
        "m_rho": {"dtype": "float32"},
        "lon_rho": {"dtype": "float32"},
        "lat_rho": {"dtype": "float32"},
        "depth": {"dtype": "u2", "_FillValue": 65535},
        "time": {"dtype": "i4"},
        "h": {"dtype": "float32"},
    }

    log("Writing NetCDF file")
    data_out.to_netcdf(output, encoding=encoding, mode="w")

    subprocess.call(["chmod", "-R", "775", output])

    log("Done!")
