clear all
close all

tindex=1;
oafile='croco_oa.nc';
coastfile='noumea_i.mat';

nc=netcdf(oafile,'r');
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
var=squeeze(nc{'NO3'}(tindex,2,:,:));
close(nc)
m_proj('mercator',...
       'lon',[min(min(lon)) max(max(lon))],...
       'lat',[min(min(lat)) max(max(lat))]);
m_pcolor(lon,lat,var);
shading flat
%caxis([33.8 35.8])
hold on
colorbar
m_usercoast(coastfile,'patch',[.9 .9 .9]);
m_grid('box','fancy',...
       'xtick',5,'ytick',5,'tickdir','out');
set(findobj('tag','m_grid_color'),'facecolor','none')
hold off
