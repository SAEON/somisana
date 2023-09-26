#!/usr/bin/env python
"""
Code for running a leeway simulation

The 'opendrift' virtual environment must be activated

The directory in which this file is run must contain an accompanying config_leeway.py file

"""
import glob, sys, os
import numpy as np
from datetime import datetime, timedelta
from dateutil.relativedelta import *
import xarray as xr
from netCDF4 import Dataset,num2date,date2num
from opendrift.readers import reader_netCDF_CF_generic
from opendrift.readers import reader_ROMS_native
from opendrift.models.leeway import Leeway
from opendrift.readers import reader_global_landmask
import config_leeway as config
import subprocess
sys.path.append('/somisana/') # where the source code gets copied into the Docker image
import plot_od,post_od

def set_croco_time(reader_filename,date_ref):
    # hacky solution to correct the time, as native croco files do not contain reference time
    # code taken directly from reader_ROMS_native.py, just with updated time_units
    ocean_time = reader_filename.Dataset.variables['time']
    time_units = 'seconds since '+str(date_ref) 
    reader_filename.times=num2date(ocean_time[:], time_units)
    reader_filename.start_time = reader_filename.times[0]
    reader_filename.end_time = reader_filename.times[-1]
    return reader_filename

def main():

    # ------------------------
    # set up the run directory
    # ------------------------
    #
    run_dir = '/tmp/opendrift/'+config.croco_run_date+'/'+config.config_name+'/'
    #
    # commenting the making of the dir as it's now done as part of the github workflow, where permissions are also set
    #if os.path.exists(run_dir):
    #    os.system('rm -rf '+run_dir)
    #os.makedirs(run_dir)
    #
    # copy the config.py file to the run dir so we have a record of the configuration that was used in the run
    os.system('cp -f /somisana/leeway/config_leeway.py '+ run_dir) # this file was baked into the docker image so we can hard code the path
    # 
    os.chdir(run_dir)
    
    # -------------------------------------
    # initialise leeway and set up readers
    # -------------------------------------
    #
    lw = Leeway(loglevel=20)  # Set loglevel to 0 for debug information
    #
    # Readers
    #
    # increasing lw.max_speed from the default of 1.3 m/s due to warning messages - the Agulhas is fast
    # we need to make sure we grab enough data from the readers at each time-step (read the docs for what this does)
    # (tests indicate this only works if done before adding the readers)
    lw.max_speed = 5 
    # 
    # Land
    reader_landmask = reader_global_landmask.Reader()
    lw.add_reader(reader_landmask)
    #
    # CROCO files covering the run
    # 
    # if you want to exclude currents for debugging:
    #lw.set_config('environment:fallback:x_sea_water_velocity', 0)
    #lw.set_config('environment:fallback:y_sea_water_velocity', 0)
    #
    # use the reader_ROMS_native reader
    # in future, the loop below could be nested in a loop on levels so file extension would be nc.level
    for croco_dir in config.croco_dirs:
        reader_croco = reader_ROMS_native.Reader(croco_dir+'stable/'+config.croco_run_date+'/croco/forecast/hourly-avg-'+config.croco_run_date+'.nc')
        reader_croco = set_croco_time(reader_croco,config.croco_ref_time)
        lw.add_reader(reader_croco)
    #
    # MERCATOR currents
    filename=config.eez_data_dir+config.croco_run_date+'/stable/mercator_'+config.croco_run_date+'.nc'
    reader_mercator = reader_netCDF_CF_generic.Reader(filename)
    lw.add_reader(reader_mercator)
    #
    # GFS wind
    #
    # if you want to exclude wind for debugging:
    # lw.set_config('environment:fallback:x_wind', 0)
    # lw.set_config('environment:fallback:y_wind', 0)
    #
    # for now we've got a hack solution to using the gfs winds - we're using the intermediate file written out
    # by croco_tools  - it's the gfs data on it's native grid in a single nc files, rather than the hundreds
    # of grb files which get downloaded and aren't so easy to use
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
    lw.add_reader(reader_gfs)
    
    # -------------------
    # physical processes
    # -------------------
    #
    # land interaction
    lw.set_config('general:use_auto_landmask', True) 
    lw.set_config('general:coastline_action', 'stranding') 
    lw.set_config('general:seafloor_action', 'lift_to_seafloor')
    #
    lw.set_config('drift:horizontal_diffusivity', config.hz_diff) # could test sensitivity 
    
    # ---------------
    # seed the model
    # ---------------
    #
    time_start = config.spill_start_time-timedelta(hours=2) # for convenience input is in local time UTC+2, so convert to model time (UTC)
    time_end = time_start+timedelta(hours=config.release_dur)
    #
    # seed the elements
    lw.seed_elements(lon=config.lon_spill, lat=config.lat_spill, 
                    radius=config.radius, 
                    time=[time_start,time_end], 
                    number=config.num_part,
                    object_type=config.object_type)
    
    # --------------
    # run the model
    # --------------
    #
    fname = 'trajectories.nc' # keep this generic - run info is contained in the dir name
    lw.run(duration=timedelta(days=config.run_dur), time_step=timedelta(minutes=config.time_step), time_step_output=timedelta(minutes=config.time_step_output), outfile=fname) 
     
    del(lw)
    
if __name__ == "__main__":
    
    main()
