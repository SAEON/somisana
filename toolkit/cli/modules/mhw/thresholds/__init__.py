import numpy as np
import xarray as xr
from glob import glob
from natsort import natsorted


def getDailyClim(sst):
    ds_day = sst.groupby("time.dayofyear").mean(dim="time")
    crap = xr.concat([ds_day[-15::], ds_day, ds_day[0:15]], dim="dayofyear")
    crap.dayofyear[0:15].values[:] = crap.dayofyear[0:15].values - 366
    crap.dayofyear[-15::].values[:] = crap.dayofyear[-15::].values + 366
    ds_clim = np.empty(np.shape(ds_day))
    # moving average over 31 days to make daily climatology
    for i in np.arange(366):
        ds_clim[i, :, :] = crap[i : i + 31, :, :].mean(dim="dayofyear").values
    ds_clim = xr.DataArray(data=ds_clim, dims=ds_day.dims, coords=ds_day.coords)
    ds_clim.name = "sst_clim"
    return ds_clim


def getDailyThresholds(sst):
    ds_day = sst.groupby("time.dayofyear")
    sst_shape = np.empty(np.shape(sst[0]))
    daily_per = np.repeat(sst_shape[None, :], 366, axis=0)
    count = 0
    for i in np.arange(366):
        count = count + 1
        daily_per[i, :, :] = np.percentile(sst[ds_day.groups[count]], 90, axis=0)

    crap = np.concatenate([daily_per[-15::], daily_per, daily_per[0:15]])

    # moving average over 31 days to make daily climatology
    ds_tres = np.repeat(sst_shape[None, :], 366, axis=0)
    for x in np.arange(366):
        ds_tres[x, :, :] = crap[x : x + 31, :, :].mean(axis=0)
    return ds_tres


def thresholds(args):
    domain = list(map(lambda i: float(i), args.domain.split(",")))
    west, east, north, south = domain

    # Adding the path to the model data
    path_to_data = "/media/matthew/Elements/SST_data/Low_res_SST/NCEI_OISST_AVHRR_ND/"

    # Adding path to save the satelite netcdf file
    save_path = "/home/matthew/Documents/Python_scripts/Marine_heat_waves/Github_test/"
    save_fname = "MHW_threshold" + ".nc"

    # The variables to be analysed as written in netcdf files
    satelite_variable = "analysed_sst"

    # The longitude and latitude dimesions of the observations of named in netcdf file
    lat = "lat"
    lon = "lon"

    # Selecting files in folder
    sstFiles = natsorted(glob(path_to_data + "*.nc"))

    # Importing data through loop saving memory
    list_of_arrays = []
    for file in sstFiles:
        ds = xr.open_dataset(file)
        ds = ds.sel(lat=slice(south, north), lon=slice(west, east))
        if np.size(ds.lat) == 116:
            list_of_arrays.append(ds["analysed_sst"])

    sst_ds = xr.concat(list_of_arrays[0 : len(list_of_arrays)], dim="time")

    # loading lon and lat
    lon = ds.lon.values
    lat = ds.lat.values

    # Kelvin conversion
    sst = sst_ds - 273.15

    # Computes the daily climatology using def below
    ds_clim = getDailyClim(sst)

    # Computes marine heat wave threshold
    ds_tres = getDailyThresholds(sst)

    # Computes daily anomaly
    ds_ano = sst.groupby("time.dayofyear") - ds_clim
    sst_ano = ds_ano.values

    thres = ds_tres[:, :, :]
    clim = ds_clim.values
    day_of_year = ds_clim.dayofyear.values
    lon = ds_clim.lon.values
    lat = ds_clim.lat.values

    ds = xr.Dataset(
        {
            "clim": (["time", "latitude", "longitude"], clim),
            "thres": (["time", "latitude", "longitude"], thres),
        },
        coords={
            "day_of_yar": day_of_year,
            "latitude": (["latitude"], lat),
            "longitude": (["longitude"], lon),
        },
    )

    ds.clim.attrs[
        "comment"
    ] = "The daily climatology calculated on a 31 day moving average"
    ds.clim.attrs["units"] = "^oC"

    ds.thres.attrs[
        "comment"
    ] = "The daily climatology calculated on a 31 day moving average"
    ds.thres.attrs["units"] = "^oC"

    # Saving dataset to saving path and filename
    ds.to_netcdf(save_path + save_fname)
