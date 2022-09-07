function add_ini_chla(inifile,gridfile,seas_datafile,cycle,Roa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,chla]=add_ini_chla(inifile,gridfile,...
%                                             seas_datafile,...
%                                             cycle);
%
%  pierrick 2001
%
%  Add chlorophyll in a CROCO initial file.
%  take seasonal data for the surface levels and extrapole 
%  using Morel and Berthon (1989) parameterization for the
%  lower levels. warning ! the unit is (micro mole/l) in the
%  dataset.
%  do a temporal interpolation to have values at initial
%  time.
%
%  ref:  Morel and Berthon, Surface pigments, algal biomass
%        profiles, and potential production of the euphotic layer:
%        Relationships reinvestigated in view of remote-sensing 
%        applications. Limnol. Oceanogr., 34, 1989, 1545-1562.
%
%  input:
%    
%    inifile       : croco initial file to process (netcdf)
%    gridfile      : croco grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,chla] : surface field to plot (as an illustration)
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
%  Updated    August-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp('Add_ini_chla: creating variable and attribute')
default=NaN;
%
% read in the datafile 
%
ncseas=netcdf(seas_datafile,'r');
x=ncseas{'X'}(:);
y=ncseas{'Y'}(:);
datatime=ncseas{'T'}(:);
datatime=datatime*30;  % !!! if the time in the dataset is in months !!!
tlen=length(datatime);
%
% open the grid file  
% 
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
dl=0.5;
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
% open the initial file  
% 
nc=netcdf(inifile,'write');
theta_s = nc{'theta_s'}(:);
if isempty(theta_s)
  disp('Restart file')
  theta_s=nc.theta_s(:);
  theta_b=nc.theta_b(:);
  hc=nc.hc(:);
else
  theta_b =  nc{'theta_b'}(:);
  hc  =  nc{'hc'}(:);
  vtransform = nc{'Vtransform'}(:);
end
N =  length(nc('s_rho'));
scrum_time = nc{'scrum_time'}(:);
scrum_time = scrum_time / (24*3600);
tinilen = length(scrum_time);
%redef(nc);
nc{'CHLA'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'CHLA'}.long_name = ncchar('Chlorophyll');
nc{'CHLA'}.long_name = 'Chlorophyll';
nc{'CHLA'}.units = ncchar('mg C');
nc{'CHLA'}.units = 'mg C';
nc{'CHLA'}.fields = ncchar('CHLA, scalar, series');
nc{'CHLA'}.fields = 'CHLA, scalar, series';
%
%endef(nc);
%
% Get the missing values
%
missval=ncseas{'chlorophyll'}.missing_value(:);
%
% loop on time
%
for l=1:tinilen
  disp(['time index: ',num2str(l),' of total: ',num2str(tinilen)])
%
%  get data time indices and weights for temporal interpolation
%
  if cycle~=0
    modeltime=mod(scrum_time(l),cycle);
  else
    modeltime=scrum_time;
  end
  l1=find(modeltime==datatime);
  if isempty(l1)
    disp('temporal interpolation')
    l1=max(find(datatime<modeltime));
    time1=datatime(l1);
    if isempty(l1)
      if cycle~=0
        l1=tlen;
        time1=datatime(l1)-cycle;
      else
        error('No previous time in the dataset')
      end
    end
    l2=min(find(datatime>modeltime));
    time2=datatime(l2);
    if isempty(l2)
      if cycle~=0
        l2=1;
        time2=datatime(l2)+cycle;
      else
        error('No posterious time in the dataset')
      end
    end
    disp(['Initialisation time: ',num2str(modeltime),...
          ' - Time 1: ',num2str(time1),...
          ' - Time 2: ',num2str(time2)])
    cff1=(modeltime-time2)/(time1-time2);
    cff2=(time1-modeltime)/(time1-time2);
  else
    cff1=1;
    l2=l1;
    cff2=0;
  end
%
% interpole the annual dataset on the horizontal croco grid
%
  disp('Add_ini_chla: horizontal extrapolation of surface data')
  surfchla=squeeze(ncseas{'chlorophyll'}(l1,jmin:jmax,imin:imax));
  surfchla=get_missing_val(x,y,surfchla,missval,Roa,default);
  surfchla2=squeeze(ncseas{'chlorophyll'}(l2,jmin:jmax,imin:imax));
  surfchla2=get_missing_val(x,y,surfchla2,missval,Roa,default);
  surfchla=cff1*surfchla + cff2*surfchla2;
  surfchlacroco=interp2(x,y,surfchla,lon,lat);
%
% extrapole the chlorophyll on the vertical
%
  zeta = squeeze(nc{'zeta'}(l,:,:));
  zcroco=zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
  disp(['Add_ini_chla: vertical ',...
  'extrapolation of chlorophyll'])
  chlacroco=extr_chlo(surfchlacroco,zcroco);
  nc{'CHLA'}(l,:,:,:)=chlacroco;
end
close(nc);
close(ncseas);
return
