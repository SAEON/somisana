function add_chla(climfile,gridfile,seas_datafile,cycle,Roa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function add_chla(climfile,gridfile,seas_datafile,cycle);
%
%  Add chlorophyll (mg C) in a CROCO climatology file.
%  take seasonal data for the surface levels and extrapole 
%  using Morel and Berthon (1989) parameterization for the
%  lower levels. warning ! the unit is (micro mole/l) in the
%  dataset.
%  ref:  Morel and Berthon, Surface pigments, algal biomass
%        profiles, and potential production of the euphotic layer:
%        Relationships reinvestigated in view of remote-sensing 
%        applications. Limnol. Oceanogr., 34, 1989, 1545-1562.
%
%  input:
%    
%    climfile      : croco climatology file to process (netcdf)
%    gridfile      : croco grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp('Add_chla: creating variable and attribute')
default=NaN;
%
% read in the datafile 
%
ncseas=netcdf(seas_datafile,'r');
x=ncseas{'X'}(:);
y=ncseas{'Y'}(:);
t=ncseas{'T'}(:);
tlen=length(t);
%
% open the grid file  
% 
ng=netcdf(gridfile,'r');
lon=ng{'lon_rho'}(:);
%lon(lon<0)=lon(lon<0)+360;
lat=ng{'lat_rho'}(:);
h=ng{'h'}(:);
close(ng);
[M,L]=size(lon);
dl=2.;
minlon=min(min(lon))-dl;
maxlon=max(max(lon))+dl;
minlat=min(min(lat))-dl;
maxlat=max(max(lat))+dl;
imin=max(find(x<=minlon));
imax=min(find(x>=maxlon));
jmin=max(find(y<=minlat));
jmax=min(find(y>=maxlat));
x=x(imin:imax);
y=y(jmin:jmax);
%
% open the clim file  
% 
nc=netcdf(climfile,'write');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
Tcline  =  nc{'Tcline'}(:);
vtransform=nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
end
N =  length(nc('s_rho'));

%redef(nc);
nc('chla_time') = tlen;
nc{'chla_time'} = ncdouble('chla_time') ;
nc{'CHLA'} = ncdouble('chla_time','s_rho','eta_rho','xi_rho') ;
%
nc{'chla_time'}.long_name = ncchar('time for chlorophyll');
nc{'chla_time'}.long_name = 'time for chlorophyll';
nc{'chla_time'}.units = ncchar('day');
nc{'chla_time'}.units = 'day';
if cycle~=0
  nc{'chla_time'}.cycle_length = cycle;
end
%
nc{'CHLA'}.long_name = ncchar('Chlorophyll');
nc{'CHLA'}.long_name = 'Chlorophyll';
nc{'CHLA'}.units = ncchar('mg C');
nc{'CHLA'}.units = 'mg C';
nc{'CHLA'}.fields = ncchar('CHLA, scalar, series');
nc{'CHLA'}.fields = 'CHLA, scalar, series';
%
%endef(nc);
%
% Record the time
%
nc{'chla_time'}(:)=t*30; % if time in month in the dataset !!!
%
% Get the missing values
%
missval=ncseas{'chlorophyll'}.missing_value(:);
%
% loop on time
%
for l=1:tlen
disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% extrapole the annual dataset on the horizontal croco grid
%
  disp('Add_chla: horizontal interpolation of surface data')
  surfchla=squeeze(ncseas{'chlorophyll'}(l,jmin:jmax,imin:imax));
  surfchla=get_missing_val(x,y,surfchla,missval,Roa,default);
  surfchlacroco=interp2(x,y,surfchla,lon,lat);
%
% extrapole the chlorophyll on the vertical
%
  zcroco=zlevs(h,0.*h,theta_s,theta_b,Tcline,N,'r',vtransform);
  disp(['Add_chla: vertical ',...
  'extrapolation of chlorophyll'])
  chlacroco=extr_chlo(surfchlacroco,zcroco);
  nc{'CHLA'}(l,:,:,:)=chlacroco;
end
close(nc);
close(ncseas);
chla=squeeze(chlacroco(N,:,:));
return
