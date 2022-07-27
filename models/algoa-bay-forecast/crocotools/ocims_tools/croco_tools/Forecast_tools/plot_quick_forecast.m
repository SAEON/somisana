%
%  forecast_analysis.m
%
%  Create an image from the forecast results and send it to the 
%  forecast web page.
%  
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
%  Updated    5-Oct-2006 by Pierrick Penven (changes in file names)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start
disp('Forecast analysis')
%
% Common parameters
%
crocotools_param
%
% plot the wind speed at noon for each day
%
skip=5;
zoom=0;
X=30;
Y=22;
% time (in matlab time)
%
today=floor(now);
%
% date in 'Yorig' time
%
rundate=datenum(today)-datenum(Yorig,1,1);
%
nc=netcdf(grdname);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
mask=nc{'mask_rho'}(:);
angle=nc{'angle'}(:);
close(nc)
mask(mask==0)=NaN;
%
lonmin=min(min(lon))-zoom;
lonmax=max(max(lon))+zoom;
latmin=min(min(lat))-zoom;
latmax=max(max(lat))+zoom;
%
close all
figure('Units','centimeters',...
       'Position',[1 1 X Y],...
       'PaperPosition',[1 1 X Y],...
       'PaperUnits','centimeters')
%
fsize=8;
nx=6;
cff1=4;
cff2=2;
%
barwidth=0.2;
barheight=0.01;
titleheight=0.01;
hmargin=0.025;
vmargin=0.06;
%
width=(1-(1+nx)*hmargin)/(nx);
height=(1-6.6*vmargin-3*barheight-titleheight)/3;
%
left1=hmargin;
%
bot1=vmargin;
bot2=bot1+barheight+0.5*vmargin;
bot3=bot2+height+1.5*vmargin;
bot4=bot3+barheight+0.5*vmargin;
bot5=bot4+height+1.5*vmargin;
bot6=bot5+barheight+0.5*vmargin;
bot7=bot6+height+1.5*vmargin;
%
% title
%
subplot('Position',[0.5-0.5*barwidth bot7 barwidth titleheight])
set(gca,'XTickLabel',[' '])
xlabel(['CROCO experiment: ',datestr(today)],'FontSize',10)
%
% 1: wind stress
%
left=left1;
bot=bot6;
for tndx=4*5:4:4*5+4*(nx)
  subplot('Position',[left bot width height])
  nc=netcdf('SCRATCH/croco_frc_GFS_0.nc');
  smstime=[];
  smstime=nc{'sms_time'}(tndx);
  if ~isempty(smstime)
    u=squeeze(nc{'sustr'}(tndx,:,:));
    v=squeeze(nc{'svstr'}(tndx,:,:));
    close(nc)
    stress=mask.*sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
    [ur,vr,lonr,latr,spd]=uv_vec2rho(u,v,lon,lat,angle,mask,skip,[0 0 0 0]);
     m_proj('mercator',...
         'lon',[lonmin lonmax],...
         'lat',[latmin latmax]);
    [C0,h0]=m_contourf(lon,lat,stress,[0:0.04:0.3],'k');
    shading flat
    caxis([0 0.3])
    hold on
    m_quiver(lonr,latr,cff1*ur,cff1*vr,0,'k');
    m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
    hold off
    m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out',...
           'FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(smstime+datenum(Yorig,1,1))],'FontSize',fsize)
    left=left+width+hmargin;
  end
end
subplot('Position',[0.5-0.5*barwidth bot5 barwidth barheight])
x=[0:1];
y=[0:0.04:0.3];
[X,Y]=meshgrid(x,y);
contourf(Y,X,Y,y)
caxis([0 0.3])
set(gca,'XTick',[0:0.04:0.3],'YTickLabel',[' '])
set(gca,'FontSize',fsize)
xlabel('Wind stress [N.m^{-2}]','FontSize',fsize)
%
% 2: Surface currents
%
left=left1;
bot=bot4;
for tndx=1:nx
  subplot('Position',[left bot width height])
  nc=netcdf('SCRATCH/croco_avg.nc');
  scrumtime=[];
  scrumtime=(nc{'scrum_time'}(tndx))/(24*3600);
  if ~isempty(scrumtime)
    N=length(nc('s_rho'));
    u=squeeze(nc{'u'}(tndx,N,:,:));
    v=squeeze(nc{'v'}(tndx,N,:,:));
    close(nc)
    spd=mask.*sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
    [ur,vr,lonr,latr,spdr]=uv_vec2rho(u,v,lon,lat,angle,mask,skip,[0 0 0 0]);
     m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
    [C0,h0]=m_contourf(lon,lat,100*spd,[0:10:80],'k');
    shading flat
    caxis([0 80])
    hold on
    m_quiver(lonr,latr,cff2*ur,cff2*vr,0,'k');
    m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
    hold off
    m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out',...
           'FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime+datenum(Yorig,1,1))],'FontSize',fsize)
    left=left+width+hmargin;
  end
end
subplot('Position',[0.5-0.5*barwidth bot3 barwidth barheight])
x=[0:1];
y=[0:10:80];
[X,Y]=meshgrid(x,y);
caxis([0 80])
contourf(Y,X,Y,y)
set(gca,'XTick',[0:10:80],'YTickLabel',[' '])
set(gca,'FontSize',fsize)
xlabel('Surface currents [cm.s^{-1}]','FontSize',fsize)
%
% 3: SST 
%
left=left1;
bot=bot2;
for tndx=1:nx
  subplot('Position',[left bot width height])
  nc=netcdf('SCRATCH/croco_avg.nc');
  scrumtime=[];
  scrumtime=(nc{'scrum_time'}(tndx))/(24*3600);
  if ~isempty(scrumtime)
    N=length(nc('s_rho'));
    sst=squeeze(nc{'temp'}(tndx,N,:,:));
    close(nc)
     m_proj('mercator',...
         'lon',[lonmin lonmax],...
         'lat',[latmin latmax]);
    [C0,h0]=m_contourf(lon,lat,sst,[10:1:25],'k');
    shading flat
    caxis([10 25])
    hold on
    m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
    hold off
    m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out',...
           'FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime+datenum(Yorig,1,1))],'FontSize',fsize)
    left=left+width+hmargin;
  end
end
subplot('Position',[0.5-0.5*barwidth bot1 barwidth barheight])
x=[0:1];
y=[10:1:25];
[X,Y]=meshgrid(x,y);
caxis([10 25])
contourf(Y,X,Y,y)
set(gca,'XTick',[10:2:25],'YTickLabel',[' '])
set(gca,'FontSize',fsize)
xlabel('SST [^{o}C]','FontSize',fsize)
%
% Print the image
%
eval(['print -depsc2 croco_',num2str(rundate),'.eps'])
eval(['!convert -density 85 croco_',num2str(rundate),...
      '.eps croco_',num2str(rundate),'.jpg'])
eval(['!mv -f croco_',num2str(rundate),'.jpg croco_realtime.jpg'])
%
% send the file to the web site
%
% %!./envoi.csh croco_realtime.jpg
% %
% close all
% %
% nc=netcdf('SCRATCH/croco_sta_hindcast.nc');
% t1=nc{'scrum_time'}(:)/(24*3600);
% sst1=squeeze(nc{'temp'}(:,1,32));
% bott1=squeeze(nc{'temp'}(:,1,1));
% temp1=squeeze(nc{'temp'}(:,1,:));
% z1=squeeze(nc{'depth'}(:,1,:));
% u1=1e3*squeeze(nc{'u'}(:,1,:));
% v1=1e3*squeeze(nc{'v'}(:,1,:));
% close(nc)
% tmin=min(t1);
% sst1(1)=NaN; 
% bott1(1)=NaN; 
% u1(1,:)=NaN;
% v1(1,:)=NaN;
% temp1(1,:)=NaN;
% 
% nc=netcdf('SCRATCH/croco_sta_forecast.nc');
% t2=nc{'scrum_time'}(:)/(24*3600);
% sst2=squeeze(nc{'temp'}(:,1,32));
% bott2=squeeze(nc{'temp'}(:,1,1));
% temp2=squeeze(nc{'temp'}(:,1,:));
% z2=squeeze(nc{'depth'}(:,1,:));
% u2=1e3*squeeze(nc{'u'}(:,1,:));
% v2=1e3*squeeze(nc{'v'}(:,1,:));
% close(nc)
% temp2=temp2(2:end,:);
% u2=u2(2:end,:);
% v2=v2(2:end,:);
% z2=z2(2:end,:);
% t2=t2(2:end);
% sst2=sst2(2:end);
% bott2=bott2(2:end);
% z=squeeze(z2(1,:));
% t1=t1-tmin;
% t2=t2-tmin;
% 
% figure('Units','centimeters',...
%        'Position',[1 1 20 20],...
%        'PaperPosition',[1 1 20 20],...
%        'PaperUnits','centimeters')
% 
% subplot(3,1,1)
% pcolor(t1,z,u1')
% hold on
% pcolor(t2,z,u2')
% axis([0 9 -30 0])
% shading flat
% caxis([-250 250])
% colorbar
% title(['Velocity East [mm/s]'])
% ylabel('Depth')
% set(gca,'Xticklabel',[])
% 
% subplot(3,1,2)
% pcolor(t1,z,v1')
% hold on
% pcolor(t2,z,v2')
% axis([0 9 -30 0])
% shading flat
% caxis([-250 250])
% colorbar
% title(['Velocity North [mm/s]'])
% ylabel('Depth')
% set(gca,'Xticklabel',[])
% 
% subplot(3,1,3)
% pcolor(t1,z,temp1')
% hold on
% pcolor(t2,z,temp2')
% axis([0 9 -30 0])
% shading flat
% caxis([10 15])
% colorbar
% title(['Temperature [^oC]'])
% ylabel('Depth')
% set(gca,'Xtick',[0.5:1:9],...
%     'Xticklabel',datestr(tmin+[0.5:1:9]+datenum(Yorig,1,1),19))
% %
% % Print the image
% %
% eval(['print -depsc2 -painters bob_',num2str(rundate),'.eps'])
% eval(['!convert -density 85 bob_',num2str(rundate),...
%       '.eps bob_',num2str(rundate),'.jpg'])
% eval(['!cp -f bob_',num2str(rundate),'.jpg bob_realtime.jpg'])
% %
% % send the file to the web site
% %
% %!./envoi.csh bob_realtime.jpg





