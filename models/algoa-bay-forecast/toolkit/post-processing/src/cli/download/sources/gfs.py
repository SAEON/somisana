# -*- coding: utf-8 -*-
from pydap.client import open_url
from datetime import datetime, timedelta, time
import sys
import os
from pathlib import Path

"""
Download GFS forecast data for running a croco model
Data is downloaded from hdays before date_now till hdays after date_now
The GFS model is initialised every 6 hours, and provides hourly forecasts
For the historical data we download the forecast for hours 1 through 6 from each initialisation 
The forecast data gets downloaded from the latest available initialisation
"""


def gfs(date_now, hdays, fdays, domain, dirout):
    # extent hdays and fdays by 6 hours to make sure our download completely covers the simulation period
    hdays = hdays+0.25
    fdays = fdays+0.25

    url1 = 'https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25_1hr.pl?file=gfs.t'
    url2 = '&lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&var_DLWRF=on&var_DSWRF=on&var_LAND' + \
        '=on&var_PRATE=on&var_RH=on&var_TMP=on&var_UFLX=on&var_UGRD=on&var_ULWRF=on&var_USWRF=on&var_VFLX=on&var_VGRD=on&' + \
        'subregion=&leftlon='+str(domain[0])+'&rightlon='+str(domain[1])+'&toplat='+str(
            domain[3])+'&bottomlat='+str(domain[2])+'&dir=%2Fgfs.'

    # get latest gfs run that exists for this day
    # (this makes things a bit more complicated, but we might as well make use
    # of the latest initialisation that is available. It also means that our
    # system shouldn't fall over if the gfs forecast is delayed...)
    print('checking for latest GFS initialisation...')
    # just converting date_now from a date to a datetime- needed for comparing to other datetimes
    date_now = datetime.combine(date_now, time())
    # start with the last possible one for today
    date_latest = datetime(date_now.year, date_now.month,
                           date_now.day, 18, 0, 0)
    gfs_exists = False
    iters = 0
    while not(gfs_exists):
        url_check = 'https://nomads.ncep.noaa.gov/dods/gfs_0p25_1hr/gfs'+date_latest.strftime(
            "%Y")+date_latest.strftime("%m")+date_latest.strftime("%d")+'/gfs_0p25_1hr_'+date_latest.strftime("%H")+'z'
        try:
            check_gfs = open_url(url_check)
            gfs_exists = True
        except:
            # work backwards in 6 hour timesteps
            date_latest = date_latest+timedelta(hours=-6)
            iters = iters+1
            if iters > 4:
                print("GFS data is not presently available")
                sys.exit('')

    print("Latest available GFS initialisation found:", date_latest)
    print("GFS download started...")
    startTime = datetime.now()  # for timing purposes

    delta_days = (date_latest-date_now).total_seconds()/86400

    # go back in time to cover the full duration of the croco simulation
    date_hist = date_now + timedelta(days=-hdays)
    while date_hist < date_latest:
        url3 = date_hist.strftime("%Y")+date_hist.strftime("%m") + \
            date_hist.strftime("%d")+'%2F'+date_hist.strftime("%H")+'%2Fatmos'
        for frcst in range(1, 7):  # forecast hours 1 to 6
            fname = date_hist.strftime("%Y")+date_hist.strftime("%m")+date_hist.strftime(
                "%d")+date_hist.strftime("%H")+'_f'+str(frcst).zfill(3)+'.grb'
            fileout = dirout+fname
            if not(os.path.isfile(fileout)):  # only download if the file doesn't already exist
                url = url1 + \
                    date_hist.strftime("%H")+'z.pgrb2.0p25.f' + \
                    str(frcst).zfill(3)+url2+url3
                cmd = 'curl -silent \'' + url + '\'' + ' -o ' + fileout
                print('download = ', fileout)

                # If the cURL command fails, then throw an error
                if os.system(cmd) != 0:
                    raise Exception('GFS download failed (via cURL). ' + fname + ' could not be downloaded. ' + cmd)

                # Small files indicate that the download succeeded, but that the requested resource doesn't exist
                # The model should still run in in these cases
                if Path(fileout).stat().st_size < 1000:  # using 1kB as the check
                    print('WARNING: '+ fname + ' could not be downloaded', open(fileout, 'r').read())
                    os.remove(fileout)

        date_hist = date_hist + timedelta(hours=6)

    # now download the forecast from date_latest, already identified as the latest initialisation of gfs
    url3 = date_latest.strftime("%Y")+date_latest.strftime(
        "%m")+date_latest.strftime("%d")+'%2F'+date_latest.strftime("%H")+'%2Fatmos'
    fhours = int((fdays-delta_days)*24)

    for frcst in range(1, fhours+1):
        fname = date_latest.strftime("%Y")+date_latest.strftime("%m")+date_latest.strftime(
            "%d")+date_latest.strftime("%H")+'_f'+str(frcst).zfill(3)+'.grb'
        fileout = dirout+fname

        # only download if the file doesn't already exist
        if not(os.path.isfile(fileout)):
            url = url1 + \
                date_latest.strftime("%H")+'z.pgrb2.0p25.f' + \
                str(frcst).zfill(3)+url2+url3
            cmd = 'curl --silent \'' + url + '\'' + ' -o ' + fileout
            print('download = ', fileout)
            
            # If the cURL command fails, then throw an error
            if os.system(cmd) != 0:
                raise Exception('GFS download failed (via cURL). ' + fname + ' could not be downloaded. ' + cmd)
            
            # Small files indicate that the download succeeded, but that the requested resource doesn't exist
            # The model should still run in in these cases
            if Path(fileout).stat().st_size < 1000:  # using 1kB as the check
                print('WARNING: '+fname+' could not be downloaded', open(fileout, 'r').read())
                os.remove(fileout)

    print('GFS download completed (in '+str(datetime.now() - startTime)+' h:m:s)')
    return delta_days  # return this as we need it when generating the croco forcing files