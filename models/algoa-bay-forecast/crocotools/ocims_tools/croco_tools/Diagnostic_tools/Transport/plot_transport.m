function plot_transport(fname)

load(fname)

npts=[2 2 2 2];

zoom=0;
lonmin=min(min(lon))-zoom;
lonmax=max(max(lon))+zoom;
latmin=min(min(lat))-zoom;
latmax=max(max(lat))+zoom;

psi_r=1e-6*psi2rho(psi-psi(38,38));

colmax=10*ceil(max(psi_r(isfinite(psi_r))/10));
colmin=10*ceil(max(-psi_r(isfinite(psi_r))/10));
dcol=5;

topo=0;

m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
[x,y]=m_ll2xy(lon,lat,'clip','off');
hold on

[C1,h1]=m_contour(rempoints(lon,npts),rempoints(lat,npts),rempoints(psi_r,npts)...
           ,[dcol:dcol:colmax],'k');
if ~isempty(C1)
  clabel(C1,h1,'LabelSpacing',1000,'Rotation',0)
  hf1=add_streamarrows(C1,x,y,u2rho_2d(u),v2rho_2d(v));
  hold on
end

[C2,h2]=m_contour(rempoints(lon,npts),rempoints(lat,npts),rempoints(-psi_r,npts)...
           ,[dcol:dcol:colmin],'k');
if ~isempty(C2)
  clabel(C2,h2,'LabelSpacing',1000,'Rotation',0)
  hf2=add_streamarrows(C2,x,y,u2rho_2d(u),v2rho_2d(v));
  hold on
end

[C3,h3]=m_contour(rempoints(lon,npts),rempoints(lat,npts),rempoints(psi_r,npts)...
           ,[0 0],'k');
if ~isempty(C3)
  clabel(C3,h3,'LabelSpacing',1000,'Rotation',0)
  hf3=add_streamarrows(C3,x,y,u2rho_2d(u),v2rho_2d(v));
  set(h3,'Color','k','Linewidth',1.2);
  set(hf3,'Linewidth',1.2);
  hold on
end

if topo==1
  [C4,h4]=m_contour(rempoints(lon,npts),rempoints(lat,npts),rempoints(h,npts)...
           ,[1000 2000 3000 4000 5000],'r');
  clabel(C4,h4,'LabelSpacing',1000,'Rotation',0)
end

m_usercoast('coastline_l.mat','patch',[.9 .9 .9]);
hold off
m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out');
set(findobj('tag','m_grid_color'),'facecolor','white')


if isfinite(z1)
 zname1=[num2str(abs(z1)),' m'];
else
 zname1='fond';
end
if isfinite(z2)
 zname2=[num2str(abs(z2)),' m'];
else
 zname2='surface';
end
title(['Transport [Svd] ',zname2,' - ',zname1])
hold off
