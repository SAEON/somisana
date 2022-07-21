function [day,month,year,imonth,thedate]=get_date(fname,tindex,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function [day,month,year,thedate]=getdate(fname,tindex);
%
% get the date from the time index of a CROCO netcdf file
%   (for a 360 days year)
%
% if Yorig (year origin) is provided, the date is computed
% as a "real time" date.
%
% input:
%
%  fname    CROCO netcdf file name (average or history) (string)
%  tindex   time index (integer)
%
% output:
%
%  day      day (scalar)
%  month    month (string)
%  year     year (scalar)
%  thedate  date (string)
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(Yorig)
  Yorig=nan;
end
%
nc=netcdf(fname);
time=nc{'scrum_time'}(tindex);
if (isempty(time))
  time=nc{'ocean_time'}(tindex);
end
if (isempty(time))
  year=0;
  imonth=0;
  day=0;
  month='';
  thedate='';
  return
end
close(nc)
%
Month=[ 'Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';...
        'Sep';'Oct';'Nov';'Dec'];
%
if isnan(Yorig)
%
% Climatolgoy simulation
%
  year=floor(1+time/(24*3600*360));
  if time<=0
    time=time-(year-1)*24*3600*360;
  end
  imonth=floor(1+rem(time/(24*3600*30),12));
  day=floor(1+rem(time/(24*3600),30));
else
%
% "Real time" simulation
%
  [year,imonth,day,h,mi,s]=datevec(time/(24*3600)+datenum(Yorig,1,1));
end
%
month=Month(imonth,:);
thedate=[num2str(day),' ',month,' ',num2str(year)];
%
return
