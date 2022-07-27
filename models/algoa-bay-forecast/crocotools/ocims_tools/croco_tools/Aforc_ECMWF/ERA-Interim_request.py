#!/usr/bin/env python

# Script to download ERA Interim data
#  This file is part of CROCOTOOLS
#
#  CROCOTOOLS is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
#  by the Free Software Foundation; either version 2 of the License,
#  or (at your option) any later version.
#
#  CROCOTOOLS is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
#  MA  02111-1307  USA
#
#  Copyright (c) 2005-2006 by Pierrick Penven 
#  e-mail:Pierrick.Penven@ird.fr  
#
#  Updated    January 2016 (E. Cadier and S. Illig)
#  Updated    December 2016 (P. Marchesiello) for 6-hourly & wave fields
#


from ecmwfapi import ECMWFDataServer
import shutil
import os
import calendar
from subprocess import call


######################
# Parameters
######################

# Period
yearStart  = 2000
yearEnd    = 2000
monthStart = 1
monthEnd   = 3

# Area of interest
ownArea = 0 	# 0 if area from a crocotools_param.m file
		# 1 if own area

# To complete if ownArea==0
paramFile='../Run/crocotools_param.m'

# To complete if ownArea==1
#lonmin = str(-10)
#lonmax = str(17.25)
#latmin = str(-30)
#latmax = str(7)

# Output directory
outdir = os.getcwd() + "/out"
outdir = '../Run/DATA/ERAI'

######################
dl = 3
if ownArea==0:
   lines = [line.rstrip('\n') for line in open(paramFile)]
   for line in lines:
       if "lonmin" in line:
	   for i in range(len(line)):
	      if line[i]=="=":
		   iStart= i+1
	      elif line[i]==";":
		   iEnd = i
	   lonmin = line[iStart:iEnd]
       elif "lonmax" in line:
	   for i in range(len(line)):
	      if line[i]=="=":
		   iStart= i+1
	      elif line[i]==";":
		   iEnd = i
	   lonmax = line[iStart:iEnd]
       elif "latmin" in line:
	   for i in range(len(line)):
	      if line[i]=="=":
		   iStart= i+1
	      elif line[i]==";":
		   iEnd = i
	   latmin = line[iStart:iEnd]
       elif "latmax" in line:
	   for i in range(len(line)):
	      if line[i]=="=":
		   iStart= i+1
	      elif line[i]==";":
		   iEnd = i
	   latmax = line[iStart:iEnd]

lonmin = str(float(lonmin)-dl)
lonmax = str(float(lonmax)+dl)
latmin = str(float(latmin)-dl)
latmax = str(float(latmax)+dl)
print 'lonmin-dl = ',lonmin
print 'lonmax+dl =',lonmax 
print 'latmin-dl =',latmin
print 'latmax+dl =',latmax



######################
# Retrieve data
######################

server = ECMWFDataServer()

### Loop on the years and months
for year in range(yearStart, yearEnd+1):
   
   if year==yearStart and year==yearEnd:
      monthStartYear = monthStart
      monthEndYear   = monthEnd
   elif year==yearStart and year!=yearEnd:
      monthStartYear = monthStart
      monthEndYear   = 12
   elif year!=yearStart and year==yearEnd:
      monthStartYear = 1
      monthEndYear   = monthEnd
   else:
      monthStartYear = 1
      monthEndYear   = 12

   for month in range(monthStartYear, monthEndYear+1):

	if month==12:
	   yearBefore  = year
	   monthBefore = month - 1
	   yearNext    = year + 1
	   monthNext   = 1
        elif month==1:
	   yearBefore  = year - 1
	   monthBefore = 12
	   yearNext    = year
	   monthNext   = month + 1
	else:
	   yearBefore  = year
	   monthBefore = month - 1
	   monthNext   = month + 1
	   yearNext    = year 

	if month<10:
	   month2 = "0"+str(month)
	else:
	   month2 = str(month)

	if monthBefore<10:
	   monthBefore2 = "0"+str(monthBefore)
	else:
	   monthBefore2 = str(monthBefore)

	if monthNext<10:
	   monthNext2 = "0"+str(monthNext)
	else:
	   monthNext2 = str(monthNext)

	if monthBefore==1 or monthBefore==3 or monthBefore==5 or monthBefore==7 or monthBefore==8 or monthBefore==10 or monthBefore==12:
	   nDays=31
	elif monthBefore==4 or monthBefore==6 or monthBefore==9 or monthBefore==11:
	   nDays=30
	else:
	   if calendar.isleap(yearBefore):
	     nDays=29
	   else:
	     nDays=28 

	date = str(yearBefore) + "-" + monthBefore2 + "-"+ str(nDays) + "/to/" + str(yearNext) + "-" + monthNext2 + "-01"
	print 'date=',date

	# 1. Sea surface temperature
	filename = 'EI_ecmwf_SSTK_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "34.128",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 2. 2 metre temperature
	filename = 'EI_ecmwf_T2M_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "167.128",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 3. 10 metre u wind component
	filename = 'EI_ecmwf_U10M_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "165.128",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 4. 10 metre v wind component
	filename = 'EI_ecmwf_V10M_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "166.128",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 5. Specific humidity
	filename = 'EI_ecmwf_Q_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "pl",
  	    "levelist" : "1000",
	    "param": "133.128",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 6. Significant wave height
	filename = 'EI_ecmwf_SWH_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "wave",
	    "param": "229.140",
	    "stream": "wave",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 7. Mean wave direction
	filename = 'EI_ecmwf_MWD_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "wave",
	    "param": "230.140",
	    "stream": "wave",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 8. Peak wave period
	filename = 'EI_ecmwf_PP1D_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "wave",
	    "param": "231.140",
	    "stream": "wave",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 9. Coefficient of drag with waves
	filename = 'EI_ecmwf_DRAGW_'+ str(year) + str(month2) +'.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "wave",
	    "param": "233.140",
	    "stream": "wave",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/06/12/18",
	    "type": "an",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 10. Total Precipitations
	filename = 'EI_ecmwf_TP_'+ str(year) + str(month2) +'_step3.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "228.128",
	    "step": "3",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_TP_'+ str(year) + str(month2) +'_step9.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "228.128",
	    "step": "9",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_TP_'+ str(year) + str(month2) +'_step15.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "228.128",
	    "step": "15",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)


	# 11. Surface solar radiation
	filename = 'EI_ecmwf_SSR_'+ str(year) + str(month2) +'_step3.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "176.128",
	    "step": "3",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_SSR_'+ str(year) + str(month2) +'_step9.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "176.128",
	    "step": "9",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_SSR_'+ str(year) + str(month2) +'_step15.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "176.128",
	    "step": "15",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 12. Surface thermal radiation
	filename = 'EI_ecmwf_STR_'+ str(year) + str(month2) +'_step3.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "177.128",
	    "step": "3",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_STR_'+ str(year) + str(month2) +'_step9.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "177.128",
	    "step": "9",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_STR_'+ str(year) + str(month2) +'_step15.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "177.128",
	    "step": "15",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 13. Surface thermal radiation downwards
	filename = 'EI_ecmwf_STRD_'+ str(year) + str(month2) +'_step3.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "175.128",
	    "step": "3",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_STRD_'+ str(year) + str(month2) +'_step9.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "175.128",
	    "step": "9",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_STRD_'+ str(year) + str(month2) +'_step15.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "175.128",
	    "step": "15",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 14. East-west surface stress
	filename = 'EI_ecmwf_EWSS_'+ str(year) + str(month2) +'_step3.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "180.128",
	    "step": "3",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_EWSS_'+ str(year) + str(month2) +'_step9.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "180.128",
	    "step": "9",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_EWSS_'+ str(year) + str(month2) +'_step15.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "180.128",
	    "step": "15",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)

	# 15. North-south surface stress
	filename = 'EI_ecmwf_NSSS_'+ str(year) + str(month2) +'_step3.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "181.128",
	    "step": "3",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_NSSS_'+ str(year) + str(month2) +'_step9.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "181.128",
	    "step": "9",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)
	filename = 'EI_ecmwf_NSSS_'+ str(year) + str(month2) +'_step15.nc'
	server.retrieve({
	    "class": "ei",
	    "dataset": "interim",
	    "date": date,
	    "expver": "1",
	    "levtype": "sfc",
	    "param": "181.128",
	    "step": "15",
	    "stream": "oper",
	    "format" : "netcdf",
	    "target": filename,
	    "time": "00/12",
	    "type": "fc",
	    "area" : latmax+"/"+lonmin+"/"+latmin+"/"+lonmax,
	    "grid": "0.25/0.25",
	})
	shutil.move(filename,outdir+"/"+filename)


