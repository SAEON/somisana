%
% Get non-seasonnal EKE and RMS SSH from AVISO Data
%
% Pierrick Penven 2014
%
clear all
close all
%
AVISO_DIR='../AVISO/MADT_RENAME';
AVISO_TYPE='madt';
%
alti_prefix=[AVISO_DIR,'/',AVISO_TYPE,'_'];
alti_suffix='.nc';
%
nonseason=0;
name='beng';
%
Yorig=2000;
%
% First date to process
%
Ymin=2014;
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
lonmin =   8;   % Minimum longitude [degree east]
lonmax =  22;   % Maximum longitude [degree east]
latmin = -38;   % Minimum latitudeF  [degree north]
latmax = -26;   % Maximum latitude  [degree north]
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
if nonseason==1
  avgzeta=zeros(Nyear,4,M,L);
  nindex=zeros(Nyear,4);
else
  avgzeta=zeros(M,L);
  nindex=0;
end  
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
  if nonseason==1
    yindex=year-Ymin+1;
    season=1+floor((month-1)/3);
    avgzeta(yindex,season,:,:)=squeeze(avgzeta(yindex,season,:,:))+zeta;
    nindex(yindex,season) = nindex(yindex,season) + 1;
  else
    nindex = nindex + 1;
    avgzeta=avgzeta+zeta;
  end
end
a=mean(mean(nindex));
if nonseason==1
  for yindex=1:Nyear
    for season=1:4
      avgzeta(yindex,season,:,:)=avgzeta(yindex,season,:,:)/nindex(yindex,season);
    end
  end
else
  avgzeta=avgzeta/nindex;
end
%avgzeta=0*avgzeta;
%
% get eke
%
nindex=0;
uu=zeros(M,L);
vv=zeros(M,L);
uv=zeros(M,L);
z2=zeros(M,L);
%
% 2nd loop: get the variance
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
  if nonseason==1
    yindex=year-Ymin+1;
    season=1+floor((month-1)/3);
    zeta=zeta-squeeze(avgzeta(yindex,season,:,:));
  else
    zeta=zeta-avgzeta;
  end
%
% Get u and v
%
  u=-gof.*v2rho_2d(vmask.*(zeta(2:end,1:end)-zeta(1:end-1,1:end))...
              .*0.5.*(pn(2:end,1:end)+pn(1:end-1,1:end)));
  v=gof.*u2rho_2d(umask.*(zeta(1:end,2:end)-zeta(1:end,1:end-1))...
              .*0.5.*(pm(1:end,2:end)+pm(1:end,1:end-1)));
%
% Get the variances
%
  uu=uu+u.^2;
  vv=vv+v.^2;
  uv=uv+u.*v;
  z2=z2+zeta.^2;
  nindex=nindex+1;
end
uu=uu/nindex;
vv=vv/nindex;
uv=uv/nindex;
z2=z2/nindex;
%
% Compute EKE
%
eke=0.5*(uu+vv);
%
% Compute RMS SSH
%
varssh=sqrt(z2);
%
% Save 
%
if nonseason==1
  fname=[name,'_eke_aviso_ns.mat']
else
  fname=[name,'_eke_aviso.mat']
end
%
save(fname,'lon','lat','avgzeta',...
       'eke','varssh','uu','vv','uv')
%
disp(['nindex= ',num2str(a)])
%
% Plot
%
plot_eke(fname)
