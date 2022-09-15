from datetime import datetime, timedelta, time
from cli.download.gfs.functions import (
    download_file,
    get_latest_available_dt,
)

"""
Download GFS forecast data for running a croco model
Data is downloaded from hdays before date_now till hdays after date_now
The GFS model is initialised every 6 hours, and provides hourly forecasts
For the historical data we download the forecast for hours 1 through 6 from each initialisation 
The forecast data gets downloaded from the latest available initialisation

The latest initialisation is used at the time this is run, so that if there is an error on GFS
side then a slightly older initialization will be found
"""


def download(run_date, hdays, fdays, domain, workdir):
    _now = datetime.now()
    hdays = hdays + 0.25
    fdays = fdays + 0.25
    run_date = datetime.combine(run_date, time())
    start_date = run_date + timedelta(days=-hdays)

    latest_available_date = get_latest_available_dt(run_date)
    delta_days = (latest_available_date - run_date).total_seconds() / 86400

    params = (
        "&lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&var_DLWRF=on&var_DSWRF=on&var_LAND"
        + "=on&var_PRATE=on&var_RH=on&var_TMP=on&var_UFLX=on&var_UGRD=on&var_ULWRF=on&var_USWRF=on&var_VFLX=on&var_VGRD=on&"
        + "subregion=&leftlon="
        + str(domain[0])
        + "&rightlon="
        + str(domain[1])
        + "&toplat="
        + str(domain[3])
        + "&bottomlat="
        + str(domain[2])
        + "&dir=/gfs."
    )

    # Download forcing files up to latest available date
    print('\nDOWNLOADING HINDCAST files')
    while start_date < latest_available_date:
        for i in range(1, 7):  # hours 1 to 6
            download_file(start_date, i, workdir, params)
        start_date = start_date + timedelta(hours=6)

    # Download forecast forcing files
    print('\nDOWNLOADING FORECAST files')
    total_forecast_hours = int((fdays - delta_days) * 24)
    for i in range(1, total_forecast_hours + 1):
        download_file(latest_available_date, i, workdir, params)

    print("GFS download completed (in " + str(datetime.now() - _now) + " h:m:s)")
    return delta_days
