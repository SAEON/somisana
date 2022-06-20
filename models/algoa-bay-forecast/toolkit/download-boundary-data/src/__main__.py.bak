from config import COPERNICUS_USERNAME, COPERNICUS_PASSWORD
import os
from datetime import timedelta, date
from download_scripts.gfs_data import download as gfs
from download_scripts.mercator_data import download as mercator
from multiprocessing import Process

def runInParallel(*fns):
  processes = []
  for fn in fns:
    p = Process(target=fn)
    p.start()
    processes.append(p)
  for p in processes:
    p.join()

TMP_DIRECTORY = '/tmp/somisana/current'
DOWNLOADS_PATH = os.path.join(TMP_DIRECTORY, 'download_inputs/')
MATLAB_ENV_PATH = os.path.join(TMP_DIRECTORY, '.env')

# Params
today = date.today() # using date(), not datetime() as we use 00:00:00 as the reference time by definition
yesterday = today + timedelta(days=-1) # Needed to check for restart file
parent_dir = os.getcwd()
hdays = 5 # x days into the past
fdays = 5 # x days into the future
geographic_extent = [22, 31, -37, -31] # Subset downloads with this extent [west, east, south, north]
date_start = today + timedelta(days=-hdays)
date_end = today + timedelta(days=fdays)
varsOfInterest = ['so', 'thetao', 'zos', 'uo', 'vo'] # Mercator
depths = [0.493, 5727.918] # [min, max] Mercator

# write the user defined input to the log file
print('working directory: ' + parent_dir)
print('date: ' + str(today))
print('hindcast days: ' + str(hdays))
print('forecast days: ' + str(fdays))
print('simulation temporal coverage: ' + str(date_start) + ' - ' + str(date_end))
print('spatial extent for download of global forcing data (west, east, south, north):')

def run_gfs():
    # Download GFS data (ocean surface weather data)
    print('Downloading GFS data...')
    delta_days_gfs = gfs(today, hdays, fdays, geographic_extent, DOWNLOADS_PATH)
    
    # MatLab is configured via a .env file
    print('Configuring MatLab with dates from GFS download...')
    env = open(MATLAB_ENV_PATH, "w")
    env.write("""RUN_DATE={0}
DELTA_DAYS_GFS={1}"""
        .format(
            str(date.today()),
            str(delta_days_gfs)
        ))
    env.close()

def run_mercator():
    # Download Mercator data (ocean boundary data)
    print('Downloading Mercator data...')
    mercator(
        COPERNICUS_USERNAME,
        COPERNICUS_PASSWORD,
        geographic_extent,
        today,
        hdays,
        fdays,
        varsOfInterest,
        depths,
        DOWNLOADS_PATH
    )

# Run script
runInParallel( run_gfs, run_mercator )
print('Complete!')