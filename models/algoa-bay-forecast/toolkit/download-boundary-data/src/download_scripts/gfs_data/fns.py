import os
from pathlib import Path
from multiprocessing import Process
from time import sleep
from datetime import datetime

MAX_CONCURRENT_DOWNLOADS = 5


def make_download_url(dt, offset, extent):
    return 'https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25_1hr.pl?file=gfs.t' \
        + dt.strftime("%H") \
        + 'z.pgrb2.0p25.f' \
        + str(offset).zfill(3) \
        + '&lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&var_DLWRF=on&var_DSWRF=on&var_LAND' \
        + '=on&var_PRATE=on&var_RH=on&var_TMP=on&var_UFLX=on&var_UGRD=on&var_ULWRF=on&var_USWRF=on&var_VFLX=on&var_VGRD=on&' \
        + 'subregion=&leftlon=' \
        + str(extent[0]) \
        + '&rightlon=' \
        + str(extent[1]) \
        + '&toplat=' \
        + str(extent[3]) \
        + '&bottomlat=' \
        + str(extent[2]) \
        + '&dir=%2Fgfs.' \
        + dt.strftime("%Y") \
        + dt.strftime("%m") \
        + dt.strftime("%d") \
        + '%2F' \
        + dt.strftime("%H") \
        + '%2Fatmos'


def make_file_path(dirout, dt, dt_offset):
    return dirout \
        + dt.strftime("%Y") \
        + dt.strftime("%m") \
        + dt.strftime("%d") \
        + dt.strftime("%H") \
        + '_f' \
        + str(dt_offset).zfill(3) \
        + '.grb'


def download_file(dirout, dt, offset, geographic_extent):
    file = make_file_path(dirout, dt, offset)
    if not(os.path.isfile(file)):
        url = make_download_url(dt, offset, geographic_extent)
        cmd = 'curl -silent \'' + url + '\'' + ' -o ' + file
        print(datetime.now().strftime("%H:%M:%S"), 'GFS download', file)
        os.system(cmd)
        # Test for download error (1000 ~= 1kb)
        if Path(file).stat().st_size < 1000:
            print('WARNING: Tiny file indicates' + file + ' download error')
            os.remove(file)


def make_test_url(dt):
    return 'https://nomads.ncep.noaa.gov/dods/gfs_0p25_1hr/gfs' \
        + dt.strftime("%Y") \
        + dt.strftime("%m") \
        + dt.strftime("%d") \
        + '/gfs_0p25_1hr_' \
        + dt.strftime("%H") \
        + 'z'


def run_fns(fns):
    processes = []
    while (len(fns) > 0):
        # Clean up finished processes
        for i, p in enumerate(processes):
            if (p.exitcode == 0):
                processes.pop(i)

        # Start new processes if there is room
        if (len(processes) < MAX_CONCURRENT_DOWNLOADS):
            f = fns.pop(0)
            p = Process(target=f)
            p.start()
            processes.append(p)
        else:
            sleep(2)  # System is busy - check again in 2 seconds

        # Wait for remaining child processes to finish
    for p in processes:
        p.join()


def make_fn(dirout, lookback, offset, geographic_extent):
    def f():
        download_file(dirout, lookback, offset, geographic_extent)
    return f
