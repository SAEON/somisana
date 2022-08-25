import requests as r
from datetime import datetime, timedelta, time
from cli.download.sources.gfs_functions import yyyymmdd, download_file, get_latest_available_dt

"""
Download GFS forecast data for running a croco model
Data is downloaded from hdays before date_now till hdays after date_now
The GFS model is initialised every 6 hours, and provides hourly forecasts
For the historical data we download the forecast for hours 1 through 6 from each initialisation 
The forecast data gets downloaded from the latest available initialisation

The latest initialisation is used at the time this is run, so that if there is an error on GFS
side then a slightly older initialization will be found
"""

def gfs(date_now, hdays, fdays, domain, dirout):
    now = datetime.now()
    hdays = hdays + 0.25
    fdays = fdays + 0.25
    date_now = datetime.combine(date_now, time())
    start_date = date_now + timedelta(days =- hdays)

    latest_available_date = get_latest_available_dt(date_now)
    delta_days = (latest_available_date - date_now).total_seconds() / 86400  
    
    params = '&lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&var_DLWRF=on&var_DSWRF=on&var_LAND' \
        + '=on&var_PRATE=on&var_RH=on&var_TMP=on&var_UFLX=on&var_UGRD=on&var_ULWRF=on&var_USWRF=on&var_VFLX=on&var_VGRD=on&' \
        + 'subregion=&leftlon=' \
        + str(domain[0]) \
        + '&rightlon=' \
        + str(domain[1]) \
        + '&toplat=' \
        + str(domain[3]) \
        + '&bottomlat=' \
        + str(domain[2]) \
        + '&dir=/gfs.'

    # Download forcing files up to latest available date
    while start_date < latest_available_date:
        for i in range(1, 7): # hours 1 to 6
            download_file(start_date, i, dirout, params)
        start_date = start_date + timedelta(hours=6)

    # Download forecast forcing files
    total_forecast_hours = int( (fdays - delta_days) * 24 )
    for i in range(1, total_forecast_hours + 1):
        download_file(latest_available_date, i, dirout, params)

    print('GFS download completed (in ' + str(datetime.now() - now) + ' h:m:s)')
    return delta_days 
