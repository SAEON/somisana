# -*- coding: utf-8 -*-
"""

Functions to download forecast data from different sources

"""
from math import floor,ceil
import numpy as np
from pydap.client import open_url
from datetime import datetime, timedelta, date, time
import calendar
import sys, os
from pathlib import Path

def gfs(date_now,hdays,fdays,domain,dirout):

    """
    Download GFS forecast data for running a croco model
    Data is downloaded from hdays before date_now till hdays after date_now
    The GFS model is initialised every 6 hours, and provides hourly forecasts
    For the historical data we download the forecast for hours 1 through 6 from each initialisation 
    The forecast data gets downloaded from the latest available initialisation
    
    """   
          
    # extent hdays and fdays by 6 hours to make sure our download completely covers the simulation period
    hdays=hdays+0.25
    fdays=fdays+0.25
    
    url1='https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25_1hr.pl?file=gfs.t'
    url2='&lev_10_m_above_ground=on&lev_2_m_above_ground=on&lev_surface=on&var_DLWRF=on&var_DSWRF=on&var_LAND'+\
  '=on&var_PRATE=on&var_RH=on&var_TMP=on&var_UFLX=on&var_UGRD=on&var_ULWRF=on&var_USWRF=on&var_VFLX=on&var_VGRD=on&'+\
        'subregion=&leftlon='+str(domain[0])+'&rightlon='+str(domain[1])+'&toplat='+str(domain[3])+'&bottomlat='+str(domain[2])+'&dir=%2Fgfs.'
    
    # get latest gfs run that exists for this day 
    # (this makes things a bit more complicated, but we might as well make use 
    # of the latest initialisation that is available. It also means that our 
    # system shouldn't fall over if the gfs forecast is delayed...)
    print('checking for latest GFS initialisation...')
    date_now=datetime.combine(date_now, time()) # just converting date_now from a date to a datetime- needed for comparing to other datetimes
    date_latest=datetime(date_now.year,date_now.month,date_now.day,18,0,0) # start with the last possible one for today 
    gfs_exists=False
    iters=0
    while not(gfs_exists):
        url_check='https://nomads.ncep.noaa.gov/dods/gfs_0p25_1hr/gfs'+date_latest.strftime("%Y")+date_latest.strftime("%m")+date_latest.strftime("%d")+'/gfs_0p25_1hr_'+date_latest.strftime("%H")+'z'
        try:
            check_gfs = open_url(url_check)
            gfs_exists=True
        except:
            date_latest=date_latest+timedelta(hours=-6) # work backwards in 6 hour timesteps
            iters=iters+1
            if iters>4:
                print("GFS data is not presently available")
                sys.exit('')
    
    print("Latest available GFS initialisation found:", date_latest)
    print("GFS download started...")
    startTime=datetime.now() # for timing purposes
    
    delta_days=(date_latest-date_now).total_seconds()/86400

    # go back in time to cover the full duration of the croco simulation
    date_hist=date_now + timedelta(days=-hdays)
    while date_hist<date_latest:
        
        url3=date_hist.strftime("%Y")+date_hist.strftime("%m")+date_hist.strftime("%d")+'%2F'+date_hist.strftime("%H")+'%2Fatmos'
        
        for frcst in range(1,7): # forecast hours 1 to 6       
            
            fname=date_hist.strftime("%Y")+date_hist.strftime("%m")+date_hist.strftime("%d")+date_hist.strftime("%H")+'_f'+str(frcst).zfill(3)+'.grb'
            fileout=dirout+fname
            
            if not(os.path.isfile(fileout)): # only download if the file doesn't already exist
                
                url=url1+date_hist.strftime("%H")+'z.pgrb2.0p25.f'+str(frcst).zfill(3)+url2+url3
                cmd='curl -silent \''  + url +'\'' + ' -o ' + fileout
                #cmd='curl --silent \''  + url +'\'' + ' -o ' + fileout
                print('download = ', fileout)
                os.system( cmd )
                # unfortunately this doesn't actually throw an error if the file to be downloaded does not exist, 
                # but it does create a small and useless fileout.
                # So check the size of fileout and delete it if it is 'small'
                if Path(fileout).stat().st_size < 1000: # using 1kB as the check
                    print('WARNING: '+fname+' could not be downloaded')
                    os.remove(fileout) 
        
        date_hist=date_hist + timedelta(hours=6)
        
        
        
        
    # now download the forecast from date_latest, already identified as the latest initialisation of gfs
    url3=date_latest.strftime("%Y")+date_latest.strftime("%m")+date_latest.strftime("%d")+'%2F'+date_latest.strftime("%H")+'%2Fatmos'
    fhours=int((fdays-delta_days)*24)
    #fhours=int(fdays*24)
    for frcst in range(1,fhours+1): # fhours + 1 to be inclusive of fhours     
        
        fname=date_latest.strftime("%Y")+date_latest.strftime("%m")+date_latest.strftime("%d")+date_latest.strftime("%H")+'_f'+str(frcst).zfill(3)+'.grb'
        fileout=dirout+fname
        
        if not(os.path.isfile(fileout)): # only download if the file doesn't already exist
        
            url=url1+date_latest.strftime("%H")+'z.pgrb2.0p25.f'+str(frcst).zfill(3)+url2+url3
            cmd='curl --silent \''  + url +'\'' + ' -o ' + fileout
            print('download = ', fileout)
            #os.system( cmd )
            # unfortunately this doesn't actually throw an error if the file to be downloaded does not exist, 
            # but it does create a small and useless fileout.
            # So check the size of fileout and delete it if it is 'small'
            if Path(fileout).stat().st_size < 1000: # using 1kB as the check
                print('WARNING: '+fname+' could not be downloaded')
                os.remove(fileout) 
        
    print('GFS download completed (in '+str(datetime.now() - startTime)+' h:m:s)')
    
    return delta_days # return this as we need it when generating the croco forcing files
       
def mercator(path2motuClient,usrname,passwd,domain,date_now,hdays,fdays,varList,depths,mercator_dir):
 
    """
    Download latest daily ocean forecasts from CMEMS GLOBAL-ANALYSIS-FORECAST-PHY-001-024
    
    Dependencies: (see https://marine.copernicus.eu/faq/what-are-the-motu-and-python-requirements/)
    
    python -m pip install motuclient
    
    Adapted script from Mostafa Bakhoday-Paskyabi <Mostafa.Bakhoday@nersc.no>
    """
    
    # extent hdays and fdays by 1 day to make sure our download completely covers the simulation period
    hdays=hdays+1
    fdays=fdays+1
    startDate = date_now + timedelta(days = -hdays) 
    endDate = date_now + timedelta(days = fdays)
    
    # loop on the variables to generate the variable string so that the number of requested variables is flexible
    # so = Salinity in psu, thetao = Temperature in degrees C, zos = SSH in m, uo = Eastward velocity in m/s, vo = Northward velocity in m/s
    var_str=''
    for var in varList:
        var_str=var_str+' --variable '+var  
    
    # output filename
    fname = 'mercator_'+str(date_now.strftime('%Y%m%d'))+'.nc'
    
    # create the runcommand string
    runcommand = 'python '+path2motuClient+'motuclient.py --quiet'+ \
            ' --user '+usrname+' --pwd '+passwd+ \
            ' --motu http://nrt.cmems-du.eu/motu-web/Motu'+ \
            ' --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS'+ \
            ' --product-id global-analysis-forecast-phy-001-024'+ \
            ' --longitude-min '+str(domain[0])+' --longitude-max '+str(domain[1])+ \
            ' --latitude-min '+str(domain[2])+' --latitude-max '+str(domain[3])+ \
            ' --date-min "'+str(startDate.strftime('%Y-%m-%d'))+'" --date-max "'+str(endDate.strftime('%Y-%m-%d'))+'"'+ \
            ' --depth-min '+str(depths[0])+' --depth-max '+str(depths[1])+ \
            var_str+ \
            ' --out-dir '+mercator_dir+' --out-name '+fname
   

    
    if os.path.exists(mercator_dir+fname)==False:
    	# run the runcommand, i.e. download the data specified above
        print('downloading latest mercator ocean forecast from CMEMS...')
        startTime=datetime.now()
        try:
            os.system(runcommand)
            print('mercator download completed (in '+str(datetime.now() - startTime)+' h:m:s)')
        except:
            # for now we'll just terminate today's forecast if the mercator download fails
            sys.exit('mercator data not available for today- forecast not executed')
            # an alternative approach might be to return a flag from this function to say whether the file was downloaded or not
            # then in run_frcst.py we could use that flag to either make a new croco file from the downloaded mercator file
            # or if the file wasn't downloaded then we could use yesterday's croco file and just repeat the last available time-step to make a new one
    else:
        print(mercator_dir+fname+' already exists - not downloading mercator data')
