#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
do some plots of the raw OpenDrift output
"""
import os
from datetime import datetime, timedelta
import sys
sys.path.append('/home/gfearon/code/somisana/')
from opendrift_tools import plot_od,post_od
import config_oil as config

print('computing the oil budget...')
post_od.get_trajectories_oil_budget(config.run_dir)

print('plotting the oil budget...')
plot_od.plot_budget(config.run_dir)

print('doing the animation...')
plot_od.iteration_animate(config.run_dir,
                  figsize=(8,4), # resize as needed to match the shape of extents below
                  extents=[24.5,28.2,-35.2,-33.0], #lon1,lon2,lat1,lat2
                  lon_release=config.lon_spill,
                  lat_release=config.lat_spill,
                  time_x=0.1, # placement of time label, in axes coordinates 
                  time_y=0.9,  
                  vmin=-10,   # the z variable is animated so this is your max depth 
                  cmap='Spectral_r',#'gray_r', 
                  plot_cbar=True,
                  cbar_loc=(0.88, 0.15, 0.01, 0.7), # [left, bottom, width, height]
                  croco_dirs=config.croco_dirs,
                  croco_run_date=config.croco_run_date
                  )

