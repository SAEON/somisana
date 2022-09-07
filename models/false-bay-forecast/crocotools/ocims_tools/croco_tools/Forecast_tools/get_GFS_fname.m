function fname=get_GFS_fname(time,gfs_run_time,gfstype)
%
%  fname=get_GFS_fname(time,gfs_run_time)
%
%  Give the GFS url for a given date.
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
%  Updated    9-Sep-2006 by Pierrick Penven
%  Updated    20-Aug-2008 by Matthieu Caillaud & P. Marchesiello
%  Updated   12-Feb-2016 by P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% set URL
%
url='http://nomads.ncep.noaa.gov:9090';
%
% set file types
%
if gfstype==0
  gfsname ='fnl';
  gfsname1='fnlflx';     % 1/2 GDAS data
else
  gfsname ='gfs';
%  gfsname1='gfs_0p25';  % 1/4 deg res GFS data
  gfsname1='gfs_0p50';   % 1/2 deg res GFS data
end
%
% Get the date
%
[y,m,d,h,mi,s]=datevec(time);
stry=num2str(y);
if m<10
  strm=['0',num2str(m)];
else
  strm=num2str(m);
end
if d<10
  strd=['0',num2str(d)];
else
  strd=num2str(d);
end
if gfs_run_time < 10
  strh='_0';
else
  strh='_';
end
%
% Get the grid
%
if gfstype==0
  gfsdir =[url,'/dods/',gfsname,'/',gfsname,stry,strm,strd,'/'];
  fname=[gfsdir,gfsname1,strh,num2str(gfs_run_time),'z'];
else
  gfsdir =[url,'/dods/',gfsname1,'/',gfsname,stry,strm,strd,'/'];
  fname=[gfsdir,gfsname1,strh,num2str(gfs_run_time),'z'];
end
fname
