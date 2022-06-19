function geost_currents_bry(bryname,grdname,Zbryname,frcname,zref,obcndx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% compute SSH and the geostrophic currents from Hydrology data
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
%  Adapted from a previous program of Patrick Marchesiello (IRD).
%
%  Copyright (c) 2001-2006 by Patrick Marchesiello and Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rho0=1025; % Bousinesq background density [kg.m-3]
g=9.8;     % Gravity acceleration [m.s-2]
De=40;     % Ekman depth [m]
%
%  grid parameters
%
% disp(' Read grid parameters ...');
nc=netcdf(grdname,'r');
L=length(nc('xi_rho'));
M=length(nc('eta_rho'));
latu=nc{'lat_u'}(:);
lonu=nc{'lon_u'}(:);
lonv=nc{'lon_v'}(:);
latv=nc{'lat_v'}(:);
lonr=nc{'lon_rho'}(:);
latr=nc{'lat_rho'}(:);
lat=nc{'lat_rho'}(:,1);
lon=nc{'lon_rho'}(1,:);

if obcndx==1
  h=nc{'h'}(1,:);
  pm=nc{'pm'}(1,:);
  pn=nc{'pn'}(1,:);
  f=nc{'f'}(1,:);
  rmask=nc{'mask_rho'}(1,:);
  umask=nc{'mask_u'}(1,:);
  vmask=nc{'mask_v'}(1,:);
  suffix='_south';
elseif obcndx==2
  h=(nc{'h'}(:,L))';
  pm=(nc{'pm'}(:,L))';
  pn=(nc{'pn'}(:,L))';
  f=(nc{'f'}(:,L))';
  rmask=(nc{'mask_rho'}(:,L))';
  umask=(nc{'mask_u'}(:,L-1))';
  vmask=(nc{'mask_v'}(:,L))';
  suffix='_east';
elseif obcndx==3
  h=nc{'h'}(M,:);
  pm=nc{'pm'}(M,:);
  pn=nc{'pn'}(M,:);
  f=nc{'f'}(M,:);
  rmask=nc{'mask_rho'}(M,:);
  umask=nc{'mask_u'}(M,:);
  vmask=nc{'mask_v'}(M-1,:);
  suffix='_north';
elseif obcndx==4
  h=(nc{'h'}(:,1))';
  pm=(nc{'pm'}(:,1))';
  pn=(nc{'pn'}(:,1))';
  f=(nc{'f'}(:,1))';
  rmask=(nc{'mask_rho'}(:,1))';
  umask=(nc{'mask_u'}(:,1))';
  vmask=(nc{'mask_v'}(:,1))';
  suffix='_west';
end
Nx=length(h);
close(nc)
%
%  Levitus vertical levels
%
noa=netcdf(Zbryname,'r');
Z=-noa{'Z'}(:);
NL=length(Z);
time=noa{'bry_time'}(:);
tlen=length(time);
%
%  Model grid vertical levels
%
nc=netcdf(bryname,'write');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
hc  =  nc{'hc'}(:);
N =  length(nc('s_rho'));
vtransform = nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
%
% get the reference level
%
kref=min(find(Z<=zref));
if isempty(kref);
  kref=length(Z);
  disp(['Warning zref not found. Taking :',num2str(Z(kref))])
end
Z=Z(1:kref);
z=reshape(Z,kref,1,1);
z=repmat(z,[1 Nx]);
%
% Open the forcing file
%
if ~isempty(frcname)
nfrc=netcdf(frcname,'r');
end
%%%%%%%%%%%%%%%%%%%
% START MAIN LOOP
%%%%%%%%%%%%%%%%%%%
%
% loop on time
%
for l=1:tlen
%for l=1:1
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% read T and S
%
  T3d=squeeze(noa{['temp',suffix]}(l,1:kref,:));
  S3d=squeeze(noa{['salt',suffix]}(l,1:kref,:));
  Ts=squeeze(T3d(1,:));
  Ss=squeeze(S3d(1,:));
  rhos=rho_eos(Ts,Ss,0);
  rho=rho_eos(T3d,S3d,z);
  rho_w=.5*(rho(1:kref-1,:)+rho(2:kref,:));
  z_w=.5*(z(1:kref-1,:)+z(2:kref,:));
  dz_w=z(1:kref-1,:)-z(2:kref,:);
%
%  COMPUTE PRESSURE
%
%  disp('Pressure field and sea level ...')
  pres=0*T3d;
%  initialize pressure at kref in Pascal
  pres(kref,:)=-zref*1.e4;
  for k=kref-1:-1:1;
    pres(k,:)=pres(k+1,:)-rho_w(k,:).*g.*dz_w(k,:);
  end
%
%  compute SSH 
%
  ssh=(squeeze(pres(1,:))./(rhos*g));
%  avgssh=sum(rmask.*ssh./(pm.*pn))/sum(rmask./(pm.*pn));
%  ssh=ssh-avgssh;
%  avgp=squeeze(tridim(avgssh.*rhos*g,kref));
%  pres=pres-avgp; 
%
%  COMPUTE GEOSTROPHIC BAROCLINIC VELOCITIES
%
%  disp('Baroclinic geostrophic component ...')
  pn3d=squeeze(tridim(pn,kref)); 
  pm3d=squeeze(tridim(pm,kref)); 
  f3d=squeeze(tridim(f,kref)); 
  m3d=squeeze(tridim(rmask,kref));   
  if  obcndx==1 |  obcndx==3
    p_u=0.5*(pres(:,1:Nx-1)+pres(:,2:Nx));
    px(:,2:Nx-1)=p_u(:,2:Nx-1)-p_u(:,1:Nx-2);
    px(:,1)=2.*px(:,2)-px(:,3);
    px(:,Nx)=2.*px(:,Nx-1)-px(:,Nx-2);
    v_r=m3d.*pm3d.*px./(rho0*f3d);
    u_r=0*v_r;
  end
  if  obcndx==2 |  obcndx==4
    p_v=0.5*(pres(:,1:Nx-1)+pres(:,2:Nx));
    py(:,2:Nx-1)=p_v(:,2:Nx-1)-p_v(:,1:Nx-2);
    py(:,1)=2.*py(:,2)-py(:,3);
    py(:,Nx)=2.*py(:,Nx-1)-py(:,Nx-2);
    u_r=-m3d.*pn3d.*py./(rho0*f3d);
    v_r=0*u_r;
  end
%
% Ekman transport
%
  if ~isempty(frcname)
%    disp('Add the Ekman transport')
    if obcndx==1
      tmp=squeeze(nfrc{'sustr'}(l,1,:));
      sustr=0*h; 
      sustr(2:end-1)=0.5*(tmp(1:end-1)+tmp(2:end)); 
      sustr(1)=sustr(2);
      sustr(end)=sustr(end-1);
      svstr=squeeze(nfrc{'svstr'}(l,1,:));
    elseif obcndx==2
      sustr=(squeeze(nfrc{'sustr'}(l,:,L-1)))';
      svstr=0*h; 
      tmp=(squeeze(nfrc{'svstr'}(l,:,L)))';
      svstr(2:end-1)=0.5*(tmp(1:end-1)+tmp(2:end)); 
      svstr(1)=svstr(2);
      svstr(end)=svstr(end-1);
    elseif obcndx==3
      tmp=squeeze(nfrc{'sustr'}(l,M,:));
      sustr=0*h; 
      sustr(2:end-1)=0.5*(tmp(1:end-1)+tmp(2:end)); 
      sustr(1)=sustr(2);
      sustr(end)=sustr(end-1);
      svstr=squeeze(nfrc{'svstr'}(l,M-1,:));
    elseif obcndx==4
      sustr=(squeeze(nfrc{'sustr'}(l,:,1)))';
      svstr=0*h; 
      tmp=(squeeze(nfrc{'svstr'}(l,:,1)))';
      svstr(2:end-1)=0.5*(tmp(1:end-1)+tmp(2:end)); 
      svstr(1)=svstr(2);
      svstr(end)=svstr(end-1);
    end
    k_ekman=min(find(Z<=-De));
    u_r(1:k_ekman,:)=u_r(1:k_ekman,:)+squeeze(tridim(rmask.*...
                       svstr./(rho0*De*f),k_ekman));
    v_r(1:k_ekman,:)=v_r(1:k_ekman,:)+squeeze(tridim(-rmask.*...
                      sustr./(rho0*De*f),k_ekman));
 end



% Replace/interpolate Equatorial values 
 %
 if  obcndx==2 | obcndx==4
     equatlat=(lat >=-2 & lat <=2);
     disp(['OBCNDX=',num2str(obcndx)])
     if sum(sum(equatlat))==0
         disp('No values outside the Equator to extrapole')
     else
         disp('Extrapole values outside the Equator')
         D=find(~equatlat);
         if length(D)~=0
             for k=1:kref
                 u_r(k,:)=interp1(lat(D),u_r(k,D),lat,'spline','extrap');
                 v_r(k,:)=interp1(lat(D),v_r(k,D),lat,'spline','extrap');
             end
         else
             disp('No values outside the Equator to extrapole')
         end
     end

 elseif obcndx==1
     disp(['OBCNDX=',num2str(obcndx)])
     if (latr(1,1) < -2 | latr(1,1) > 2 )
         disp(['OK South boundary outside of the equatorial band'])
     else
         error(['Replace your South boundary'])
     end
%
 elseif obcndx==3
     disp(['OBCNDX=',num2str(obcndx)])
     if ( latr(end,1) < -2 | latr(end,1) > 2)
         disp(['OK North boundary outside of the equatorial band'])
     else
         error(['Replace your North boundary'])
     end
 end
%
%  Masking
%  
  umask3d=squeeze(tridim(umask,kref)); 
  vmask3d=squeeze(tridim(vmask,kref)); 
  if  obcndx==1 |  obcndx==3
    u=umask3d.*0.5.*(u_r(:,1:end-1)+u_r(:,2:end));
    v=vmask3d.*v_r;
  end
  if  obcndx==2 |  obcndx==4
    u=umask3d.*u_r;
    v=vmask3d.*0.5.*(v_r(:,1:end-1)+v_r(:,2:end));
  end
  ssh=ssh.*rmask; 
%
% Vertical interpolation of baroclinic fields
%
%  disp('Vertical interpolation ...')
  zcroco=squeeze(zlevs(h,0*h,theta_s,theta_b,hc,N,'r',vtransform));
  if  obcndx==1 |  obcndx==3
    zu=0.5*(zcroco(:,1:end-1)+zcroco(:,2:end));
    zv=zcroco;
  end
  if  obcndx==2 |  obcndx==4
    zu=zcroco;
    zv=0.5*(zcroco(:,1:end-1)+zcroco(:,2:end));
  end
%
% Add non gradient velocities at the top and nul velocities 
% at -10000m for vertical extrapolation.
%
  u=cat(1,u(1,:),u);
  v=cat(1,v(1,:),v);
  u=flipdim(cat(1,u,0*u(1,:)),1);
  v=flipdim(cat(1,v,0*v(1,:)),1);
  z1=flipud([100;Z;-10000]);
%
% Do the interpolation
%
  u=ztosigma_1d(u,zu,z1);
  v=ztosigma_1d(v,zv,z1);
%
%  Barotropic velocities
%
%  disp('Barotropic component ...')
  zw=squeeze(zlevs(h,0*h,theta_s,theta_b,hc,N,'w',vtransform));
  dz=zw(2:end,:)-zw(1:end-1,:);
  if  obcndx==1 |  obcndx==3
    dzu=0.5*(dz(:,1:end-1)+dz(:,2:end));
    dzv=dz;
  end
  if  obcndx==2 |  obcndx==4
    dzu=dz;
    dzv=0.5*(dz(:,1:end-1)+dz(:,2:end));
  end
  hu=sum(dzu.*u);
  hv=sum(dzv.*v);
  D_u=sum(dzu);
  D_v=sum(dzv);
  ubar=hu./D_u;
  vbar=hv./D_v;
%
% corners     (beurk.....)
%
  ubar(1)=0.5*ubar(2); 
  ubar(end)=0.5*ubar(end-1); 
  vbar(1)=0.5*vbar(2); 
  vbar(end)=0.5*vbar(end-1); 
  u(:,1)=0.5*u(:,2); 
  u(:,end)=0.5*u(:,end-1); 
  v(:,1)=0.5*v(:,2); 
  v(:,end)=0.5*v(:,end-1); 
%
%  Write into file
%
%  disp('Writes into climatology file ...')
  nc{['u',suffix]}(l,:,:)=u;
  nc{['v',suffix]}(l,:,:)=v;
  nc{['ubar',suffix]}(l,:)=ubar;
  nc{['vbar',suffix]}(l,:)=vbar;
  nc{['zeta',suffix]}(l,:)=ssh;
end
close(nc)
%
% Close the forcing file
%
if ~isempty(frcname)
  close(nfrc);
end
