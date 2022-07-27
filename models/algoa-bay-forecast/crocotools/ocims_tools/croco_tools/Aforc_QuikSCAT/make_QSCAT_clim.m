%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  make_QSCATclm.m
%
%  Interpolate QuikSCAT monthly climdatology data on a CROCO grid 
%  and write into a CROCO netcdf forcing file
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
%  Updated    21-Dec-2006 by Pierrick Penven (new climatology file)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
nc=netcdf(grdname);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
angle=nc{'angle'}(:);
result=close(nc);
cosa = cos(angle);
sina = sin(angle);
%
% Loop on time
%
nc=netcdf(frcname,'write');
for tindex=1:12
  time=nc{'sms_time'}(tindex);
  u=ext_data(QSCAT_clim_file,'taux',tindex,...
             lon,lat,time,Roa,2);
  v=ext_data(QSCAT_clim_file,'tauy',tindex,...
             lon,lat,time,Roa,2);
%
%  Rotation (if not rectangular lon/lat grid)
%
  nc{'sustr'}(tindex,:,:)=rho2u_2d(u.*cosa + v.*sina);
  nc{'svstr'}(tindex,:,:)=rho2v_2d(v.*cosa - u.*sina);
end
close(nc)
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
test_forcing(frcname,grdname,'spd',[1 4 7 10],3,coastfileplot)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
