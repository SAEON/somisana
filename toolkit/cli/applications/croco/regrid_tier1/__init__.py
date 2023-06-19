import xarray as xr
import numpy as np
from lib.log import log
import os
from datetime import timedelta, datetime
import cli.applications.croco.postprocess as post
import subprocess

# We are hard coding the reference date here as all our CROCO output are
# represented in seconds from 1 Jan 2000). This is of course not generally true
# for all CROCO files
REFERENCE_DATE = datetime(2000, 1, 1, 0, 0, 0)


def regrid_tier1(args):
    id = args.id
    grid = os.path.abspath(args.grid)
    input = os.path.abspath(args.input)
    output = os.path.abspath(args.output)

    log("Running CROCO output regridding (tier1)")
    log("CONFIG::id", id)
    log("CONFIG::input", input)
    log("CONFIG::grid", grid)
    log("CONFIG::output", output)

    # Ensure the directory for the specified output exists
    os.makedirs(os.path.dirname(output), exist_ok=True)

    time_steps = post.get_time(input, REFERENCE_DATE)

    # Get the run_date from the CROCO output NetCDF file
    run_date = time_steps[int(len(time_steps) / 2) - 1].strftime(
        "%Y%m%d"
    )  # TODO: rather make this an input - what if in future the hindcast and forecast durations aren't equal
    log("CONFIG::run_date", run_date)

    log("Extracting the model output variables we need")
    with xr.open_dataset(input) as ds:
        eta_rho = ds.eta_rho  # y index-based grid position
        xi_rho = ds.xi_rho  # x index-based grid position
        lon_rho = ds.lon_rho
        lat_rho = ds.lat_rho
        s_rho = ds.s_rho
        h_ = ds.h
        temp_ = ds.temp
        salt_ = ds.salt
        ssh_ = ds.zeta

    # These have clever masking
    h = post.get_var(input, grid, "h")
    temp = post.get_var(input, grid, "temp")
    salt = post.get_var(input, grid, "salt")
    ssh = post.get_var(input, grid, "zeta")

    log("Regridding and rotating u/v")
    u, v = post.get_uv(input, grid)

    # get the depth levels of the sigma layers
    log("Computing depth of sigma levels")
    depth = post.get_depths(input, grid)

    # Create new xarray dataset with selected variables
    log("Generating dataset")
    data_out = xr.Dataset(
        attrs={
            "description": "subset of CROCO output with u,v data regridded to the rho grid and rotated to be east,north components. A new 'depth' variable is added to provide the depths of the sigma levels in metres",
            "model_name": id,
            "run_date": run_date,
        },
        data_vars={
            "zeta": xr.Variable(["time", "eta_rho", "xi_rho"], ssh, ssh_.attrs),
            "temp": xr.Variable(
                ["time", "s_rho", "eta_rho", "xi_rho"], temp, temp_.attrs
            ),
            "salt": xr.Variable(
                ["time", "s_rho", "eta_rho", "xi_rho"], salt, salt_.attrs
            ),
            "u": xr.Variable(
                ["time", "s_rho", "eta_rho", "xi_rho"],
                u,
                {
                    "long_name": "Eastward velocity",
                    "units": "meters per second",
                    "standard_name": "eastward_sea_water_velocity",
                },
            ),
            "v": xr.Variable(
                ["time", "s_rho", "eta_rho", "xi_rho"],
                v,
                {
                    "long_name": "Northward velocity",
                    "units": "meters per second",
                    "standard_name": "northward_sea_water_velocity",
                },
            ),
            "depth": xr.Variable(
                ["time", "s_rho", "eta_rho", "xi_rho"],
                depth,
                {
                    "long_name": "Depth of sigma levels of the rho grid (centred in grid cells)",
                    "units": "meter",
                    "positive": "up",
                },
            ),
            "h": xr.Variable(["eta_rho", "xi_rho"], h, h_.attrs),
        },
        coords={
            "eta_rho": xr.Variable(["eta_rho"], eta_rho.values, eta_rho.attrs),
            "xi_rho": xr.Variable(["xi_rho"], xi_rho.values, xi_rho.attrs),
            "lon_rho": xr.Variable(
                ["eta_rho", "xi_rho"],
                lon_rho.values,
                lon_rho.attrs,
            ),
            "lat_rho": xr.Variable(
                ["eta_rho", "xi_rho"],
                lat_rho.values,
                lat_rho.attrs,
            ),
            "s_rho": xr.Variable(["s_rho"], s_rho.values, s_rho.attrs),
            "time": xr.Variable(
                ["time"],
                time_steps,
                {"description": "time"},
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
        "s_rho": {"dtype": "float32"},
        "time": {"dtype": "i4"},
    }

    log("Writing NetCDF file")
    data_out.to_netcdf(output, encoding=encoding, mode="w")

    subprocess.call(["chmod", "-R", "775", output])

    log("Done!")
