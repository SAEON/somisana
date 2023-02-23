import os
import numpy as np
import xarray as xr
from glob import glob
from natsort import natsorted

def calculate_daily_clim(mhw_bulk_cache, nc_thresholds_path):
    mhw_bulk_cache = os.path.abspath(mhw_bulk_cache)

    # Selecting files in folder
    files = natsorted(glob(mhw_bulk_cache + "/*.nc"))

    # Importing data through loop saving memory (Seems like there is a issue with rolling means and xarray https://github.com/pydata/xarray/issues/3277 need to loop the load)
    list_of_arrays = []
    for file in files:
        ds = xr.open_dataset(file)
        list_of_arrays.append(np.squeeze(ds['sst']))
       
    sst_ds = xr.concat(list_of_arrays[0:len(list_of_arrays)],dim='time')

    #Dropping empty dimesion zlev
    sst_ds = sst_ds.drop_vars('zlev')
    #Add a fill values as the rolling mean can't handle the land values
    sst_ds = sst_ds.fillna(9999)

    # # loading lon and lat
    lon = sst_ds.lon.values
    lat = sst_ds.lat.values

    ############################################### 
    #Computes the daily climatology

    # Find daily climatology
    daily_clim_tmp = sst_ds.groupby("time.dayofyear").mean(dim="time")
    # Adding 15 days on each year of timeseries from beginning and end (need overlap for rolling mean 31 days)
    daily_clim_pad = xr.concat([daily_clim_tmp[-15::],daily_clim_tmp,daily_clim_tmp[0:15]],dim='dayofyear')
    #print(daily_clim_pad)
    # Find 31 day rolling mean of the climatology
    daily_clim = daily_clim_pad.rolling(dayofyear=31, center=15).mean().dropna("dayofyear")
    #print(daily_clim)
    ################################### 
    #Computes marine heat wave threshold

    # Group by day of year 
    day_of_year = sst_ds.groupby('time.dayofyear') 
    day_of_year_values = daily_clim.dayofyear.values 

    #Still have to loop
    #Create empty variable to populate
    daily_percentile = np.zeros(np.shape(daily_clim))
    count = 0

    #Loop through days of year not indices 
    for i in day_of_year_values:
        #Find 90th percentile
        daily_percentile[count,:,:]=np.percentile(sst_ds[day_of_year.groups[i]],90,axis=0)
        count = count+1

    #Convert back to xarray dataset (maybe lazy way)    
    daily_percentile = xr.DataArray(daily_percentile, 
                       dims=['dayofyear','lat','lon'], 
                        coords=dict(
                                   lat= lat,
                                   lon= lon,
                                   dayofyear=day_of_year_values,
                                    ))
    # Adding 15 days on each year of timeseries from beginning and end
    daily_percentile_pad = xr.concat([daily_percentile[-15::],daily_percentile,daily_percentile[0:15]],dim='dayofyear')
    # Find 31 day rolling mean of the climatology 
    thres = daily_percentile_pad.rolling(dayofyear=31, center=15).mean().dropna("dayofyear")
    ################################### 
    #Replace fill values with nans
    daily_clim = daily_clim.where(daily_clim < 9998, np.nan)
    thres = thres.where(thres < 9998, np.nan)

    ds = xr.Dataset(
         {
             "clim": (["time", "latitude", "longitude"], daily_clim.values),
             "thres": (["time", "latitude", "longitude"], thres.values),
         },
         coords={
             "day_of_year": day_of_year_values,
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
    ds.to_netcdf(nc_thresholds_path)
    print('daily clim finished')
    