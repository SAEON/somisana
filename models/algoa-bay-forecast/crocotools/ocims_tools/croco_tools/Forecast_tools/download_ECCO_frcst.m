function ecco_name=download_ECCO_frcst(lonmin,lonmax,latmin,latmax,...
                                         FRCST_dir,FRCST_prefix,url,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Extract a subgrid from ECCO to get a CROCO forcing
%   Store that into monthly files.
%   Take care of the Greenwitch Meridian.
% 
% 
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    8-Sep-2006 by Pierrick Penven
%  Updated    20-Aug-2008 by Matthieu Caillaud & P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Get the date
%
rundate_str=date;
rundate=datenum(rundate_str)-datenum(Yorig,1,1);
[y,m,d,h,mi,s]=datevec(rundate_str);
%
% start
%
disp([' '])
disp(['Get data for ',rundate_str])
disp(['Minimum Longitude: ',num2str(lonmin)])
disp(['Maximum Longitude: ',num2str(lonmax)])
disp(['Minimum Latitude: ',num2str(latmin)])
disp(['Maximum Latitude: ',num2str(latmax)])
disp([' '])
%
% Create the directory
%
disp(['Making output data directory ',FRCST_dir])
eval(['!mkdir ',FRCST_dir])
%
% Start 
%
disp(['Process the dataset: ',url])
%
% Get the latest ECCO time
%
%
% first ecco time: 06-Jan-2006 (315696)
% first ecco time: 07-Jan-2006 (324456) !!! should be reset every year !!!
ecco_time_start_year=359520;

%
ecco_time_start=ecco_time_start_year/24+datenum(1970,1,1)-datenum(Yorig,1,1);
ecco_times=[ecco_time_start:10:ecco_time_start+10000];
%htime_ecco=24*(ecco_times+datenum(Yorig,1,1)-datenum(1970,1,1));
%
% Get the closest ecco time
%
ecco_indx=max(find(ecco_times<=rundate));
foundfile=0;
%
while foundfile==0
  ecco_time=ecco_times(ecco_indx);
  disp([' Testing date: ' datestr(ecco_time+datenum(Yorig,1,1))])
  [ecco_y,ecco_m,ecco_d,ecco_h,ecco_mi,ecco_s]=...
  datevec(ecco_time+datenum(Yorig,1,1));
  daysinyear=ecco_time+datenum(Yorig,1,1)-datenum(ecco_y,1,1);
  necco=round(daysinyear/10);
  nhours=necco*240;
  if nhours < 1000
    endname=['_00',num2str(nhours),'_240.cdf'];
  elseif nhours < 10000
    endname=['_0',num2str(nhours),'_240.cdf'];
  else nhours < 10000
    endname=['_',num2str(nhours),'_240.cdf'];
  end
%  
  if necco <= 9
    prefix=[url,num2str(ecco_y),'/n10day_01_0',num2str(necco),'/'];
    suffix=['_08_08.00001',endname];
  elseif necco <= 18
    prefix=[url,num2str(ecco_y),'/n10day_10_',num2str(necco),'/'];
    suffix=['_08_08.02160',endname];
  elseif necco <= 27
    prefix=[url,num2str(ecco_y),'/n10day_19_',num2str(necco),'/'];
    suffix=['_08_08.04320',endname];
  elseif necco <= 37
    prefix=[url,num2str(ecco_y),'/n10day_28_',num2str(necco),'/'];
    suffix=['_08_08.06480',endname];
  end
%
%  test if the file exist
%
  vname='Have';
  fname=[prefix,vname,suffix];
  warning off
  try
    x=loaddap('-A -e +v ',fname);
    foundfile=1;
  catch
    foundfile=0;
  end
  if foundfile==1 & ~isempty(x)
    disp('  File found')
  else
    foundfile=0;
    disp('  File does not exist')
    ecco_indx=ecco_indx-1;
    if ecco_indx==0
     error('DOWNLOAD_ECCO_FRCST: No file found...')
    end
  end
  warning on
end
%
tindex=x.time.DODS_ML_Size;
missval=x.Have.missing_value;
%
% Get the time
%
vname='Have';
fname=[prefix,'Have',suffix];
trange=['[',num2str(tindex-1),':',num2str(tindex-1),']'];
time=readdap(fname,'time',trange);
time=floor(time/24+datenum(1970,1,1));
disp(['    Date: ',datestr(time)])
time=time-datenum(Yorig,1,1);
ecco_name=[FRCST_dir,FRCST_prefix,num2str(time),'.cdf'];
%
%if isempty(dir(ecco_name))
if ~exist(ecco_name)
%
%
% Get a subset of the ECCO grid
%
  vname='Have';
  fname=[prefix,vname,suffix];
  [i1min,i1max,i2min,i2max,i3min,i3max,...
   i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
   jrange,jrange_v,krange,lon,lon_u,lat,lat_v,depth]=...
   get_ECCO_subgrid(fname,lonmin,lonmax,latmin,latmax);
%
% Extract ECCO
%
   extract_ECCO_frcst(FRCST_dir,FRCST_prefix,prefix,suffix,tindex,missval,...
                      lon,lon_u,lat,lat_v,depth,...
                      krange,jrange,jrange_v,...
                      i1min,i1max,i2min,i2max,i3min,i3max,...
                      i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
                      time,Yorig)
else
  disp('  ECCO file allready exist')
end
return
