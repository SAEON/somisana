#!/usr/bin/env python
"""
Code for running an openoil simulation

The 'opendrift' virtual environment must be activated

The directory in which this file is run must contain an accompanying config_oil.py file

"""
import glob, sys, os
import numpy as np
from datetime import datetime, timedelta
from dateutil.relativedelta import *
import xarray as xr
from netCDF4 import Dataset,num2date,date2num
#from opendrift.readers import reader_netCDF_CF_generic
#from opendrift.readers import reader_ROMS_native
#from opendrift.readers import reader_oscillating
from opendrift.models.openoil import OpenOil
from opendrift.readers import reader_global_landmask
import config_oil as config
import subprocess
sys.path.append('/somisana/') # where the source code gets copied into the Docker image
import plot_od,post_od,pre_od
import plot_oil

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
    os.system('cp -f /somisana/oil/config_oil.py '+ run_dir) # this file was baked into the docker image so we can hard code the path
    # 
    os.chdir(run_dir)
    
    # -------------------------------------
    # initialise openoil and set up readers
    # -------------------------------------
    #
    o = OpenOil(loglevel=50,  weathering_model='noaa')  # loglevel=50 turns off logs, loglevel=0 gives max information for debugging
    
    o = pre_od.add_readers(o,config)
    
    # -------------------
    # physical processes
    # -------------------
    #
    # land interaction
    o.set_config('general:use_auto_landmask', True) 
    o.set_config('general:coastline_action', 'stranding') 
    o.set_config('general:seafloor_action', 'lift_to_seafloor')
    #
    # I'd prefer to use the exact wind and current...for now anyway
    o.set_config('drift:wind_uncertainty',0) 
    o.set_config('drift:current_uncertainty',0) 
    # ...but add hz diffusivity
    o.set_config('drift:horizontal_diffusivity', config.hz_diff) # could test sensitivity 
    o.set_config('drift:vertical_mixing', True) 
    o.set_config('vertical_mixing:timestep', 60) # seconds, higher timestep for this process
    o.set_config('drift:vertical_advection', False) # maybe something to test sensitivity to
    o.set_config('vertical_mixing:diffusivitymodel','environment') # default - reading from croco file
    o.set_config('environment:fallback:ocean_vertical_diffusivity', 0.005) # loosely based on near-surface CROCO output. We'll need this for when we combine our croco runs which include diffusivity with mercator data which does not
    o.set_config('wave_entrainment:entrainment_rate', 'Li et al. (2017)') # default
    o.set_config('wave_entrainment:droplet_size_distribution', 'Li et al. (2017)') # as per Rohrs et al. (2018)
    
    # ---------------------
    # oil spill properties
    # ---------------------
    #
    # weathering
    o.set_config('processes:dispersion', False) # not needed as we are modelling wave entrainment explicitly (see Rohrs et al. (2018))
    o.set_config('processes:evaporation', True)
    o.set_config('processes:emulsification', True)
    #
    # droplet sizes
    # this is only important for a subsea release, and I assume we're looking at surface releases for now
    # so I'm just specifying large initial droplets so that all particles can surface after 1 time-step
    # (this get's over-ridden by the wave entrainment DSD when pushed into the water column due to wave entrainment)
    o.set_config('seed:droplet_size_distribution','uniform')
    o.set_config('seed:droplet_diameter_min_subsea', 0.05)
    o.set_config('seed:droplet_diameter_max_subsea', 0.05)
    # if it's a subsea blowout you may want to specify a lognormal distribution
    #o.set_config('seed:droplet_size_distribution','lognormal')
    #o.set_config('seed:droplet_diameter_mu',1.5e-3)
    #o.set_config('seed:droplet_diameter_sigma',0.5e-3)
    #
    time_start = config.spill_start_time-timedelta(hours=2) # for convenience input is in local time UTC+2, so convert to model time (UTC)
    time_end = time_start+timedelta(hours=config.release_dur)
    #
    # flow rate
    o.set_config('seed:m3_per_hour', config.oil_flow_rate); 
    #
    # seed the elements
    o.seed_elements(lon=config.lon_spill, lat=config.lat_spill, z=config.z,
                    radius=config.radius, 
                    time=[time_start,time_end], 
                    number=config.num_part,
                    oil_type=config.oil_type,
                    wind_drift_factor=config.wind_drift_factor)
    
    # --------------
    # run the model
    # --------------
    #
    fname = 'trajectories.nc' # keep this generic - run info is contained in the dir name
    o.run(duration=timedelta(days=config.run_dur), time_step=timedelta(minutes=config.time_step), time_step_output=timedelta(minutes=config.time_step_output), outfile=fname) 
     
    del(o)
    
if __name__ == "__main__":
    
    main()
