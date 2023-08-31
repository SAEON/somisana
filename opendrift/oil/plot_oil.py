#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
do some plots of the raw OpenDrift output
"""
import os
from datetime import datetime, timedelta
import sys
import config_oil as config
sys.path.append('/somisana/') # where the source code gets copied into the Docker image
import plot_od,post_od

def main():

    print('computing the oil budget...')
    post_od.get_trajectories_oil_budget(config.run_dir)
    
    print('plotting the oil budget...')
    plot_od.plot_budget(config.run_dir)
    
    print('doing the animation...')
    plot_od.iteration_animate(config.run_dir,
                      figsize=config.figsize, # resize as needed to match the shape of extents below
                      extents=config.plot_extents, #lon1,lon2,lat1,lat2
                      lon_release=config.lon_spill,
                      lat_release=config.lat_spill,
                      time_x=config.time_z, # placement of time label, in axes coordinates 
                      time_y=config.time_y,  
                      vmin=config.vmin,   # the z variable is animated so this is your max depth 
                      cmap=config.cmap, #'Spectral_r' 
                      plot_cbar=config.plot_cbar,
                      cbar_loc=config.cbar_loc, # [left, bottom, width, height]
                      croco_dirs=config.croco_dirs,
                      croco_run_date=config.croco_run_date
                      )
   
if __name__ == "__main__":

    main()

