import os
import xarray as xr
from lib.log import log
from natsort import natsorted
import pandas as pd
import numpy as np
from glob import glob
from cli.applications.mhw.params import OISST_CACHE
from cli.applications.mhw.detect.ecjoliver_mhw_source import (
    detect as detect_mhw_original_fn,
)


def open_dataset(file):
    try:
        ds = xr.open_dataset(file)
    except:
        print(f"Failed to open file: {file}")
        return None
    ds.close()
    return file


def detect(args):
    log("Running MHW detect")
    output = os.path.abspath(args.output)
    domain = [float(x) for x in args.domain.split(",")]
    [min_long, max_long, min_lat, max_lat] = domain
    oisst_cache = os.path.abspath(args.oisst_cache) if args.oisst_cache else OISST_CACHE
    log("Using bulk OISST cache", oisst_cache)

    # Files are cached with domain information in the name
    # If multiple domains are cached we want to be sure to only use
    # files cached for this domain
    # TODO - would be better if a single EEZ cache was used
    cache_identifier = "".join(str(v) for v in domain)

    # Selecting files in folder
    datasets = [
        ds
        for ds in (
            open_dataset(file)
            for file in natsorted(
                glob(oisst_cache + "/*{id}.nc".format(id=cache_identifier))
            )
        )
        if ds is not None
    ]

    log("Fond OISST cache", len(datasets), "items NetCDF files found")

    #### RUN THE SCRIPT ####

    with xr.open_mfdataset(datasets, parallel=True) as ds:
        # TODO - this is for future reference when we want to subset from a larger cached domain
        ds = ds.sel(lat=slice(min_lat, max_lat), lon=slice(min_long, max_long))
        ds = ds.drop_vars("zlev")
        ds = np.squeeze(ds)
        log("Merged cached dataset opened!")

        sst = ds["sst"].values
        time = ds.time
        t_ordinal = np.array([pd.to_datetime(x).toordinal() for x in ds.time.values])

        # Find dimensions of sst variable to reproduce the netcdf output file
        t_dim = np.shape(sst)[0]  # Time dim
        rows = np.shape(sst)[1]  # Number of rows
        cols = np.shape(sst)[2]  # Number of columns

        # Creating empty array for output netcdf
        climatology = np.zeros([t_dim, rows, cols])  # Climatology values of MHW
        threshold = np.zeros(
            [t_dim, rows, cols]
        )  # Threshold used to determine if a MHW occurred
        MHW = np.zeros(
            [t_dim, rows, cols]
        )  # Creating a variable recording if MHW present or absent at each grid cell

        # Define the mapping from converting string values to numeric values within the loop
        mapping = {"Moderate": 1, "Strong": 2, "Severe": 3, "Extreme": 4}

        # Loop through the SST values (3D: lon/lat/time)
        log(f"Running detection script on grid, size ({rows}, {cols})")
        for x in np.arange(rows):
            # number of columns
            for y in np.arange(cols):
                log(
                    f"Calculating cell [{x}, {y}] ({(x + 1) * (y + 1)} / {rows*cols} total points)"
                )
                # IF a land value threshold climatology and MHW is filled with nans
                if np.all(np.isnan(sst[:, x, y])):
                    climatology[:, x, y] = np.full(t_dim, np.nan)
                    threshold[:, x, y] = np.full(t_dim, np.nan)
                    MHW[:, x, y] = np.full(t_dim, np.nan)

                # ELSE detect MHWs
                else:
                    # Calculate mhw with ecjoliver script (https://github.com/ecjoliver/marineHeatWaves)
                    mhw_temp = detect_mhw_original_fn(t_ordinal, sst[:, x, y])

                    # Extracting climatology and threshold from diction created by script
                    climatology_tmp = mhw_temp[1]["seas"]
                    threshold_tmp = mhw_temp[1]["thresh"]

                    # Extracting time indices (start and end) and category of defined MHW at grid cell (x,y)
                    index_start = mhw_temp[0]["index_start"]
                    index_end = mhw_temp[0]["index_end"]
                    category = mhw_temp[0]["category"]

                    # Fill in the time indices as only start and end provided
                    # Create empty lists
                    mhw_index = []
                    mhw_category = []

                    # Looping through all the time start time indices detected
                    for i in np.arange(len(index_start)):
                        # Filling indices with np.arange(start,end,step)
                        index_tmp = np.arange(index_start[i], index_end[i] + 1)
                        # Add corresponding category to each index (the category are strings)
                        category_tmp = np.repeat(category[i], len(index_tmp))

                        # Replace the string values with mapped values category 1-4 instead of 'moderate' to 'extreme'
                        # function detect from (https://github.com/ecjoliver/marineHeatWaves) outputs the category as strings
                        category_num_tmp = np.vectorize(mapping.get)(category_tmp)

                        # Adding the indices and categories to the empty lists created
                        mhw_index.append(index_tmp)
                        mhw_category.append(category_num_tmp)

                    # Create empty array full length of tim dimension
                    mhw_detection_full = np.zeros(t_dim)
                    # Using the indices of MHW events full the category values (1-4) at the correct index
                    mhw_detection_full[np.concatenate(mhw_index)] = np.concatenate(
                        mhw_category
                    )

                    # Fill the variables one grid point at a time
                    climatology[:, x, y] = climatology_tmp
                    threshold[:, x, y] = threshold_tmp
                    MHW[:, x, y] = mhw_detection_full

        #### OUTPUT ####
        ds_save = xr.Dataset(
            {
                "threshold": (["time_leap", "latitude", "longitude"], climatology),
                "climatology": (["time", "latitude", "longitude"], threshold),
                "MHW": (["time", "latitude", "longitude"], MHW),
                "sst": (["time", "latitude", "longitude"], sst),
            },
            coords={
                "latitude": (["latitude"], ds.lat.values),
                "longitude": (["longitude"], ds.lon.values),
                "time": (["time"], time.values),
            },
        )
        ds_save.to_netcdf(output)

    print(
        """Marine Heat Wave events saved to {filename}""".format(filename=args.output)
    )
