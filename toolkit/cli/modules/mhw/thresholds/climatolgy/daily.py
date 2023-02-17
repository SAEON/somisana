import os
import numpy as np
import xarray as xr
from glob import glob
from natsort import natsorted

def calculate_daily_clim(domain, mhw_bulk_cache, nc_thresholds_path):
    mhw_bulk_cache = os.path.abspath(mhw_bulk_cache)
    west, east, south, north = domain

    # Selecting files in folder
    files = natsorted(glob(mhw_bulk_cache + "/*.nc"))

    # Importing data through loop saving memory
    sst_ds = xr.open_mfdataset(files)

    # # loading lon and lat
    # lon = ds.lon.values
    # lat = ds.lat.values

    # Computes the daily climatology using def below
    sst = sst_ds.sst

    ############################################### 
    #Computes the daily climatology using def below

    # Find daily climatology
    daily_clim_tmp = sst.groupby("time.dayofyear").mean(dim="time")

    # Adding 15 days on each year of timeseries from beginning and end (need overlap for rolling mean 31 days)
    daily_clim_pad = xr.concat([daily_clim_tmp[-15::],daily_clim_tmp,daily_clim_tmp[0:15]],dim='dayofyear')

    # Find 31 day rolling mean of the climatology 
    daily_clim = daily_clim_pad.rolling(dayofyear=31, center=15).mean().dropna("dayofyear")

    ################################### 
    #Computes marine heat wave threshold

    # Group by day of year 
    day_of_year = sst.groupby('time.dayofyear') 
    day_of_year_values = daily_clim.dayofyear.values 


    #Still have to loop
    #Create empty variable to populate
    daily_percentile = np.zeros(np.shape(daily_clim))
    count = 0
    for i in np.arange(len(day_of_year)):
        count = count+1
        #Find 90th percentile
        daily_percentile[i,:,:]=np.percentile(sst[day_of_year.groups[count]],90,axis=0)
      
    
    #Convert back to xarray dataset (maybe lazy way)    
    daily_percentile = xr.DataArray(daily_percentile, 
                        dims=['dayofyear','lon','lat'], 
                        coords=dict(
                                    lon= lon.values,
                                    lat= lat.values,
                                    dayofyear=day_of_year_values,
                                    ))

    # Adding 15 days on each year of timeseries from beginning and end
    daily_percentile_pad = xr.concat([daily_percentile[-15::],daily_percentile,daily_percentile[0:15]],dim='dayofyear')

    # Find 31 day rolling mean of the climatology 
    thres = daily_percentile_pad.rolling(dayofyear=31, center=15).mean().dropna("dayofyear")

    #Laoding variables to add to netcdf file 
    day_of_year = ds_clim.dayofyear.values
    lon = ds_clim.lon.values
    lat = ds_clim.lat.values

    ds = xr.Dataset(
         {
             "clim": (["time", "latitude", "longitude"], daily_clim.values),
             "thres": (["time", "latitude", "longitude"], thres.values),
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
    ds.to_netcdf(nc_thresholds_path)
