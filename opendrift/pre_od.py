#!/usr/bin/env python
"""
some generic functions for running opendrift on the somisana ocean model output
specifically around setting up the environmental data readers
These are common to all OpenDrift applications

"""

import sys, os, glob
import numpy as np
from datetime import datetime, timedelta
import xarray as xr
from opendrift.readers import reader_netCDF_CF_generic
from opendrift.readers import reader_ROMS_native
from opendrift.readers import reader_global_landmask
import xarray as xr

def set_croco_time(reader_filename,date_ref):
    # hacky solution to correct the time, as native croco files do not contain reference time
    # code taken directly from reader_ROMS_native.py, just with updated time_units
    ocean_time = reader_filename.Dataset.variables['time']
    time_units = 'seconds since '+str(date_ref) 
    reader_filename.times=num2date(ocean_time[:], time_units)
    reader_filename.start_time = reader_filename.times[0]
    reader_filename.end_time = reader_filename.times[-1]
    return reader_filename

def add_readers(o,config):
    # add the somisana readers
    # o - OpenDrift object to add the readers to
    # config - configuration file which contains info on what readers to add
    
    # start by increasing o.max_speed from the default of 1.3 m/s due to warning messages - the Agulhas is fast!
    # we need to make sure we grab enough data from the readers at each time-step (read the docs for what this does)
    # (tests indicate this only works if done before adding the readers)
    o.max_speed = 5 
    
    # -----
    # Land
    # -----
    reader_landmask = reader_global_landmask.Reader()
    o.add_reader(reader_landmask)
    
    # -----------------------------
    # CROCO files covering the run
    # -----------------------------
    # 
    # if you want to exclude currents for debugging:
    #o.set_config('environment:fallback:x_sea_water_velocity', 0)
    #o.set_config('environment:fallback:y_sea_water_velocity', 0)
    #
    # use the reader_ROMS_native reader
    # in future, the loop below could be nested in a loop on levels so file extension would be nc.level
    for croco_dir in config.croco_dirs:
        reader_croco = reader_ROMS_native.Reader(croco_dir+'stable/'+config.croco_run_date+'/croco/forecast/hourly-avg-'+config.croco_run_date+'.nc')
        reader_croco = set_croco_time(reader_croco,config.croco_ref_time)
        o.add_reader(reader_croco)
    
    # ------------------
    # MERCATOR currents
    # ------------------
    #
    # (FYI this is also the file which is getting archived on the file server - 
    # https://mnemosyne.somisana.ac.za/somisana/global-data)
    filename=config.eez_data_dir+config.croco_run_date+'/stable/mercator_'+config.croco_run_date+'.nc'
    reader_mercator = reader_netCDF_CF_generic.Reader(filename)
    o.add_reader(reader_mercator)
    
    # ---------
    # GFS wind
    # ---------
    #
    # if you want to exclude wind for debugging:
    # o.set_config('environment:fallback:x_wind', 0)
    # o.set_config('environment:fallback:y_wind', 0)
    #
    # for now we've got a hack solution to using the gfs winds - we're using the intermediate file written out
    # by croco_tools  - it's the gfs data on it's native grid in a single nc files, rather than the hundreds
    # of grb files which get downloaded and aren't so easy to use
    # (FYI this is also the file which is getting archived on the file server - 
    # https://mnemosyne.somisana.ac.za/somisana/global-data)
    #
    filename='/tmp/algoa-bay-forecast/stable/'+config.croco_run_date+'/croco/forcing/GFS_'+config.croco_run_date+'.nc'
    # I'm opening the file as an xarray dataset before passing to reader_netCDF_CF_generic
    # because it had trouble with the time conversion inside the reader
    # Doing it like this is a hack to get around this issue, as the time gets handled by xarray
    # rather than by netCDF4's num2date function as done in the reader 
    Dataset = xr.open_dataset(filename, decode_times=True) # decode_times=True is the default 
    reader_gfs = reader_netCDF_CF_generic.Reader(Dataset,
                            standard_name_mapping={'uwnd': 'x_wind',
                                                   'vwnd': 'y_wind'},)    
    o.add_reader(reader_gfs)
    
    return o
