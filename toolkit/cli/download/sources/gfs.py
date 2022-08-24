import requests as r
from datetime import datetime, timedelta, time
import sys
import os
from cli.download.sources._functions import yyyymmdd, time_param, create_fname, validate_download_or_remove, make_cURL

"""
Download GFS forecast data for running a croco model
Data is downloaded from hdays before date_now till hdays after date_now
The GFS model is initialised every 6 hours, and provides hourly forecasts
For the historical data we download the forecast for hours 1 through 6 from each initialisation 
The forecast data gets downloaded from the latest available initialisation

The latest initialisation is used at the time this is run, so that if there is an error on GFS
side then a slightly older initialization will be found
"""

BASE_URL = 'https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25_1hr.pl?file=gfs.t'

def gfs(date_now, hdays, fdays, domain, dirout):
    start_time = datetime.now()
    date_now = datetime.combine(date_now, time())
    hdays = hdays + 0.25
    fdays = fdays + 0.25

    URL_PARAMS = '&lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&var_DLWRF=on&var_DSWRF=on&var_LAND' \
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
    
    date_latest = datetime(date_now.year, date_now.month, date_now.day, 18, 0, 0)
    gfs_exists = False
    iters = 0

    while not (gfs_exists):
        if iters > 4:
            print("GFS data is not presently available")
            sys.exit(1)

        url_check = \
            'https://nomads.ncep.noaa.gov/dods/gfs_0p25_1hr/gfs' \
            + yyyymmdd(date_latest) \
            + '/gfs_0p25_1hr_' \
            + date_latest.strftime("%H") \
            + 'z'

        print('Testing GFS availability', url_check)
        result = r.head(url_check)
        xdap = result.headers.get('XDAP')
        if xdap:
            print("Latest available GFS initialisation found at",url_check, '\n', 'X-DAP HTTP Header', xdap, '\n', '\n')
            gfs_exists = True
        else:
            date_latest = date_latest + timedelta(hours=- 6)
            iters += 1

    print("GFS download started...")
    delta_days = (date_latest-date_now).total_seconds() / 86400
    date_hist = date_now + timedelta(days =- hdays)

    while date_hist < date_latest:

        # forecast hours 1 to 6
        for i in range(1, 7):
            fname = create_fname(date_hist, i)
            fileout = os.path.join(dirout, fname)

            # only download if the file doesn't already exist
            if not (os.path.isfile(fileout)):
                url = BASE_URL \
                    + date_hist.strftime("%H") \
                    + 'z.pgrb2.0p25.f' \
                    + str(i).zfill(3) \
                    + URL_PARAMS \
                    + time_param(date_hist)

                cmd = make_cURL(url, fileout)
                print(cmd)

                if os.system(cmd) != 0:
                    raise Exception('GFS download failed (via cURL). ' + fname + ' could not be downloaded. ' + cmd)
                else:
                    validate_download_or_remove(fileout)

        date_hist = date_hist + timedelta(hours=6)

    # now download the forecast from date_latest, already identified as the latest initialisation of gfs
    fhours = int( (fdays-delta_days) * 24 )

    for i in range(1, fhours + 1):
        fname = create_fname(date_latest, i)
        fileout = os.path.join(dirout, fname)

        # only download if the file doesn't already exist
        if not (os.path.isfile(fileout)):
            url = BASE_URL + \
                date_latest.strftime("%H") \
                + 'z.pgrb2.0p25.f' \
                + str(i).zfill(3) \
                + URL_PARAMS \
                + time_param(date_latest)

            cmd = make_cURL(url, fileout)
            print(cmd)

            if os.system(cmd) != 0:
                raise Exception('GFS download failed (via cURL). ' + fname + ' could not be downloaded. ' + cmd)
            else:
                validate_download_or_remove(fileout)

    print('GFS download completed (in '+str(datetime.now() - start_time)+' h:m:s)')
    return delta_days 
