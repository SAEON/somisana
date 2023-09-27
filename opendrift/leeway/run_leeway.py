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
import plot_od,post_od,pre_od

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
    lw = pre_od.add_readers(lw,config)

    # -------------------
    # physical processes
    # -------------------
    #
    # land interaction
    lw.set_config('general:use_auto_landmask', True) 
    lw.set_config('general:coastline_action', 'stranding') 
    #
    lw.set_config('drift:horizontal_diffusivity', config.hz_diff) # could test sensitivity 
    
    # ---------------
    # seed the model
    # ---------------
    #
    lw.seed_elements(lon=config.lon_spill, lat=config.lat_spill, 
                    radius=config.radius, 
                    time=config.spill_start_time-timedelta(hours=2), # for convenience input is in local time UTC+2, so convert to model time (UTC) 
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
