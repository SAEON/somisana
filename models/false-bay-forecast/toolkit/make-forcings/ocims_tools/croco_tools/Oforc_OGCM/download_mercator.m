function download_mercator(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
                       OGCM_dir,OGCM_prefix,url,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subgrid from mercator to get a CROCO forcing
% Store that into monthly files.
% Take care of the Greenwitch Meridian.
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    6-Sep-2006 by Pierrick Penven
%  Updated    20-Aug-2008 by Matthieu Caillaud & P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp([' '])
disp(['Get data from Y',num2str(Ymin),'M',num2str(Mmin),...
      ' to Y',num2str(Ymax),'M',num2str(Mmax)])
disp(['Minimum Longitude: ',num2str(lonmin)])
disp(['Maximum Longitude: ',num2str(lonmax)])
disp(['Minimum Latitude: ',num2str(latmin)])
disp(['Maximum Latitude: ',num2str(latmax)])
disp([' '])
%
% Create the directory
%
disp(['Making output data directory ',OGCM_dir])
eval(['!mkdir ',OGCM_dir])
%
% Start 
%
disp(['Process the dataset: ',url])
%
% Find a subset of the mercator grid
%
[i1min,i1max,i2min,i2max,i3min,i3max,...
 i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
 jrange,jrange_v,krange,lon,lon_u,lat,lat_v,depth]=...
 get_mercator_subgrid(url,lonmin,lonmax,latmin,latmax);

%[i1min,i1max,i2min,i2max,i3min,i3max,jrange,krange,lon,lat,depth]=...
 %get_mercator_subgrid([url],lonmin,lonmax,latmin,latmax);

% Loop on the years
%
for Y=Ymin:Ymax
  disp(['Processing year: ',num2str(Y)])
%
% Loop on the months
%
  if Y==Ymin
    mo_min=Mmin;
  else
    mo_min=1;
  end
  if Y==Ymax
    mo_max=Mmax;
  else
    mo_max=12;
  end
  for M=mo_min:mo_max
    disp(['  Processing month: ',num2str(M)])
%
% Extract MERCATOR data
%
    extract_mercator(OGCM_dir,OGCM_prefix,url,Y,M,...
                 lon,lon_u,lat,lat_v,depth,...
                 krange,jrange,jrange_v,...
                 i1min,i1max,i2min,i2max,i3min,i3max,...
                 i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
                 Yorig)
  end
end

return




    
  %  extract_mercator(OGCM_dir,OGCM_prefix,[url],Y,M,...
  %              lon,lat,depth,SODA_time(tndx),...
  %               trange,krange,jrange,...
  %               i1min,i1max,i2min,i2max,i3min,i3max,...
  %               Yorig)
