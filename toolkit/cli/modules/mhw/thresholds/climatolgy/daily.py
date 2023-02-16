import os
import numpy as np
import xarray as xr
from glob import glob
from natsort import natsorted


def getDailyClim(daily_data, month_median, day_range):
    moving_avg = xr.concat([daily_data[-month_median::], daily_data, daily_data[0:month_median]], dim="dayofyear")
    moving_avg.dayofyear[0:month_median].values[:] = moving_avg.dayofyear[0:month_median].values - day_range
    moving_avg.dayofyear[-month_median::].values[:] = moving_avg.dayofyear[-month_median::].values + day_range
    ds_clim = np.empty(np.shape(daily_data))
    # moving average over 31 days to make daily climatology
    for i in np.arange(day_range):
        ds_clim[i, :, :] = moving_avg[i : i + 31, :, :].mean(dim="dayofyear").values
    ds_clim = xr.DataArray(data=ds_clim, dims=daily_data.dims, coords=daily_data.coords)
    ds_clim.name = "sst_clim"
    return ds_clim


def getDailytres(sst, day_range, day_i_min, day_i_max, month_median):
    ds_day = sst.groupby("time.dayofyear")
    sst_shape = np.empty(np.shape(sst[0]))
    daily_per = np.repeat(sst_shape[None, :], day_range, axis=0)
    for i, day in enumerate(range(day_i_min, day_i_max)):
        daily_per[i, :, :] = np.percentile(sst[ds_day.groups[day]], 90, axis=0)
    crap = np.concatenate([daily_per[-month_median::], daily_per, daily_per[0:month_median]])
    # moving average over 31 days to make daily climatology
    ds_tres = np.repeat(sst_shape[None, :], day_range, axis=0)
    for x in np.arange(day_range):
        ds_tres[x, :, :] = crap[x : x + 31, :, :].mean(axis=0)
    return ds_tres


def calculate_daily_clim(domain, mhw_bulk_cache, nc_thresholds_path):
    mhw_bulk_cache = os.path.abspath(mhw_bulk_cache)
    west, east, south, north = domain
    lat = "lat"
    lon = "lon"

    # Selecting files in folder
    files = natsorted(glob(mhw_bulk_cache + "/*.nc"))

    # Importing data through loop saving memory
    sst_ds = xr.open_mfdataset(files)

    # # loading lon and lat
    # lon = ds.lon.values
    # lat = ds.lat.values

    # Computes the daily climatology using def below
    sst = sst_ds.sst
    daily_data = sst.groupby("time.dayofyear").mean(dim="time")
    day_i_min = daily_data.dayofyear[0].values
    day_i_max = daily_data.dayofyear[-1].values
    day_range = day_i_max - day_i_min
    month_median = 15
    ds_clim = getDailyClim(daily_data, month_median, day_range)

    # Computes marine heat wave threshold
    ds_tres = getDailytres(sst, day_range, day_i_min, day_i_max, month_median)


    thres = ds_tres[:, :, :]
    clim = ds_clim.values
    day_of_year = ds_clim.dayofyear.values
    lon = ds_clim.lon.values
    lat = ds_clim.lat.values

    # ds = xr.Dataset(
    #     {
    #         "clim": (["time", "latitude", "longitude"], clim),
    #         "thres": (["time", "latitude", "longitude"], thres),
    #     },
    #     coords={
    #         "day_of_yar": day_of_year,
    #         "latitude": (["latitude"], lat),
    #         "longitude": (["longitude"], lon),
    #     },
    # )

    # ds.clim.attrs[
    #     "comment"
    # ] = "The daily climatology calculated on a 31 day moving average"
    # ds.clim.attrs["units"] = "^oC"

    # ds.thres.attrs[
    #     "comment"
    # ] = "The daily climatology calculated on a 31 day moving average"
    # ds.thres.attrs["units"] = "^oC"

    # # Saving dataset to saving path and filename
    # ds.to_netcdf(nc_thresholds_path)
