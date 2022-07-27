%
%  make_forecast.m
%
%  Preparation of the files for the forecast system:
%     - launch make_OGCM_frcst and make_GFS
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
%  Updated   12-Feb-2016 by P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start
tic
crocotools_param

%
% Get the lateral boundary conditions
%
make_OGCM_frcst
%
% Get the surface forcing
%
make_GFS
%
% Copy the resulting files
%
%rundate=datenum(date)-datenum(Yorig,1,1); nc_suffix='.nc';
eval(['!cp ',bry_prefix,num2str(rundate),nc_suffix,' ',bry_prefix,'0',nc_suffix])
eval(['!cp ',blk_prefix,num2str(rundate),nc_suffix,' ',blk_prefix,'0',nc_suffix])
eval(['!cp ',frc_prefix,num2str(rundate),nc_suffix,' ',frc_prefix,'0',nc_suffix])
eval(['!cp ',clm_prefix,num2str(rundate),nc_suffix,' ',clm_prefix,'0',nc_suffix])
eval(['!cp ',ini_prefix,num2str(rundate),nc_suffix,' ',ini_prefix,'0',nc_suffix])
%
% Add tidal data in forcing file
%
if add_tides_fcst==1
  disp(['Add tidal data ... '])
  frcname=[CROCO_files_dir,'croco_frc_GFS_0.nc'];
  %add_tidal_data(tidename,grdname,frcname,Ntides,tidalrank,...
  %               Ymin,Mmin,Dmin,Hmin,Min_min,Smin,coastfileplot)
   [Y,M,d,h,mi,s] = datevec(date);
   add_tides(tidename,grdname,frcname,Ntides,tidalrank,...
                                  Yorig,Y,M,coastfileplot)

end
%
%  Set the clock right: 
%  - copy croco_ini.nc in FORECAST/croco_ini.nc if not available
%  - update scrum_time in FORECAST/croco_ini.nc using timezone information
%    In this case, initial scrum_time is the UTC time corresponding to 
%    local midnight of day: now-hdays+1 (scrum_time needs to be a UTC time
%    since all forcing fields are referenced to UTC time).
%
disp('Set the clock right in initial file using Time Zone information')
time=(floor(now)-datenum(Yorig,1,1)-(hdays-1)-timezone/24)*86400;
ininame='FORECAST/croco_ini.nc';
nc=netcdf(ininame,'write');
if isempty(nc)
  disp('No restart file available in CROCO_FILES, copy OGCM inifile')
  eval(['!cp ',ini_prefix,num2str(rundate),nc_suffix,' ',ininame])
  nc=netcdf(ininame,'write');
end
nc{'scrum_time'}(:)=time;
close(nc)
toc
return
