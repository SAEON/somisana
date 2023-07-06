import os
import xarray as xr
from lib.log import log
from lib.resource_stats import get_memory_usage
from natsort import natsorted
import pandas as pd
import numpy as np
from glob import glob
from cli.applications.mhw.params import OISST_CACHE
from cli.applications.mhw.detect.ecjoliver_mhw_source import (
    detect as detect_mhw_original_fn,
)


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
    files = natsorted(glob(oisst_cache + "/*{id}.nc".format(id=cache_identifier)))

    log(f"Found OISST cache ({len(files)} files)")

    #### RUN THE SCRIPT ####

    # Open the daily SST .nc files, and concatenate them
    # to create a single Xarray dataset (containing each day)
    with xr.open_mfdataset(files, engine="netcdf4", combine="by_coords",  chunks={'lat': 10, 'lon': 10}, parallel=True) as ds:
        ds = ds.sel(lat=slice(min_lat, max_lat), lon=slice(min_long, max_long))
        ds = ds.drop_vars("zlev")
        ds = np.squeeze(ds)
        log("Merged cached dataset opened!")

        # sst is a 3D array of temperature values [time, x, y]
        sst = ds["sst"].values
        time = ds.time
        t_ordinal = np.array([pd.to_datetime(x).toordinal() for x in ds.time.values])

        # Find dimensions of sst variable to reproduce the netcdf output file
        t_dim_limit = 365  # Time dim (set to 365 save a year with of data save memory)
        t_dim = np.shape(sst)[0]
        rows = np.shape(sst)[1]  # Number of rows
        cols = np.shape(sst)[2]  # Number of columns

        # Creating empty array for output netcdf
        climatology = np.zeros([t_dim_limit, rows, cols])  # Climatology values of MHW
        threshold = np.zeros(
            [t_dim_limit, rows, cols]
        )  # Threshold used to determine if a MHW occurred
        MHW = np.zeros(
            [t_dim_limit, rows, cols]
        )  # Creating a variable recording if MHW present or absent at each grid cell

        # Define the mapping from converting string values to numeric values within the loop
        mapping = {"Moderate": 1, "Strong": 2, "Severe": 3, "Extreme": 4}

        # Loop through the SST values (3D: lon/lat/time)
        log("Running detection script on grid")
        for x in np.arange(rows):
            # number of columns
            for y in np.arange(cols):
                log(
                    f"Calculating cell [{x + 1}, {y + 1}] / [{rows}, {cols}]). Memory usage {get_memory_usage()}"
                )
                # IF a land value threshold climatology and MHW is filled with nans
                if np.all(np.isnan(sst[:, x, y])):
                    climatology[:, x, y] = np.full(t_dim_limit, np.nan)
                    threshold[:, x, y] = np.full(t_dim_limit, np.nan)
                    MHW[:, x, y] = np.full(t_dim_limit, np.nan)

                # ELSE detect MHWs
                else:
                    # Calculate mhw with ecjoliver script (https://github.com/ecjoliver/marineHeatWaves)
                    mhw_temp = detect_mhw_original_fn(t_ordinal, sst[:, x, y])

                    # mhw_temp[0] => Dictionary of climatology related info
                    # mhw_temp[1] => Dictionary of MHW related output

                    # Extracting climatology and threshold from diction created by script
                    climatology_tmp = mhw_temp[1][
                        "seas"
                    ]  # seas => climatology at this grid point
                    threshold_tmp = mhw_temp[1][
                        "thresh"
                    ]  # Thresholds of each timestep at this grid point

                    # Extracting time indices (start and end) and category of defined MHW at grid cell (x,y)

                    index_start = mhw_temp[0]["index_start"]
                    index_end = mhw_temp[0]["index_end"]
                    category = mhw_temp[0]["category"]

                    # Fill in the time indices as only start and end provided
                    # Create empty lists
                    mhw_index = []
                    mhw_category = []

                    # The output of the MHW script includes the start / end date3s
                    # of events. But it's better to:
                    #  (1) Have this information per timestep
                    #  (2) Change categories into numbers for easier plotting
                    # Which is what this code does
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

                    # Fill the variables one grid point at a time (save only last 365 days)
                    climatology[:, x, y] = climatology_tmp[-t_dim_limit:]
                    threshold[:, x, y] = threshold_tmp[-t_dim_limit:]
                    MHW[:, x, y] = mhw_detection_full[-t_dim_limit:]

        #### OUTPUT ####
        log("Saving output")
        ds_save = xr.Dataset(
            {
                "threshold": (["time_leap", "latitude", "longitude"], climatology),
                "climatology": (["time", "latitude", "longitude"], threshold),
                "MHW": (["time", "latitude", "longitude"], MHW),
                "sst": (["time", "latitude", "longitude"], sst[-t_dim_limit:, :, :]),
            },
            coords={
                "latitude": (["latitude"], ds.lat.values),
                "longitude": (["longitude"], ds.lon.values),
                "time": (["time"], time[-t_dim_limit:].values),
            },
        )
        ds_save.to_netcdf(output)

    print(
        """Marine Heat Wave events saved to {filename}""".format(filename=args.output)
    )
