function bry_interp_bgc_chloro(zbryname,grdfile,clmfile,lon,lat,seas_datafile,ann_datafile,...
                    dataname,vname,obcndx,coef,Roa);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  function bry_interp_bgc_chloro(zbryname,lon,lat,seas_datafile,ann_datafile,...
%                      dataname,vname,obcndx,Roa);
% 
%  Interpole data for the lateral boundaries (bry_file) along 
%  horizontal z levels.
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
%  Updated    5-Oct-2006 by Pierrick Penven (test for negative salinity)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M,L]=size(lon);
%
disp(['Add ',dataname,': creating variable and attribute'])
% set the default value if no data
default=NaN;
Roa=0;
%
% read in the datafile 
%
ncseas=netcdf(seas_datafile,'r');
x=ncseas{'X'}(:);
y=ncseas{'Y'}(:);
t=ncseas{'T'}(:);
tlen=length(t);
missval=ncseas{'chlorophyll'}.missing_value(:);
%
% open the grid file  
% 
ng=netcdf(grdfile,'r');
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
nc=netcdf(clmfile,'r');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
Tcline  =  nc{'Tcline'}(:);
N =  length(nc('s_rho'));
vtransform=nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
close(nc)
%
% loop on time
%
chlacroco=zeros(tlen,N,M,L);
for l=1:tlen
disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% extrapole the annual dataset on the horizontal croco grid
%
  disp([dataname,' : horizontal interpolation of surface data'])
  surfchla=squeeze(ncseas{'chlorophyll'}(l,jmin:jmax,imin:imax));
  surfchla=get_missing_val(x,y,surfchla,missval,Roa,default);
  surfchlacroco=interp2(x,y,surfchla,lon,lat);
%
% extrapole the chlorophyll on the vertical
%
  zcroco=zlevs(h,0.*h,theta_s,theta_b,Tcline,N,'r',vtransform);
  disp(['      ==> then vertical extrapolation'])
  chlacroco(l,:,:,:)=extr_chlo(surfchlacroco,zcroco);
end
close(ncseas);
%
% get the boundary position
%
if obcndx==1
%
% Southern boundary
% 
  icroco=(1:L);
  jcroco=1;
elseif obcndx==2
%
% Eastern boundary
% 
  icroco=L;
  jcroco=(1:M);
elseif obcndx==3
%
% Northern boundary
% 
  icroco=(1:L);
  jcroco=M;
elseif obcndx==4
%
% Western boundary
% 
  icroco=1;
  jcroco=(1:M);
end
%
lon=lon(jcroco,icroco);
lat=lat(jcroco,icroco);
%
% Open the boundary file
%
nc=netcdf(zbryname,'write');
%
% loop on time
% 
dims=size(lon);
for l=1:tlen
%for l=1:1
  disp(['writing time index: ',num2str(l),' of total: ',num2str(tlen)])
  datazgrid=squeeze(chlacroco(l,:,jcroco,icroco));
  nc{vname}(l,:,:)=coef.*datazgrid;
end
close(nc);
return

