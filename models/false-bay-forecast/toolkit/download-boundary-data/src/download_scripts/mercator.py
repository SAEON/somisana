# -*- coding: utf-8 -*-
from datetime import datetime, timedelta
import sys
import os

"""
Download latest daily ocean forecasts from CMEMS GLOBAL-ANALYSIS-FORECAST-PHY-001-024
Dependencies: (see https://marine.copernicus.eu/faq/what-are-the-motu-and-python-requirements/)
python -m pip install motuclient
Adapted script from Mostafa Bakhoday-Paskyabi <Mostafa.Bakhoday@nersc.no>
"""


def mercator(usrname, passwd, domain, date_now, hdays, fdays, varList, depths, mercator_dir):
    # extent hdays and fdays by 1 day to make sure our download completely covers the simulation period
    hdays = hdays+1
    fdays = fdays+1
    startDate = date_now + timedelta(days=-hdays)
    endDate = date_now + timedelta(days=fdays)

    # loop on the variables to generate the variable string so that the number of requested variables is flexible
    # so = Salinity in psu, thetao = Temperature in degrees C, zos = SSH in m, uo = Eastward velocity in m/s, vo = Northward velocity in m/s
    var_str = ''
    for var in varList:
        var_str = var_str+' --variable '+var

    # output filename
    fname = 'mercator_'+str(date_now.strftime('%Y%m%d'))+'.nc'

    # create the runcommand string
    runcommand = 'motuclient --quiet' + \
        ' --user '+usrname+' --pwd '+passwd + \
        ' --motu http://nrt.cmems-du.eu/motu-web/Motu' + \
        ' --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS' + \
        ' --product-id global-analysis-forecast-phy-001-024' + \
        ' --longitude-min '+str(domain[0])+' --longitude-max '+str(domain[1]) + \
        ' --latitude-min '+str(domain[2])+' --latitude-max '+str(domain[3]) + \
        ' --date-min "'+str(startDate.strftime('%Y-%m-%d'))+'" --date-max "'+str(endDate.strftime('%Y-%m-%d'))+'"' + \
        ' --depth-min '+str(depths[0])+' --depth-max '+str(depths[1]) + \
        var_str + \
        ' --out-dir '+mercator_dir+' --out-name '+fname

    if os.path.exists(mercator_dir+fname) == False:
        # run the runcommand, i.e. download the data specified above
        print('downloading latest mercator ocean forecast from CMEMS...')
        startTime = datetime.now()
        try:
            os.system(runcommand)
            print('mercator download completed (in ' +
                  str(datetime.now() - startTime)+' h:m:s)')
        except:
            # for now we'll just terminate today's forecast if the mercator download fails
            sys.exit('mercator data not available for today- forecast not executed')
            # an alternative approach might be to return a flag from this function to say whether the file was downloaded or not
            # then in run_frcst.py we could use that flag to either make a new croco file from the downloaded mercator file
            # or if the file wasn't downloaded then we could use yesterday's croco file and just repeat the last available time-step to make a new one
    else:
        print(mercator_dir+fname+' already exists - not downloading mercator data')