# Packages needed
import xarray as xr
import os
import pandas as pd
import numpy as np
from glob import glob
from natsort import natsorted

# Import script used to define MHW (https://github.com/ecjoliver/marineHeatWaves)
# from cli.applications.mhw.thresholds.climatology import detect


def calculate_daily_clim(mhw_bulk_cache, nc_mhw_output_path, domain):
    mhw_bulk_cache = os.path.abspath(mhw_bulk_cache)

    # Files for multiple domains may be cached - we want this one
    cache_identifier = "".join(str(v) for v in domain)

    # Selecting files in folder
    files = natsorted(glob(mhw_bulk_cache + "/*{id}.nc".format(id=cache_identifier)))

    # Importing data through loop saving memory (Seems like there is a issue with rolling means and xarray https://github.com/pydata/xarray/issues/3277 need to loop the load)
    # list_of_arrays = []
    # for file in files:
    #    try:
    #        ds = xr.open_dataset(file)
    #        list_of_arrays.append(np.squeeze(ds["sst"]))
    #    except:
    #        print("Unable to open NetCDF file", file)

    # sst_ds = xr.concat(list_of_arrays[0 : len(list_of_arrays)], dim="time")

    # Loading in netcdf using xarray open_mfdataset could be used as rolling mean no longer used
    sst_ds = xr.open_mfdataset(path_to_data + file_names)

    # Dropping empty dimesion zlev
    sst_ds = sst_ds.drop_vars("zlev")
    # Add a fill values as the rolling mean can't handle the land values
    # sst_ds = sst_ds.fillna(9999)

    # # loading lon and lat
    lon = sst_ds.lon.values
    lat = sst_ds.lat.values

    # Loading the temperature variable from OISST
    sst = sst_ds["sst"].values

    # Formatting time dimesion
    time = sst_ds.time

    # %% Detect Marine heat wave

    # Find dimensions of sst variable to reproduce the netcdf output file
    # Time dim
    t_dim = np.shape(sst)[0]
    # Number of rows
    rows = np.shape(sst)[1]
    # Number of columns
    cols = np.shape(sst)[2]

    # Creating empty array for output netcdf
    # Climatology values of MHW
    climatology = np.zeros([t_dim, rows, cols])
    # Threshold used to determine if a MHW occured
    threshold = np.zeros([t_dim, rows, cols])
    # Creating a variable recording if MHW present or absent at each grid cell
    MHW = np.zeros([t_dim, rows, cols])

    # Define the mapping from converting string values to numeric values within the loop
    mapping = {"Moderate": 1, "Strong": 2, "Severe": 3, "Extreme": 4}

    # loop through each grid cell in the sst matrix and caculate MHW over the entire time period
    # tqdm is just a timing package to see how long loop takes to complete can be removed

    # number of rows
    for x in np.arange(rows):
        # number of columns
        for y in np.arange(cols):
            # IF a land value threshold climatolgy and MHW is filled with nans
            if np.all(np.isnan(sst[:, x, y])):
                climatology_tmp = np.full(t_dim, np.nan)
                threshold_tmp = np.full(t_dim, np.nan)
                MHW_tmp = np.full(t_dim, np.nan)

            # ELSE detect MHWs
            else:
                # Calculate mhw with ecjoliver script (https://github.com/ecjoliver/marineHeatWaves)
                mhw_temp = detect(t_ordinal, sst[:, x, y])

                # Extracting climatology and threshold from diction created by script
                climatology_tmp = mhw_temp[1]["seas"]
                threshold_tmp = mhw_temp[1]["thresh"]

                # Extracting time indices (start and end) and category of defined MHW at grgid cell (x,y)
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
                    catergory_tmp = np.repeat(category[i], len(index_tmp))

                    # Replace the string values with mapped values category 1-4 instead of 'moderate' to 'extreme'
                    # function detect from (https://github.com/ecjoliver/marineHeatWaves) outputs the category as strings
                    catergory_num_tmp = np.vectorize(mapping.get)(catergory_tmp)

                    # Adding the indices and categories to the empty lists created
                    mhw_index.append(index_tmp)
                    mhw_category.append(catergory_num_tmp)

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

    ###############################################
    # Save netcdf file

    ds_save = xr.Dataset(
        {
            "threshold": (["time_leap", "latitude", "longitude"], climatology),
            "climatology": (["time", "latitude", "longitude"], threshold),
            "MHW": (["time", "latitude", "longitude"], MHW),
            "sst": (["time", "latitude", "longitude"], sst),
        },
        coords={
            "latitude": (["latitude"], lat),
            "longitude": (["longitude"], lon),
            "time": (["time"], time.values),
        },
    )

    # Saving dataset to saving path and filename
    ds_save.to_netcdf(nc_mhw_output_path)
    print("daily mhw detection finished")
