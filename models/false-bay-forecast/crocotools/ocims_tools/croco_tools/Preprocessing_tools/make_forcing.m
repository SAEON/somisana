%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO forcing file
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Contributions of P. Marchesiello (IRD)
%
%  Updated    Aug-2006 by Pierrick Penven
%  Updated    2006/10/02 by Pierrick Penven (add the 'tmp file' for 
%                                            ext_data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
%  Wind stress
%
taux_file=[coads_dir,'taux.cdf'];
taux_name='taux';
tauy_file=[coads_dir,'tauy.cdf'];
tauy_name='tauy';
%
%  Heat fluxes w3
%
shf_file=[coads_dir,'netheat.cdf'];
shf_name='netheat';
%
%  Fresh water fluxes (evaporation - precipitation)
%
swf_file=[coads_dir,'emp.cdf'];
swf_name='emp';
%
%  Sea surface temperature and heat flux sensitivity to the
%  sea surface temperature (dQdSST).
%  To compute dQdSST we need:
%    sat     : Surface atmospheric temperature
%    airdens : Surface atmospheric density
%    w3      : Wind speed at 10 meters
%    qsea    : Sea level specific humidity
%
sst_file=[coads_dir,'sst.cdf'];
sst_name='sst';
sat_file=[coads_dir,'sat.cdf'];
sat_name='sat';
airdens_file=[coads_dir,'airdens.cdf'];
airdens_name='airdens';
w3_file=[coads_dir,'w3.cdf'];
w3_name='w3';
qsea_file=[coads_dir,'qsea.cdf'];
qsea_name='qsea';
%
%  Sea surface salinity
%
sss_file=[coads_dir,'sss.cdf'];
sss_name='salinity';
%
%  Short wave radiation
%
srf_file=[coads_dir,'shortrad.cdf'];
srf_name='shortrad';
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
angle=nc{'angle'}(:);
close(nc);
cosa = cos(angle);
sina = sin(angle);
%
% Create the forcing file
%
disp(' ')
disp(' Create the forcing file...')
create_forcing(frcname,grdname,CROCO_title,...
               coads_time,coads_time,coads_time,...
               coads_time,coads_time,coads_time,...
               coads_cycle,coads_cycle,coads_cycle,...
               coads_cycle,coads_cycle,coads_cycle)
%
% Loop on time
%
nc=netcdf(frcname,'write');
for tindex=1:length(coads_time)
  time=nc{'sms_time'}(tindex);
  u=ext_data(taux_file,taux_name,tindex,...
             lon,lat,time,Roa,2);
  v=ext_data(tauy_file,tauy_name,tindex,...
             lon,lat,time,Roa,2);
%
%  Rotation (if not rectangular lon/lat grid)
%
  nc{'sustr'}(tindex,:,:)=rho2u_2d(u.*cosa + v.*sina);
  nc{'svstr'}(tindex,:,:)=rho2v_2d(v.*cosa - u.*sina);
end
for tindex=1:length(coads_time)
  time=nc{'shf_time'}(tindex);
  nc{'shflux'}(tindex,:,:)=ext_data(shf_file,shf_name,tindex,...
                                    lon,lat,time,Roa,1);
end
for tindex=1:length(coads_time)
  time=nc{'swf_time'}(tindex);
%
% coeff = mm/(3hour) -> centimeter day-1 (!!!!!)
%
  nc{'swflux'}(tindex,:,:)=0.8*ext_data(swf_file,swf_name,tindex,...
                                        lon,lat,time,Roa,1);
%  nc{'swflux'}(tindex,:,:)=0.8*(ext_data(evap_file,evap_name,...
%                                         tindex,lon,lat,time,Roa)-...
%			        ext_data(precip_file,precip_name,...
%                                         tindex,lon,lat,time,Roa));
end
for tindex=1:length(coads_time)
  time=nc{'sst_time'}(tindex);
  sst=ext_data(sst_file,sst_name,tindex,lon,lat,time,Roa,2);
  sat=ext_data(sat_file,sat_name,tindex,lon,lat,time,Roa,2);
  airdens=ext_data(airdens_file,airdens_name,tindex,lon,lat,time,Roa,2);
  w3=ext_data(w3_file,w3_name,tindex,lon,lat,time,Roa,2);
  qsea=0.001*ext_data(qsea_file,qsea_name,tindex,lon,lat,time,Roa,2);
  dqdsst=get_dqdsst(sst,sat,airdens,w3,qsea);
  nc{'SST'}(tindex,:,:)=sst;
  nc{'dQdSST'}(tindex,:,:)=dqdsst;
end
for tindex=1:length(coads_time)
  time=nc{'sss_time'}(tindex);
  nc{'SSS'}(tindex,:,:)=ext_data(sss_file,sss_name,tindex,...
                                 lon,lat,time,Roa,1);			 
end
for tindex=1:length(coads_time)
  time=nc{'srf_time'}(tindex);
  nc{'swrad'}(tindex,:,:)=ext_data(srf_file,srf_name,tindex,...
                                  lon,lat,time,Roa,1);
end
close(nc)
%
% Make a few plots
%
if makeplot==1
  disp(' ')
  disp(' Make a few plots...')
  test_forcing(frcname,grdname,'spd',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(frcname,grdname,'shflux',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(frcname,grdname,'swflux',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(frcname,grdname,'SST',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(frcname,grdname,'SSS',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(frcname,grdname,'dQdSST',[1 4 7 10],3,coastfileplot)
  figure
  test_forcing(frcname,grdname,'swrad',[1 4 7 10],3,coastfileplot)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
