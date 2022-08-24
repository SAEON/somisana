import os
from pathlib import Path

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
        print('WARNING:', fileout, '< 1kB (flagged as invalid)', open(fileout, 'r').read())
        os.remove(fileout)

def make_cURL(url, fileout):
    return 'curl --silent \'' \
        + url \
        + '\'' \
        + ' -o ' \
        + fileout