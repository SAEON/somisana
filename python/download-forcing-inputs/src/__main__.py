#!/usr/bin/env python3
from config import COPERNICUS_USERNAME, COPERNICUS_PASSWORD
import sys, os, glob
from datetime import timedelta, date, datetime
import download_frcst
#import subprocess

startTime_all=datetime.now() # for timing purposes
date_now = date.today() # using date(), not datetime() as we use 00:00:00 as the reference time by definition
# date_now = date_now + timedelta(days=-1) # temporary just for debugging in case you want to run a previous day

print('\n##########################################')
print('# STARTING SCRIPT python packages installed')
print('##########################################\n')

# parent dir for running this script
parent_dir=os.getcwd()
print(parent_dir)

# temporal limits for the simulation
# it will run from date_now - hdays to date_now + fdays
hdays=5
fdays=5

# temporal output of croco model (in hours)
nh_avg=6 # full domain
nh_avg_surf=1 # surface layer only

# temporal limits for archiving CROCO output (in days from start of simulation)
archive_start=hdays-1 # the day before today
archive_end=hdays+fdays # the last day

# spatial limits for downloading data for model forcing (just needs to cover model limits to do the interpolation)
# [west, east, south, north]
domain = [22, 31, -37, -31]

# write the user defined input to the log file
print('working directory: '+parent_dir)
print('date: '+str(date_now))
print('hindcast days: '+str(hdays))
print('forecast days: '+str(fdays))
date_start = date_now +timedelta(days=-hdays)
date_end = date_now +timedelta(days=fdays)
print('simulation temporal coverage: '+str(date_start)+' - '+str(date_end))
print('spatial extent for download of global forcing data (west, east, south, north):')

# write the user defined input to the log file

print('\n##########################################')
print('# DOWNLOAD DATA FOR FORCING THE MODEL')
print('##########################################\n')
#
fileout ='/home/GFS/test.grb'
#


# GFS
#gfs_dir=parent_dir+'/GFS/'
gfs_dir='home/matthew/docker_output/'
# start by removing already downloaded files. This adds redundancy in the download but it is only a few minutes anyway so not worth the effort of removing only certain files
for f in glob.glob(gfs_dir+'*grb*'):
    os.remove(f)
#
#delta_days_gfs=download_frcst.gfs(date_now, hdays, fdays, domain, gfs_dir)

########################
# Download Mercator data
########################

# Define some inputs specific to mercator download
#mercator_dir=parent_dir+'/mercator/'
mercator_dir='home/matthew/docker_output/'
# start by removing already downloaded files. 
for f in glob.glob(mercator_dir+'*nc'):
    os.remove(f)
#path2motuClient = '/home/osboxes/anaconda3/lib/python3.7/site-packages/'
path2motuClient = '/usr/local/lib/python3.8/site-packages/'
usrname = COPERNICUS_USERNAME
passwd = COPERNICUS_PASSWORD
# variables to extract
varList = ['so', 'thetao', 'zos', 'uo', 'vo']
# min and max depths
depths = [0.493, 5727.918]
# download the data
print('\n'+'downloading mercator data...')
download_frcst.mercator(path2motuClient, usrname, passwd, domain, date_now, hdays, fdays, varList, depths, mercator_dir)