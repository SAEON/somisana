%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  pathfinder_sst
%
%  Interpolate PATHFINDER data on CROCO grid and write
%  into a CROCO netcdf forcing file
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
%  Copyright (c) 2003 by X. Capet (UCLA) and P. Marchesiello (IRD) 
%  Contribution of P. Penven (IRD)
%
%  Updated  October-2006 by Pierrick Penven 
%  (generalisation of crocotool_param.m)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all 
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
isoctave=exist('octave_config_info');
%
Roa=1e8;    % extrapolation decay length scale
default=0;
icoarse=8; % resolution coef for coarse grid
spval=NaN;  % Missing value
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Read CROCO Grid
%
ncgrd=netcdf(grdname,'r');
latgrd=ncgrd{'lat_rho'}(:);  % model grid
longrd=ncgrd{'lon_rho'}(:);
maskgrd=ncgrd{'mask_rho'}(:);
maskgrd(maskgrd==0)=NaN;
close(ncgrd)
lonmin=min(min(longrd))-1;
lonmax=max(max(longrd))+1;
latmin=min(min(latgrd))-1;
latmax=max(max(latgrd))+1;
%
% Create Grid for the PATHFINDER data
% Extract a subdomain.
% Extend 1 degree to ensure that the coarse grid
% for land extrapolation is large enough
%
nc=netcdf(pathfinder_sst_name,'r');
LON=nc{'X'}(:);
LAT=nc{'Y'}(:);
imin=max(find(LON<lonmin));
imax=min(find(LON>lonmax));
jmin=max(find(LAT<latmin));
jmax=min(find(LAT>latmax));
LON=LON(imin:imax);
LAT=LAT(jmin:jmax);
[lon,lat]=meshgrid(LON,LAT);
%
% Create coarser grid for land extrapolation
%
LONTMP=LON(1:icoarse:end);
LATTMP=LAT(1:icoarse:end);
[lontmp,lattmp]=meshgrid(LONTMP,LATTMP);
%
% Do the Interpolation and fill missing values (NaN)
% with extrapolated data.
%
ncfor=netcdf(frcname,'write');
for tindex=1:12
  disp([' ... Month index: ',num2str(tindex)])
  SST=squeeze(nc{'SST'}(tindex,jmin:jmax,imin:imax));
%
% Found weird values (-3) in Louisiana (ice cubes ?)
%
  SST(SST<0)=NaN;
%
  SSTTMP=SST(1:icoarse:end,1:icoarse:end);
  if tindex==1
    SSTTMP=get_missing_val(LONTMP,LATTMP,SSTTMP, ...
             spval,Roa,default,1);              % 1 to save extrap
  else
    SSTTMP=get_missing_val(LONTMP,LATTMP,SSTTMP, ...
             spval,Roa,default,0);              % 0 to load extrap
  end
%  
% Interpolation from coarse PATHFINDER grid to CROCO grid
%
  SSTTMPgrd=interp2(lontmp,lattmp,SSTTMP,longrd,latgrd,'linear');
% 
% Interpolation from fine PATHFINDER grid to CROCO grid
%
  SSTgrd=interp2(lon,lat,SST,longrd,latgrd,'linear');
%  
% Replace NaN values by extrapolated data
%
  NON=isnan(SSTgrd);
  SSTgrd(NON)=SSTTMPgrd(NON);
%  
% Write into forcing file at tindex
%
  ncfor{'SST'}(tindex,:,:)=SSTgrd; 
end 
%
close(nc)
close(ncfor)
if (isoctave == 0)
  eval(['!rm tmp.mat'])
else
  system('rm tmp.mat')
end
%
% Plot
%
if makeplot == 1
  tindex=1;
%
% Raw PATHFINDER data
%
nc=netcdf(pathfinder_sst_name,'r');
  sst=squeeze(nc{'SST'}(tindex,jmin:jmax,imin:imax));
  close(nc)
  sst(sst<0)=NaN;
  domaxis=[lonmin lonmax latmin latmax];
  m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)],...
         'lat',[domaxis(3) domaxis(4)]);
  fontsize=12;
  m_pcolor(lon,lat,sst);
  shading flat
  caxis([min(min(sst)) max(max(sst))])
  colorbar
  if ~isempty(coastfileplot)
    m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
  end
  title(['Raw PATHFINDER data'])
  m_grid('box','fancy','tickdir','out','fontsize',fontsize);
%
% Data interpolated on CROCO grid
%
  figure
nc=netcdf(frcname,'r');
  sstgrd=nc{'SST'}(tindex,:,:);
  close(nc);
  domaxis=[lonmin lonmax latmin latmax];
  m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)], ...
         'lat',[domaxis(3) domaxis(4)]);
  m_pcolor(longrd,latgrd,sstgrd);
  shading flat;
  caxis([min(min(sst)) max(max(sst))])
  colorbar;
  if ~isempty(coastfileplot)
    m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
  end
  title('Data interpolated on CROCO grid')
  m_grid('box','fancy','tickdir','out','fontsize',fontsize);
end
 
