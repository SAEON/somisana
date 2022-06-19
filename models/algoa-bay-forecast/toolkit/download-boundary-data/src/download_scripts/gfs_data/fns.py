import os
from pathlib import Path

base_url = 'https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25_1hr.pl?file=gfs.t'
base_url_test = 'https://nomads.ncep.noaa.gov/dods/gfs_0p25_1hr/gfs'

def getDownloadUri(dt, offset, extent):
    return base_url \
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

def getFilePath(dirout, dt, dt_offset):
    return dirout \
      + dt.strftime("%Y") \
      + dt.strftime("%m") \
      + dt.strftime("%d") \
      + dt.strftime("%H") \
      + '_f' \
      + str(dt_offset).zfill(3) \
      + '.grb'

 # using 1kB as the check - files smaller than this indicates download failed
def testForDownloadError(fileout):
    if Path(fileout).stat().st_size < 1000: 
        print('WARNING: '+ fileout + ' could not be downloaded')
        os.remove(fileout)

###
### These are exported
###

def testUrl(dt):
    return  base_url_test \
      + dt.strftime("%Y") \
      + dt.strftime("%m") \
      + dt.strftime("%d") \
      + '/gfs_0p25_1hr_' \
      + dt.strftime("%H") \
      + 'z'

def downloadFile(dirout, dt, offset, geographic_extent):
    file = getFilePath(dirout, dt, offset)
    if not(os.path.isfile(file)):
        url = getDownloadUri(dt, offset, geographic_extent)
        cmd = 'curl -silent \'' + url + '\'' + ' -o ' + file
        print('downloading to', file)
        os.system(cmd)
        testForDownloadError(file)
