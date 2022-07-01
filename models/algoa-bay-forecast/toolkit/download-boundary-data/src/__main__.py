#!/usr/bin/env python3
from config import COPERNICUS_USERNAME, COPERNICUS_PASSWORD
import os
from datetime import timedelta, date
from download_scripts.gfs import gfs
from download_scripts.mercator import mercator

TMP_DIRECTORY = '/tmp/somisana/current'
DOWNLOADS_PATH = os.path.join(TMP_DIRECTORY, 'forcing-inputs/')
MATLAB_ENV_PATH = os.path.join(TMP_DIRECTORY, '.env')

# Params
date_now = date.today() # using date(), not datetime() as we use 00:00:00 as the reference time by definition
date_yesterday = date_now + timedelta(days=-1) # Needed to check for restart file
parent_dir = os.getcwd()
hdays = 5 # x days into the past
fdays = 5 # x days into the future
domain = [22, 31, -37, -31] # Subset downloads with this extent [west, east, south, north]
date_start = date_now + timedelta(days=-hdays)
date_end = date_now + timedelta(days=fdays)
varsOfInterest = ['so', 'thetao', 'zos', 'uo', 'vo'] # Mercator
depths = [0.493, 5727.918] # [min, max] Mercator

# write the user defined input to the log file
print('working directory: ' + parent_dir)
print('date: ' + str(date_now))
print('hindcast days: ' + str(hdays))
print('forecast days: ' + str(fdays))
print('simulation temporal coverage: ' + str(date_start) + ' - ' + str(date_end))
print('spatial extent for download of global forcing data (west, east, south, north):')

# Download GFS data (ocean surface weather data)
print('Downloading GFS data...')
delta_days_gfs = gfs(date_now, hdays, fdays, domain, DOWNLOADS_PATH)

# Download Mercator data (ocean boundary data)
print('Downloading Mercator data...')
mercator(
    COPERNICUS_USERNAME,
    COPERNICUS_PASSWORD,
    domain,
    date_now,
    hdays,
    fdays,
    varsOfInterest,
    depths,
    DOWNLOADS_PATH
)

# MatLab is configured via a .env file
print('Configuring MatLab...')
with open(MATLAB_ENV_PATH, 'w+') as env:
    env.write("""RUN_DATE={0}
DELTA_DAYS_GFS={1}
"""
    .format(
        str(date.today()),
        str(delta_days_gfs)
    ))
os.chmod(MATLAB_ENV_PATH, '0o777')

# Script complete
print('Complete!')