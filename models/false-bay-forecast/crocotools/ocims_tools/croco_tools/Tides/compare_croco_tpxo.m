%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% valid_tides: compares CROCO tidal time series with tide-gauge data
%              and CROCO forcing data (TPXO), then computes harmonic
%              constituants using Rich Pawlowicz's T_TIDE package 
%              and intercompare model/data/forcing for each the 
%              strongest model tidal constituents.
%
%  T_TIDE  -->  http://www.eos.ubc.ca/~rich/#T_Tide
%  R. Pawlowicz, B. Beardsley, and S. Lentz, 2002: Classical tidal harmonic 
%  analysis including error estimates in MATLAB using T_TIDE, Computers and 
%  Geosciences. 28, 929-937.

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
%  Copyright (c) 2005-2006 by Patrick Marchesiello and Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%  Updated    12-Aug-2011 by Patrick Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; 
close all;
%==================== USER DEFINED VARIABLES ============================
%
% Output  ................
%
fid=1;                     % ouput type: 1=screen ; 2=outfile 
outfile='valid_tides.txt'; % output file name
t_tide_out='none';         % t_tide output: 'none' 'screen' or outfile
%
% MODEL ....................................
%
crocotools_param
%
hisname =[CROCO_files_dir,'croco_his.nc'];
%
% time series parameters: start, interval and duration
%
year=2000; month=1; day=2; % Start time of analysis
ndays=30;                   % Duration of analysis in days
timestep=2;                % Tide sampling interval in hours

%
% TIDAL STATIONS .............................
% number and positions (lat,lon)
nbstations=4;
staname(1,:)='Gabes  ';
lonsta(1)=11.2; latsta(1)=34.2; 
staname(2,:)='Venezia';
lonsta(2)=12.8; latsta(2)=44.6; 
staname(3,:)='Napoli ';
lonsta(3)=12; latsta(3)=40; 
staname(4,:)='Egean  ';
lonsta(4)=24.5; latsta(4)=39.5; 

%================ END USERS DEFINED VARIABLES =========================
%
% Set model time array
%
res=24/timestep;            % nb points a day
time0 = mjd(year,month,day);
tmin  = mjd(Ymin,Mmin,Dmin);
tstr  = time0-tmin;
nc=netcdf(hisname);
timem=nc{'scrum_time'}(:)/86400;
close(nc)
ndays=min(ndays,floor(timem(end)-tstr));
Tstr=1+res*tstr;
Tend=Tstr+res*ndays;
T =Tend-Tstr+1;
jul_off = mjd(Yorig,1,1);
for i=1:T;
  time(i)=time0+(i-1)/res-jul_off;
end;
%
% Read CROCO grid
%
nc=netcdf(grdname);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
lonu=nc{'lon_u'}(:);
latv=nc{'lat_v'}(:);
h=nc{'h'}(:);
mask=nc{'mask_rho'}(:);
close(nc);
latmid=mean(mean(lat));
%
%....................................................................
% Find j,i indices for tide stations
%....................................................................
%
for k=1:nbstations
 [J(k),I(k)]=find((latv(1:end-1,2:end-1)<latsta(k) & latv(2:end,2:end-1)>=latsta(k) &...
                   lonu(2:end-1,1:end-1)<lonsta(k) & lonu(2:end-1,2:end)>=lonsta(k))==1);
 I(k)=I(k)+1; J(k)=J(k)+1;
 if isempty(I(k)) |  isempty(J(k))
  disp(' Warning: location of tide station not found, use model middle point ...')
  [M,L]=size(lon);
  I(k)=round(L/2);
  J(k)=round(M/2);
 end 
 if mask(J(k),I(k))==0,
  disp(' Warning: location of tide station in model land mask ...')
 end
 lonsta_m(k)=lon(J(k),I(k));
 latsta_m(k)=lat(J(k),I(k));
end
%
%....................................................................
% Model tides: read CROCO surface elevation 
%....................................................................
%
nc=netcdf(hisname);
ssh_m=squeeze(nc{'zeta'}(Tstr:Tend,:,:));
close(nc);
%
%.....................................................................
% Forcing tides (e;g. TPXO) 
% Rebuild from harmonics stored in croco forcing file
%.....................................................................
%
nc=netcdf(frcname);
Tperiod=squeeze(nc{'tide_period'}(:)./24);     % hours-->days
Ephase =squeeze(nc{'tide_Ephase'}(:)*pi/180);  % deg-->rad
Eamp   =squeeze(nc{'tide_Eamp'}(:));           % m
cmpt=nc.components(:);
close(nc);
Nmax=length(Eamp); 
Ntides=min([Nmax Ntides]);
for i=1:Ntides
  components(3*i-2:3*i)=[cmpt(3*i-2:3*i-1),' '];
end
disp(' ')
disp(['Model forcing tidal components : ',components])
disp(' ')
%
ssh_f=zeros(size(ssh_m));
for itime=1:T
 for itide=1:Ntides
   omega=2*pi/Tperiod(itide)*time(itime); 
   ssh_f(itime,:,:)=ssh_f(itime,:,:) + ...
                  Eamp(itide,:,:).*cos(omega - Ephase(itide,:,:));
 end
end
%
%==============================================================
% Make a few plots
%==============================================================
%
%------------------------------------------
%               Plot domain
%------------------------------------------
f=figure;
set(f,'Position',[200 300 800 400]);
themask=ones(size(mask));
themask(mask==0)=NaN;
domaxis=[min(min(lon)) max(max(lon)) min(min(lat)) max(max(lat))];
colaxis=[min(min(h)) max(max(h))];
colormap(cool)
fixcolorbar([0.25 0.05 0.5 0.03],colaxis,...
            'Topography',10)
width=1; height=0.8;
subplot('position',[0. 0.14 width height])
m_proj('mercator',...
       'lon',[domaxis(1) domaxis(2)],...
       'lat',[domaxis(3) domaxis(4)]);
m_pcolor(lon,lat,h.*themask); hold on;
shading flat; caxis(colaxis)
[C1,h1]=m_contour(lon,lat,h,[5 10 20 30 40 50 70 100 500 1000 2000 4000],'k');
clabel(C1,h1,'LabelSpacing',1000,'Rotation',0,'Color','r')
if ~isempty(coastfileplot)
  m_usercoast(coastfileplot,'color','r');
else
  m_gshhs_l('color','r');
  m_gshhs_l('speckle','color','r');
end
for k=1:nbstations
  m_text(lonsta(k),latsta(k),sprintf('+ %s',staname(k,:)),'fontsize',18);
end
m_grid('box','fancy','tickdir','in');
hold off
%
%-------------------------------------------
% Plot tidal series: model and TPXO forcing
%-------------------------------------------
time_m=time;
timeref=[time_m(1):1/24:time_m(end)];
method='spline';

for k=1:nbstations  % select 4 stations
 figure
 ssh_f_sta=squeeze(ssh_f(:,J(k),I(k)));
 sshf(:,k)=interp1(time_m,ssh_f_sta,timeref,method);
 a=plot(timeref,sshf(:,k),'k--'); hold on;
%
 ssh_m_sta=squeeze(ssh_m(:,J(k),I(k)));
 sshm(:,k)=interp1(time_m,ssh_m_sta,timeref,method);
 b=plot(timeref,sshm(:,k),'r');
%
 h_legend=legend([a b],'TPXO','Model');
 set(h_legend,'FontSize',7,'Location','Southeast');
 title(staname(k,:));
 hold off;
 cmax=1; %max(abs(sshm(:,k)))*1.5;
 axis([timeref(1) timeref(end) -cmax cmax]);
end

%return
%
%===================================================================
% Tidal harminic analysis using T_TIDE
%===================================================================
%
disp(' ')
disp(' ====== TIDAL ANALYSIS ======')
disp(' ')
%
 
  disp(' ')
  disp('---------------------------------------------------------')
  disp('           Harmonic analysis : MODEL DATA                ')
  disp('---------------------------------------------------------')
  disp(' ')

 for ista=1:nbstations;  % station loop ------

  disp(' ')
  disp('============================ ')
  disp([' ... STATION: ',staname(ista,:)])
  disp('=============================')
  disp(' ')

  ssh0=sshm(:,ista);

  [tidestruc,xout]=t_tide(ssh0,'interval',1,'start',datenum(Yorig,1,1), ...
                               'latitude',latmid,'output',t_tide_out);
   Itides(1:Ntides)=0;
   nconst=length(tidestruc.name);
   for i=1:nconst;
     for k=1:Ntides;
       if tidestruc.name(i,1:3)==components(3*k-2:3*k), 
         Itides(k)=i; 
       end
     end
   end
   Itides=Itides(Itides~=0);
   Atides_m=tidestruc.tidecon(Itides,1);
   Ptides_m=tidestruc.tidecon(Itides,3);
   Ttides_m=tidestruc.name(Itides,:);
   Nbtides=length(Atides_m);
   Ptides_m=zero22pi(Ptides_m+180)-180;

  ssh0=sshf(:,ista);

  [tidestruc,xout]=t_tide(ssh0,'interval',1,'start',datenum(Yorig,1,1), ...
                               'latitude',latmid,'output',t_tide_out);
   Itides(1:Ntides)=0;
   nconst=length(tidestruc.name);
   for i=1:nconst;
     for k=1:Ntides;
       if tidestruc.name(i,1:3)==components(3*k-2:3*k), 
         Itides(k)=i; 
       end
     end
   end
   Itides=Itides(Itides~=0);
   Atides_f=tidestruc.tidecon(Itides,1);
   Ptides_f=tidestruc.tidecon(Itides,3);
   Ttides_f=tidestruc.name(Itides,:);
   Nbtides=length(Atides_f);
   Ptides_f=zero22pi(Ptides_f+180)-180;

   Atides_err=Atides_m-Atides_f;
   Ptides_err=Ptides_m-Ptides_f;
   Ptides_err=zero22pi(Ptides_err+180)-180;

   fprintf(fid,'\n                      model/forcing err');
   fprintf(fid,'\n tide     Amp[cm]    Amp[cm]  Phase[deg]\n');
   for i=1:Nbtides
     fprintf(fid,' ');
     fprintf(fid,'%s %10.1f %12.1f %10.1f\n', ...
             Ttides_m(i,:),100*Atides_m(i),100*Atides_err(i),Ptides_err(i));
   end
   disp(' ')

 end
 return




