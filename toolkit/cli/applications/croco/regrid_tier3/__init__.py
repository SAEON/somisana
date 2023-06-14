import xarray as xr
import numpy as np
from lib.log import log
from dask import delayed
import os
import dask
import dask.array as da
from lib.resource_stats import get_memory_usage
import subprocess
from scipy import interpolate
import matplotlib.path as mplPath


def regrid_tier3(args):
    input = os.path.abspath(args.input)
    output = os.path.abspath(args.output)
    spacing = float(args.spacing)
    log("Running CROCO output regridding (tier3)")
    log("CONFIG::input", input)
    log("CONFIG::output", output)
    log("CONFIG::spacing", spacing, "degrees")

    log("Extracting the tier 2 re-gridded model output")
    with xr.open_dataset(input) as ds:
        zeta_in = ds.zeta.values
        temp_in = ds.temp.values
        salt_in = ds.salt.values
        u_in = ds.u.values
        v_in = ds.v.values
        depth = ds.depth.values
        lon_rho = ds.lon_rho.values
        lat_rho = ds.lat_rho.values
        Nt, Nz, Ny, Nx = np.shape(temp_in)
        lon_rho_1d = np.ravel(lon_rho)
        lat_rho_1d = np.ravel(lat_rho)

        # input for griddata function later
        lonlat_input = np.array([lon_rho_1d, lat_rho_1d]).T

        log("Generating the regular horizontal output grid")
        # get the model boundary polygon
        lon_boundary = np.hstack(
            (lon_rho[0:, 0], lon_rho[-1, 1:-1], lon_rho[-1::-1, -1], lon_rho[0, -2::-1])
        )
        lat_boundary = np.hstack(
            (lat_rho[0:, 0], lat_rho[-1, 1:-1], lat_rho[-1::-1, -1], lat_rho[0, -2::-1])
        )

        # find the corners of the output regular grid (just big enough to cover the model domain)
        lon_min = np.floor(np.min(lon_boundary) / spacing) * spacing
        lon_max = np.ceil(np.max(lon_boundary) / spacing) * spacing
        lat_min = np.floor(np.min(lat_boundary) / spacing) * spacing
        lat_max = np.ceil(np.max(lat_boundary) / spacing) * spacing

        # generate the regular grid
        Nlon = int(np.rint((lon_max - lon_min) / spacing)) + 1
        Nlat = int(np.rint((lat_max - lat_min) / spacing)) + 1
        lon_out = np.linspace(lon_min, lon_max, num=Nlon, endpoint=True)
        lat_out = np.linspace(lat_min, lat_max, num=Nlat, endpoint=True)
        lon_out_grd, lat_out_grd = np.meshgrid(lon_out, lat_out)

        # get a mask for the output grid which tells us which points are inside the CROCO model grid
        poly_boundary = mplPath.Path(np.array([lon_boundary, lat_boundary]).T)
        mask_out = np.zeros_like(lon_out_grd)
        for y in np.arange(Nlat):
            for x in np.arange(Nlon):
                if poly_boundary.contains_point((lon_out_grd[y, x], lat_out_grd[y, x])):
                    mask_out[y, x] = 1
                else:
                    mask_out[y, x] = np.nan

        log("Interpolating the model output onto the regular horizontal output grid")

        @delayed
        def compute_2d_chunk(t, variable, method="nearest"):
            return (
                interpolate.griddata(
                    lonlat_input,
                    np.ravel(variable[t, ::]),
                    (lon_out_grd, lat_out_grd),
                    method,
                )
                * mask_out
            )

        @delayed
        def compute_3d_chunk(t, variable, n, method="nearest"):
            return (
                interpolate.griddata(
                    lonlat_input,
                    np.ravel(variable[t, n, ::]),
                    (lon_out_grd, lat_out_grd),
                    method,
                )
                * mask_out
            )

        # Separate lists for each time step
        zeta_out = []
        temp_out_time = []
        salt_out_time = []
        u_out_time = []
        v_out_time = []

        for t in np.arange(Nt):
            # Lists for each depth level
            temp_out_depth = []
            salt_out_depth = []
            u_out_depth = []
            v_out_depth = []

            zeta_out.append(
                da.from_delayed(
                    compute_2d_chunk(t, zeta_in),
                    shape=(Nlat, Nlon),
                    dtype=float,
                )
            )

            for n in np.arange(Nz):
                log(
                    f"Timestep {str(t+1).zfill(3)}/{Nt}. Depth {str(np.round(depth[n]).astype(int)).zfill(5)}m (lvl {str(n+1).zfill(2)}/{Nz}). Memory usage: {get_memory_usage()}"
                )
                temp_out_depth.append(
                    da.from_delayed(
                        compute_3d_chunk(t, temp_in, n),
                        shape=(Nlat, Nlon),
                        dtype=float,
                    )
                )
                salt_out_depth.append(
                    da.from_delayed(
                        compute_3d_chunk(t, salt_in, n),
                        shape=(Nlat, Nlon),
                        dtype=float,
                    )
                )
                u_out_depth.append(
                    da.from_delayed(
                        compute_3d_chunk(t, u_in, n),
                        shape=(Nlat, Nlon),
                        dtype=float,
                    )
                )
                v_out_depth.append(
                    da.from_delayed(
                        compute_3d_chunk(t, v_in, n),
                        shape=(Nlat, Nlon),
                        dtype=float,
                    )
                )
            
            # Stack the depth dimension and append to the time list
            temp_out_time.append(da.stack(temp_out_depth, axis=0))
            salt_out_time.append(da.stack(salt_out_depth, axis=0))
            u_out_time.append(da.stack(u_out_depth, axis=0))
            v_out_time.append(da.stack(v_out_depth, axis=0))

        # Stack the time dimension
        zeta_out = da.stack(zeta_out, axis=0)
        temp_out = da.stack(temp_out_time, axis=0)
        salt_out = da.stack(salt_out_time, axis=0)
        u_out = da.stack(u_out_time, axis=0)
        v_out = da.stack(v_out_time, axis=0)

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
                        "units": "degrees_east",
                        "standard_name": "longitude",
                    },
                ),
                "latitude": xr.Variable(
                    ["latitude"],
                    lat_out,
                    {
                        "long_name": "Latitude",
                        "units": "degrees_west",
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

        log("Generating NetCDF data")
        write_op = data_out.to_netcdf(
            output,
            encoding={
                "zeta": {"dtype": "float32"},
                "temp": {"dtype": "float32"},
                "salt": {"dtype": "float32"},
                "u": {"dtype": "float32"},
                "v": {"dtype": "float32"},
                "depth": {"dtype": "float32"},
                "longitude": {"dtype": "float32"},
                "latitude": {"dtype": "float32"},
                "time": {"dtype": "i4"},
            },
            mode="w",
            compute=False,
        )

        log("Writing NetCDF file")
        dask.compute(write_op)

        subprocess.call(["chmod", "-R", "775", output])
        log("Done!")
