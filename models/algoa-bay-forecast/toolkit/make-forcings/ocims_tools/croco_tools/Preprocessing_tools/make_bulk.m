%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO bulk file
%
%  Extrapole and interpole surface data to get surface boundary
%  conditions for CROCO (forcing netcdf file)
%
%  Data input format (netcdf):
%     taux(T, Y, X)
%     T : time [Months]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library 
%                (Atlas of Surface Marine Data 1994)
%
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.DASILVA/
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
%  Copyright (c) 2005 by Patrick Marchesiello and Pierrick Penven
%  e-mail:Patrick.Marchesiello@ird.fr  
%
%  Updated    2006/09/29 by Pierrick Penven (add a test for the plots)
%  Updated    2006/10/02 by Pierrick Penven (add the 'tmp file' for 
%                                            ext_data)
%  Updated    2006/10/05 by Pierrick Penven (add coads_dir)
%  Updated    25-Oct-2006 by Pierrick Penven (uwnd and vwnd)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
%  Load air-sea parameters
%
as_consts
%
%    sat      : Surface atmospheric temperature
%    airdens  : Surface atmospheric density
%    w3       : Wind speed at 10 meters
%    qsea     : Sea level specific humidity
%    rh       : relative humidity
%    precip   : precipitation rate
%    shortrad : Short wave radiation 
%    longrade : Outgoing long wave radiation
%
sat_file     =[coads_dir,'sat.cdf'];
sat_name     ='sat';
sst_file     =[coads_dir,'sst.cdf'];
sst_name     ='sst';
airdens_file =[coads_dir,'airdens.cdf'];
airdens_name ='airdens';
u3_file      =[coads_dir,'u3.cdf'];
u3_name      ='u3';
v3_file      =[coads_dir,'v3.cdf'];
v3_name      ='v3';
w3_file      =[coads_dir,'w3.cdf'];
w3_name      ='w3';
qsea_file    =[coads_dir,'qsea.cdf'];
qsea_name    ='qsea';
rh_file      =[coads_dir,'rh.cdf'];
rh_name      ='rh';
precip_file  =[coads_dir,'precip.cdf'];
precip_name  ='precip';
srf_file     =[coads_dir,'shortrad.cdf'];
srf_name     ='shortrad';
lrf_file     =[coads_dir,'longrad.cdf'];
lrf_name     ='longrad';
taux_file      =[coads_dir,'taux.cdf'];
taux_name      ='taux';
tauy_file      =[coads_dir,'tauy.cdf'];
tauy_name      ='tauy';

%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp(CROCO_title)
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
nc=netcdf(grdname,'r');
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
lonu=nc{'lon_u'}(:);
latu=nc{'lat_u'}(:);
lonv=nc{'lon_v'}(:);
latv=nc{'lat_v'}(:);
angle=nc{'angle'}(:);
close(nc);
cosa=cos(angle);
sina=sin(angle);
%
% Create the forcing file
%
disp(' ')
disp(' Create the bulk forcing file...')
create_bulk(blkname,grdname,CROCO_title,coads_time,coads_cycle);
%
% Loop on time
%
nc=netcdf(blkname,'write');
for tindex=1:length(coads_time)
  time=nc{'bulk_time'}(tindex);
  nc{'tair'}(tindex,:,:) = ext_data(sat_file,sat_name,tindex,...
                                        lon,lat,time,Roa,1);
end
for tindex=1:length(coads_time)
  time=nc{'bulk_time'}(tindex);
%        percent -> fraction
  nc{'rhum'}(tindex,:,:) = 0.01*ext_data(rh_file,rh_name,tindex,...
                                        lon,lat,time,Roa,1);
end
for tindex=1:length(coads_time)
  time=nc{'bulk_time'}(tindex);
%        mm/(3hour) -> centimeter day-1 
  nc{'prate'}(tindex,:,:)= 0.8*ext_data(precip_file,precip_name,tindex,...
                                        lon,lat,time,Roa,1);
end
for tindex=1:length(coads_time)
  time=nc{'bulk_time'}(tindex);
  radlw=ext_data(lrf_file,lrf_name,tindex,...
                                        lon,lat,time,Roa,1);
  nc{'radlw'}(tindex,:,:)=radlw;

  % radlw_in: substract upward gray-body longwave flux 
  % and make it positive downward
  sst= ext_data(sst_file,sst_name,tindex,...
                                        lon,lat,time,Roa,1);
  lwup=emiss_lw.*sigmaSB.*((sst+CtoK).^4);
  nc{'radlw_in'}(tindex,:,:)=-(radlw-lwup);
end
for tindex=1:length(coads_time)
  time=nc{'bulk_time'}(tindex);
  nc{'radsw'}(tindex,:,:)= ext_data(srf_file,srf_name,tindex,...
                                        lon,lat,time,Roa,1);
end
%
% Compute wind rotated and at u,v points
%
for tindex=1:length(coads_time)
  time=nc{'bulk_time'}(tindex);
  nc{'wspd'}(tindex,:,:) = ext_data(w3_file,w3_name,tindex,...
                                        lon,lat,time,Roa,1);
end
for tindex=1:length(coads_time)
  time=nc{'bulk_time'}(tindex);
  uwnd = ext_data(u3_file,u3_name,tindex,...
                                        lon,lat,time,Roa,1);
  vwnd = ext_data(v3_file,v3_name,tindex,...
                                        lon,lat,time,Roa,1);
  u10=rho2u_2d(uwnd.*cosa+vwnd.*sina);
  v10=rho2v_2d(vwnd.*cosa-uwnd.*sina);
  nc{'uwnd'}(tindex,:,:) = u10;
  nc{'vwnd'}(tindex,:,:) = v10;
end
%
% Compute wind stress rotated and at u,v points
%
for tindex=1:length(coads_time)
  time=nc{'sms_time'}(tindex);
  tx=ext_data(taux_file,taux_name,tindex,...
             lon,lat,time,Roa,2);
  ty=ext_data(tauy_file,tauy_name,tindex,...
             lon,lat,time,Roa,2);
  nc{'sustr'}(tindex,:,:)=rho2u_2d(tx.*cosa + ty.*sina);
  nc{'svstr'}(tindex,:,:)=rho2v_2d(ty.*cosa - tx.*sina);
end
close(nc)
%
% Make a few plots
%
if makeplot==1
  disp(' ')
  disp(' Make a few plots...')
  test_forcing(blkname,grdname,'tair',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'rhum',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'prate',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'uwnd',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'vwnd',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'wspd',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'radlw',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'radlw_in',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'radsw',[1 4 7 10],3,coastfileplot)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
