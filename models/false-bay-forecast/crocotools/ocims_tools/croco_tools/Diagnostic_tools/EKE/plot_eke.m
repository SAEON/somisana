function plot_eke(name)
%clear all
%close all
coastname='coastline_l.mat'; 
meancurrent=1;
%
%name='beng_eke_aviso.mat';
load(name)
lonmin=min(lon(:));
lonmax=max(lon(:));
latmin=min(lat(:));
latmax=max(lat(:));
%

eke=1e4*eke;
colmin=0;
colmax=100*ceil(max(eke(isfinite(eke)))/100);
dc=[colmax-colmin]/30;


m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
m_contourf(lon,lat,eke,[colmin:dc:colmax]);
caxis([colmin colmax])
shading flat
hold on

if meancurrent==1
  [C2,h2]=m_contour(lon,lat,100*avgzeta,[-200:5:200],'k');
  set(h2,'LineWidth',1.)
  [u,v]=geostrophy(lon,lat,avgzeta);
  [x,y]=m_ll2xy(lon,lat,'clip','off');
  h3=add_streamarrows(C2,x,y,u,v);
  set(h3,'LineWidth',1.2)
end

m_usercoast(coastname,'patch',[.9 .9 .9]);
m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out','fontsize',7);
set(findobj('tag','m_grid_color'),'facecolor','white')
hold off

colorbar
title('EKE [cm^2.s^{-2}]')
