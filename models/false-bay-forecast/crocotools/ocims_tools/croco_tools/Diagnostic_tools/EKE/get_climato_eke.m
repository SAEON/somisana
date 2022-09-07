%
% Get non-seasonnal EKE and RMS SSH from AVISO Data
%
% Pierrick Penven 2014
%
clear all
close all
%
AVISO_DIR='../../AVISO/MADT_RENAME';
AVISO_TYPE='madt';
%
alti_prefix=[AVISO_DIR,'/',AVISO_TYPE,'_'];
alti_suffix='.nc';
%
Yorig=2000;
%
% First date to process
%
Ymin=1993;
Mmin=01;
Dmin=01;
%
% Last date to process
%
Ymax=2014;
Mmax=12;
Dmax=27;
%
dt=1; % Interval between AVISO maps [days]
%
lonmin = -10;   % Minimum longitude [degree east]
lonmax = 140;   % Maximum longitude [degree east]
latmin = -60;   % Minimum latitudeF  [degree north]
latmax =  10;   % Maximum latitude  [degree north]
%
coastfile='coastline_l.mat';
%
% Times of start and end
%
tstart=datenum(Ymin,Mmin,Dmin)-datenum(Yorig,1,1);
tend  =datenum(Ymax,Mmax,Dmax)-datenum(Yorig,1,1);
t=(tstart:dt:tend);
%
% Get the total number of AVISO maps
%
N=length(t);
%
% Get the total number of years
%
Nyear=1+Ymax-Ymin;
%
% Get the horizontal grid
%
strdate=datestr(t(1)+datenum(Yorig,1,1),26);
alti_date=strdate([1 2 3 4 6 7 9 10]);
alti_fname=[alti_prefix,alti_date,alti_suffix];
[x,y,zeta]=get_topex2014(lonmin,lonmax,latmin,latmax,alti_fname);
mask=isfinite(zeta);
[umask,vmask,pmask]=uvp_mask(mask);
[lon,lat,f,pm,pn]=get_tpx_grid(x,y);
gof=9.81./f;
[M,L]=size(lon);
%
% get avgzeta
%
avgzeta=zeros(12,M,L);
nindex=0*(1:12);

%
% 1st loop: get the mean
%
for n=1:N
%
% get zeta
%   
  strdate=datestr(t(n)+datenum(Yorig,1,1),26);
  alti_date=strdate([1 2 3 4 6 7 9 10]);
  [year,month,day,alti_H,alti_MI,alti_S]=datevec(t(n)+datenum(Yorig,1,1));
  alti_fname=[alti_prefix,alti_date,alti_suffix];
  [x,y,zeta]=get_topex2014(lonmin,lonmax,latmin,latmax,alti_fname);
  avgzeta(month,:,:)=squeeze(avgzeta(month,:,:))+zeta;
  nindex(month) = nindex(month) + 1;
end

for month=1:12
  avgzeta(month,:,:)=squeeze(avgzeta(month,:,:))/nindex(month);
end

save('climato_madt_aviso.mat','lon','lat','avgzeta')

