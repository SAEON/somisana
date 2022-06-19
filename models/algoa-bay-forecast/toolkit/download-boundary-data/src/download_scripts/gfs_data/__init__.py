from pydap.client import open_url
from datetime import datetime, timedelta, time
import sys
from download_scripts.gfs_data.fns import downloadFile, testUrl

"""
Download GFS forecast data for running a croco model
Data is downloaded from hdays before date_now till hdays after date_now
The GFS model is initialised every 6 hours, and provides hourly forecasts
For the historical data we download the forecast for hours 1 through 6 from each initialisation 
The forecast data gets downloaded from the latest available initialisation
"""


def download(today, hdays, fdays, geographic_extent, dirout):
    # Configure the script
    now = datetime.now()
    hdays = hdays + 0.25 # Pad the simulation period (6 hrs)
    fdays = fdays + 0.25 # Pad the simulation period (6 hrs)

    # Find latest available data
    today = datetime.combine(today, time())
    latest_dt = datetime(today.year, today.month, today.day, 18, 0, 0)
    gfs_exists = False
    iters = 0
    while not(gfs_exists):
        try:
            print('Testing for latest data', latest_dt)
            open_url(testUrl(latest_dt))
            gfs_exists = True
        except:
            latest_dt = latest_dt+timedelta(hours=-6)
            iters = iters+1
            if iters > 4:
                print("GFS data is not presently available")
                sys.exit('')

    print("Latest available GFS initialisation found:", latest_dt)
    delta_days = (latest_dt - today).total_seconds() / 86400

    print('\n\n=== Downloading historical data ===')
    lookback = today + timedelta(days =- hdays)
    while lookback < latest_dt:
        for offset in range(1, 7):
            downloadFile(dirout, lookback, offset, geographic_extent)
        lookback = lookback + timedelta(hours=6)

    # Download forecast data
    print('\n=== Downloading forecast data ===')
    total_forecast_hours = int((fdays - delta_days) * 24)
    for offset in range(1, total_forecast_hours + 1):
        downloadFile(dirout, latest_dt, offset, geographic_extent)

    print('\nGFS download completed (in '+str(datetime.now() - now)+' h:m:s)')
    return delta_days  # return this as we need it when generating the croco forcing files