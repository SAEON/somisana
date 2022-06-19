%*********************************************************
% plot CROCO forecast analysis at noon for each day
%*********************************************************
clear all
close all
start
crocotools_param
as_consts % load constants

disp('Forecast analysis')
%********************************************************
%            User defined parameters
%
dirin     = './';
dirout    = './Figs/';
eval(['!mkdir ',dirout])
grdname   = [dirin,'SCRATCH/croco_grd.nc'];
frcname   = [dirin,'SCRATCH/croco_frc_GFS_0.nc'];
avgname   = [dirin,'SCRATCH/croco_avg.nc'];
coastfile = [dirin,'coastline_l.mat'];

%lonmin=8; lonmax=22; latmin=-38; latmax=-26;

skip_wnd  =  2;
skip_cur  =  2;
zoom      =  0;
fsize     = 14;   % Font size
nx        =  3;   % number of days
titlemark = ['IRD: ',datestr(now)];

mean_currents = 0;  % 1: plot 0-500 mean currents
                    % 0: surface currents

plot_fig_1 = 0; % wind
plot_fig_2 = 0; % surface currents
plot_fig_3 = 1; % SST + surface currents
plot_fig_4 = 1; % SSH
plot_fig_5 = 0; % HBL

% offset to convert UTC  model time 
% into local matlab time (days]
days_off = timezone/24+datenum(Yorig,1,1); 
%
%************ End of users's defined parameter ************
%
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
h=nc{'h'}(:);
mask=nc{'mask_rho'}(:);
angle=nc{'angle'}(:);
close(nc)
mask(mask==0)=NaN;
%
nc=netcdf(avgname);
N=length(nc('s_rho'));
close(nc)
[M L]=size(lon);
Mu=M; Lu=L-1; Mv=M-1; Lv=L;
zeta(1:M,1:L)=0;
zw=zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
zu=rho2u_3d(zw);
zv=rho2v_3d(zw);
dzu=zu(2:end,:,:)-zu(1:end-1,:,:);
dzv=zv(2:end,:,:)-zv(1:end-1,:,:);
%
% coastline
%bounds=[lonmin lonmax latmin latmax]; res='l';
%coastfile=make_coast2(bounds,res)

%
barwidth=0.5;
barheight=0.04;
titleheight=0.01;
hmargin=0.025;
vmargin=0.10;
clear title;

if plot_fig_1,
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 1: wind
%
 disp('PLot winds ...')
 itime=0;
 cmin=0; cint=5; cmax=30; cff_wnd=.4; % winds
 [LON,LAT]=meshgrid([lonmin:1/3:lonmax],[latmin:1/3:latmax]);
 nc=netcdf(frcname);
 smstime=nc{'sms_time'}(:);
 smstime0=floor(now)-datenum(Yorig,1,1)-1/24-1;  %midday
 for tndx=1:nx;
  smstime0=smstime0+1;
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['WIND',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);
  istr=max(find(smstime<=smstime0));
  iend=min(find(smstime>=smstime0));
  u1=squeeze(nc{'sustr'}(istr,:,:));
  v1=squeeze(nc{'svstr'}(istr,:,:));
  u2=squeeze(nc{'sustr'}(iend,:,:));
  v2=squeeze(nc{'svstr'}(iend,:,:));
  u=(u1*(smstime(iend)-smstime0)+u2*(smstime0-smstime(istr)))/ ...
                                (smstime(iend)-smstime(istr));
  v=(v1*(smstime(iend)-smstime0)+v2*(smstime0-smstime(istr)))/ ...
                                (smstime(iend)-smstime(istr));
  stress=sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
  [ur,vr,lonr,latr,maskr]=uv_vec2rho(u,v,lon,lat,angle,mask,skip_wnd,[0 0 0 0]);

  spd=1.94384*sqrt(stress./(rho_air*1.15e-3));
  spdr=sqrt(ur.^2+vr.^2)./(rho_air*1.15e-3);
  ur=1.94384*ur./(rho_air*1.15e-3*spdr);
  vr=1.94384*vr./(rho_air*1.15e-3*spdr);

  U=interp2(lonr,latr,ur,LON,LAT);
  V=interp2(lonr,latr,vr,LON,LAT);

  m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
% [C0,h0]=m_contourf(lon,lat,stress,[0:0.04:0.3],'k');
  [C0,h0]=m_contourf(lon,lat,spd,[cmin:cint:cmax],'k');
  shading flat
  caxis([cmin cmax])
  hold on
  %h=m_quiver(lonr,latr,cff_wnd*ur,cff_wnd*vr,0,'k'); hold on;
  h=m_streamslice(LON,LAT,U,V,1); hold on;
  %m_streamslice(lonr,latr,ur,vr,1); hold on;
  set(h,'color','b');
  m_usercoast(coastfile,'patch',[.0 .0 .0]);
  hold off
  m_grid('box','fancy','tickdir','in','FontSize',fsize);
  set(findobj('tag','m_grid_color'),'facecolor','white')
  title([datestr(smstime0+days_off,1)],'FontSize',fsize+1)
  ht=m_text(lonmax,latmax+.5,titlemark);
  set(ht,'horizontalalignment','right','fontsize',fsize-4,'Color','b');
  set(gca,'Layer','top');
  subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
  colormap(1-copper)
  x=[0:1];
  y=[cmin:cint:cmax];
  [X,Y]=meshgrid(x,y);
  contourf(Y,X,Y,y)
  caxis([cmin cmax])
  set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
  set(gca,'FontSize',fsize)
  set(gca,'Layer','top');
%  xlabel('Wind Stress [N m^{-2}]','FontSize',fsize)
  xlabel('Wind [knots]','FontSize',fsize)
  set(gcf, 'PaperPositionMode', 'auto');

  export_fig -transparent file.pdf
  eval(['! mv -f file.pdf ',dirout,outname,'.pdf']);
 end
close(nc)
end % plot_fig_1

if plot_fig_2,
%
% 2: Surface currents
%
disp('PLot surface currents ...')
itime=0;
cmin=0; cint=0.1; cmax=2.0; cff_cur=2; 
for tndx=hdays+1:nx+hdays
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['FLOW',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);

  nc=netcdf(avgname);
  scrumtime=[];
  scrumtime=(nc{'scrum_time'}(tndx))/86400+days_off;
  if ~isempty(scrumtime)
    U=zeros(Mu,Lu);
    V=zeros(Mv,Lv);
    N=length(nc('s_rho'));
    if mean_currents,
      u=squeeze(nc{'u'}(tndx,:,:,:));
      v=squeeze(nc{'v'}(tndx,:,:,:));
      for j=1:Mu; for i=1:Lu; for k=N:-1:1;
        if zu(k,j,i)>-500,
          U(j,i)=U(j,i)+u(k,j,i).*dzu(k,j,i);
          hu(j,i)=-zu(k,j,i);
        end;
      end; end; end;
      clear u; u=U./hu; clear U;
      for j=1:Mv; for i=1:Lv; for k=N:-1:1;
        if zv(k,j,i)>-500,
          V(j,i)=V(j,i)+v(k,j,i).*dzv(k,j,i);
          hv(j,i)=-zv(k,j,i);
        end;
      end; end; end;
      clear v; v=V./hv; clear V;
    else
      u=squeeze(nc{'u'}(tndx,N,:,:));
      v=squeeze(nc{'v'}(tndx,N,:,:));
    end
    close(nc)

    spd=1.94384*mask.*sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
    spd=get_missing_val(lon,lat,spd);
    [ur,vr,lonr,latr,maskr]=uv_vec2rho(u,v,lon,lat,angle,mask,skip_cur,[0 0 0 0]);

    m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
    [C0,h0]=m_contourf(lon,lat,spd,[cmin:cint:cmax],'k');
    shading flat
    caxis([cmin cmax])
    hold on
    m_quiver(lonr,latr,cff_cur*ur,cff_cur*vr,0,'k');
    m_usercoast(coastfile,'patch',[.0 .0 .0]);
    hold off
    m_grid('box','fancy','tickdir','in','FontSize',fsize);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime,1)],'FontSize',fsize+1)
    ht=m_text(lonmax,latmax+.5,titlemark);
    set(ht,'horizontalalignment','right','fontsize',fsize-3,'Color','b');
    set(gca,'Layer','top');
    subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
    colormap(1-copper)
    x=[0:1];
    y=[cmin:cint:cmax];
    [X,Y]=meshgrid(x,y);
    caxis([cmin cmax])
    contourf(Y,X,Y,y)
    set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
    set(gca,'FontSize',fsize)
    set(gca,'Layer','top');
    if mean_currents,
      xlabel('0-500m mean currents [Knots]','FontSize',fsize)
    else
      xlabel('Surface currents [Knots]','FontSize',fsize)
    end
    set(gcf, 'PaperPositionMode', 'auto');

    export_fig -transparent file.pdf
    eval(['! mv -f file.pdf ',dirout,outname,'.pdf']);
  end
end
end % plot_fig_2

if plot_fig_3,
%
% 3: SST and Surface Currents
%
disp('PLot SST and surface currents ...')
itime=0;
nc=netcdf(avgname);
sst=mask.*squeeze(nc{'temp'}(1,N,:,:));
close(nc)
cmin=floor(min(min(sst)));
cmax= ceil(max(max(sst)));
cint=1; cff_cur=1.5;
%cmin=13; cmax=20;
for tndx=hdays+1:nx+hdays
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['SST',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);

  nc=netcdf(avgname);
  scrumtime=[];
  scrumtime=(nc{'scrum_time'}(tndx))/86400+days_off;
  if ~isempty(scrumtime)
    N=length(nc('s_rho'));
    sst=mask.*squeeze(nc{'temp'}(tndx,N,:,:));
    u=squeeze(nc{'u'}(tndx,N,:,:));
    v=squeeze(nc{'v'}(tndx,N,:,:));
    close(nc)
    [ur,vr,lonr,latr,maskr]=uv_vec2rho(u,v,lon,lat,angle,mask,skip_cur,[0 0 0 0]);
    spdr=sqrt(ur.^2+vr.^2);
    sst=get_missing_val(lon,lat,sst);
    ur=get_missing_val(lonr,latr,ur);
    vr=get_missing_val(lonr,latr,vr);

    %plot_res=1/3;
    %[LON,LAT]=meshgrid([lonmin:plot_res:lonmax],[latmin:plot_res:latmax]);
    %U=interp2(lonr,latr,ur,LON,LAT);
    %V=interp2(lonr,latr,vr,LON,LAT);

    m_proj('mercator',...
         'lon',[lonmin lonmax],...
         'lat',[latmin latmax]);
    [C0,h0]=m_contourf(lon,lat,sst,[cmin:cint:cmax],'k');
    shading flat
    caxis([cmin cmax])
    hold on
    m_quiver(lonr,latr,cff_cur*ur,cff_cur*vr,0,'k');
    %m_streamslice(LON,LAT,U,V,2);
    m_usercoast(coastfile,'patch',[.0 .0 .0]);
    hold off
    m_grid('box','fancy','tickdir','in','FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime,1)],'FontSize',fsize+1);
    ht=m_text(lonmax,latmax+.5,titlemark);
    set(ht,'horizontalalignment','right','fontsize',fsize-3,'Color','b');
    set(gca,'Layer','top');

    subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
    x=[0:1];
    y=[cmin:cint:cmax];
    [X,Y]=meshgrid(x,y);
    caxis([cmin cmax])
    contourf(Y,X,Y,y)
    set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
    set(gca,'FontSize',fsize)
    set(gca,'Layer','top');
    xlabel('SST [^{o}C]','FontSize',fsize)
    set(gcf, 'PaperPositionMode', 'auto');

    export_fig -transparent file.pdf
    eval(['! mv -f file.pdf ',dirout,outname,'.pdf']);
  end
end
end % plot_fig_3
%
if plot_fig_4,
%
% 4: Sea Surface Height
%
disp('PLot SSH ...')
itime=0;
cmin=-50; cint=5; cmax=50;
for tndx=hdays+1:nx+hdays
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['SSH',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);

  nc=netcdf(avgname);
  scrumtime=[];
  scrumtime=(nc{'scrum_time'}(tndx))/86400+days_off;
  if ~isempty(scrumtime)
    N=length(nc('s_rho'));
    ssh=100*squeeze(nc{'zeta'}(tndx,:,:));
    ssh=(ssh-mean(mean(ssh))).*mask;
    close(nc)
    ssh=get_missing_val(lon,lat,ssh);

    m_proj('mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);
    [C0,h0]=m_contourf(lon,lat,ssh,[cmin:cint:cmax]);
%    shading flat
    caxis([cmin cmax])
    m_usercoast(coastfile,'patch',[.0 .0 .0]);
    m_grid('box','fancy','tickdir','in','FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime,1)],'FontSize',fsize+1)
	ht=m_text(lonmax,latmax+.5,titlemark);
    set(ht,'horizontalalignment','right','fontsize',fsize-3,'Color','b');
    set(gca,'Layer','top');

    subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
    x=[0:1];
    y=[cmin:cint:cmax];
    [X,Y]=meshgrid(x,y);
    caxis([cmin cmax])
    contourf(Y,X,Y,y)
    set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
    set(gca,'FontSize',fsize)
    set(gca,'Layer','top');
    xlabel('SSH [cm]','FontSize',fsize)
    set(gcf, 'PaperPositionMode', 'auto');

    export_fig -transparent file.pdf
    eval(['! mv -f file.pdf ',dirout,outname,'.pdf']);
  end
end
end % plot_fig_4

if plot_fig_5,
%
% 5: Surface Boundary Layer Depth
%
disp('PLot HBL ...')
itime=0;
cmin=0; cint=10; cmax=100;
for tndx=hdays+1:nx+hdays
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['HBL',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);

  nc=netcdf(avgname);
  scrumtime=[];
  scrumtime=(nc{'scrum_time'}(tndx))/86400+days_off;
  if ~isempty(scrumtime)
    hbl=mask.*squeeze(nc{'hbl'}(tndx,:,:));
    close(nc)
%    hbl=get_missing_val(lon,lat,hbl);

    m_proj('mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);
    m_pcolor(lon,lat,hbl);
    shading flat
    caxis([cmin cmax])
    m_usercoast(coastfile,'patch',[.0 .0 .0]);
    m_grid('box','fancy','tickdir','in','FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime,1)],'FontSize',fsize+1)
	ht=m_text(lonmax,latmax+.5,titlemark);
    set(ht,'horizontalalignment','right','fontsize',fsize-3,'Color','b');
    set(gca,'Layer','top');

    subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
    x=[0:1];
    y=[cmin:cint:cmax];
    [X,Y]=meshgrid(x,y);
    caxis([cmin cmax])
    contourf(Y,X,Y,y)
    set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
    set(gca,'FontSize',fsize)
    set(gca,'Layer','top');
    xlabel('HBL [m]','FontSize',fsize)
    set(gcf, 'PaperPositionMode', 'auto');

    export_fig -transparent file.pdf
    eval(['! mv -f file.pdf ',dirout,outname,'.pdf']);
  end
end
end % plot_fig_5
