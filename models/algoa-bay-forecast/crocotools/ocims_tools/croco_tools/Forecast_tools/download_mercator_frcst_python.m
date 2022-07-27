function mercator_name=download_mercator_frcst_python(pathMotu,user,password, ...
                                               mercator_type,lh,lf, ...
                                               lonmin,lonmax,latmin,latmax,zmax,...
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
%  Updated   20-Aug-2008 by Matthieu Caillaud & P. Marchesiello
%  Updated   12-Feb-2016 by P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Set variable names according to mercator type data
%
if mercator_type==1,
  vars = {'ssh' ...
	  'u' ...
	  'v' ...
	  'temperature' ...
	  'salinity'};
else
  vars = {'sossheig' ...
	  'vozocrtx' ...
	  'vomecrty' ...
	  'votemper' ...
	  'vosaline'};
end
%
% Get dates
%
rundate_str=date;
rundate=datenum(rundate_str)-datenum(Yorig,1,1);

for i=1:lh
  time1(i)=datenum(rundate_str)-(lh+1-i);
end
time2=datenum(rundate_str);
for j=1:lf
  time3(j)=datenum(rundate_str)+j;
end
time=cat(2,time1,time2,time3);
tiempo_inicial = time1(1);
tiempo_final = time3(end);
if (lonmin > 180)
  lonmin = lonmin - 360;
end
if (lonmax > 180)
  lonmax = lonmax - 360;
end
disp([' '])
disp(['Get data for ',rundate_str])
disp(['Minimum Longitude: ',num2str(lonmin)])
disp(['Maximum Longitude: ',num2str(lonmax)])
disp(['Minimum Latitude:  ',num2str(latmin)])
disp(['Maximum Latitude:  ',num2str(latmax)])
disp([' '])
%
% Get data
%
get_file_python_mercator(pathMotu,mercator_type,vars, ...
	      [lonmin-1 lonmax+1 latmin-1 latmax+1 0 zmax], ...
	      {datestr(tiempo_inicial,'yyyy-mm-dd') datestr(tiempo_final,'yyyy-mm-dd')}, ...
	      {user password}, ...
	      url);
%
% Convert data format and write in a more CROCOTOOLS 
% compatible input file 
%
disp(['Making output data directory ',FRCST_dir]) % create directory
eval(['!mkdir ',FRCST_dir])
%
mercator_name=[FRCST_dir,FRCST_prefix,num2str(rundate),'.cdf'];
if ~exist(mercator_name)  
  write_mercator_frcst(FRCST_dir,FRCST_prefix,url, ...
                       mercator_type,vars,time,Yorig); % write data
else
  disp('Mercator file already exist')
end

return
