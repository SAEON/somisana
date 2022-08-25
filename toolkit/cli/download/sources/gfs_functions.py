import os
from pathlib import Path
from datetime import datetime, timedelta
import requests as r

BASE_URL = 'https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25_1hr.pl?file=gfs.t'


def yyyymmdd(dt):
    return dt.strftime("%Y") \
        + dt.strftime("%m") \
        + dt.strftime("%d")


def time_param(dt):
    return yyyymmdd(dt) \
        + '/' \
        + dt.strftime("%H") \
        + '/atmos'


def create_fname(dt, i):
    return yyyymmdd(dt) \
        + dt.strftime("%H") \
        + '_f' \
        + str(i).zfill(3) \
        + '.grb'


def validate_download_or_remove(fileout):
    if Path(fileout).stat().st_size < 1000:
        print('WARNING:', fileout, '< 1kB (flagged as invalid)',
              open(fileout, 'r').read())
        os.remove(fileout)


def make_cURL(url, fileout):
    return 'curl --silent \'' \
        + url \
        + '\'' \
        + ' -o ' \
        + fileout


def make_url(dt, i, URL_PARAMS):
    return BASE_URL \
        + dt.strftime("%H") \
        + 'z.pgrb2.0p25.f' \
        + str(i).zfill(3) \
        + URL_PARAMS \
        + time_param(dt)


def exec_cmd(cmd, fileout):
    if os.system(cmd) != 0:
        raise Exception('GFS download failed from command: ' + cmd)
    else:
        validate_download_or_remove(fileout)


def download_file(dt, i, dirout, PARAMS):
    fname = create_fname(dt, i)
    fileout = os.path.join(dirout, fname)

    if not (os.path.isfile(fileout)):
        url = make_url(dt, i, PARAMS)
        cmd = make_cURL(url, fileout)
        print(cmd)
        exec_cmd(cmd, fileout)
    else:
        print('File already exists', fileout)

def get_latest_available_dt(dt):
    latest_available_date = datetime(dt.year, dt.month, dt.day, 18, 0, 0)
    gfs_exists = False
    iters = 0

    while not (gfs_exists):
        if iters > 4:
            print("GFS data is not presently available")
            exit(1)

        dataset_url = \
            'https://nomads.ncep.noaa.gov/dods/gfs_0p25_1hr/gfs' \
            + yyyymmdd(latest_available_date) \
            + '/gfs_0p25_1hr_' \
            + latest_available_date.strftime("%H") \
            + 'z'

        print('Testing GFS availability', dataset_url)
        result = r.head(dataset_url)
        xdap = result.headers.get('XDAP')

        if xdap:
            print("Latest available GFS initialisation found at",dataset_url, '\n', 'X-DAP HTTP Header', xdap, '\n', '\n')
            gfs_exists = True
        else:
            latest_available_date = latest_available_date + timedelta(hours=- 6)
            iters += 1
    
    return latest_available_date