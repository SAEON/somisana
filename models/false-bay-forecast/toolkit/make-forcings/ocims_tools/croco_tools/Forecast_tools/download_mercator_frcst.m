function mercator_name=download_mercator_frcst(lonmin,lonmax,latmin,latmax,...
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
l=1;
rundate_str=date;
rundate=datenum(rundate_str)-datenum(Yorig,1,1);
lh=5; % length of hindcast for mercator
lf=6; % length of forecast
%%% test if mercator forecast exist %%%
% mercator time is in julian hours since 1950
    time=readdap(url,'time',[])/24; 
time(1)
    time=time+datenum(1950,1,1);
time(1)
    time=time-datenum(Yorig,1,1);
    time(1)
    rundate
    size(time)
    stop
    while l==1
    try
        x=find(time==rundate+lf);
        foundtime=1;
    catch
        foundtime=0;
    end
        if foundtime==1 & ~isempty(x)
            disp('time is ok')
        else
            foundtime=0;
            disp('missing forecast')
        end
        
if foundtime==0;
    lf=lf-1;
    l=1;
else
    l=0;
end
    end

for i=1:lh
    time1(i)=datenum(rundate_str)-(lh+1-i);
end
time2=datenum(rundate_str);
for j=1:lf
    time3(j)=datenum(rundate_str)+j;
    
end
if foundtime==0
    time3=[time3 time3(end)];
        end
        
time=cat(2,time1,time2,time3);


% Get time from Opendap
time2=readdap(url,'time',[])/24;
time2=time2+datenum(1950,1,1);
%time2=time2-datenum(Yorig,1,1);

% Get time index
for i=1:length(time)
   tndx(i)=find(time2==time(i));
end

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
% 
%  test if the file exist
%
% 
foundfile=0;
  fname=url;
  warning off
  try
    x=loaddap('-A -e +v ', fname);
    foundfile=1;
  catch
    foundfile=0;
  end
  if foundfile==1 & ~isempty(x)
    disp('  File found')
  else
    foundfile=0;
    disp('  File does not exist')
  end
  warning on
%
%
%tindex=x.time.DODS_ML_Size;
%missval=x.ssh.missing_value; %PSY3V1
missval=x.ssh.ml__FillValue; %PSY3V2
% Get the time
%
trange=['[',num2str(min(tndx)-1),':',num2str(max(tndx)-1),']'];
fname=url;
%
%trange=['[',num2str(tindex-1),':',num2str(tindex-1),']'];
%time=readdap(fname,'time',trange);
%time=floor(time+datenum(1950,1,1));
%disp(['    Date: ',datestr(time)])
%time=time-datenum(Yorig,1,1);
time=time2(tndx)-datenum(Yorig,1,1);
mercator_name=[FRCST_dir,FRCST_prefix,num2str(rundate),'.cdf'];
%
%if isempty(dir(mercator_name))
if ~exist(mercator_name)
%
%
% Get a subset of the ECCO grid
%

  
  [i1min,i1max,i2min,i2max,i3min,i3max,...
   i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
   jrange,jrange_v,krange,lon,lon_u,lat,lat_v,depth]=...
   get_mercator_subgrid(url,lonmin,lonmax,latmin,latmax);
%
% Extract mercator
%
   extract_mercator_frcst(FRCST_dir,FRCST_prefix,url,tndx,missval,...
                      lon,lon_u,lat,lat_v,depth,...
                      krange,jrange,jrange_v,...
                      i1min,i1max,i2min,i2max,i3min,i3max,...
                      i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
                      time,Yorig)
else
  disp('  mercator file allready exist')
end

return
