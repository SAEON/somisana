function barotropic_currents(clmname,grdname,obc)
%
% Pierrick 2003
%
% Get the barotropic velocities from the baroclinic currents
% Enforce mass conservation
%
conserv=1;
%
%  grid parameters
%
disp(' Read grid parameters ...');
nc=netcdf(grdname,'r');
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
h=nc{'h'}(:);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
rmask=nc{'mask_rho'}(:);
umask=nc{'mask_u'}(:);
vmask=nc{'mask_v'}(:);
[M,L]=size(rmask);
close(nc)
%
%  Model grid vertical levels
%
nc=netcdf(clmname,'write');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
hc  =  nc{'hc'}(:);
vtransform = nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
N =  length(nc('s_rho'));
tlen = length(nc('uclm_time'));
%
%  Barotropic velocities
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  zeta=squeeze(nc{'zeta'}(l,:,:));
  u=squeeze(nc{'u'}(l,:,:,:));
  v=squeeze(nc{'v'}(l,:,:,:));
  zw=zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
  dz=zw(2:end,:,:)-zw(1:end-1,:,:);
  dzu=0.5*(dz(:,:,1:end-1)+dz(:,:,2:end));
  dzv=0.5*(dz(:,1:end-1,:)+dz(:,2:end,:));
  hu(:,:)=sum(dzu.*u);
  hv(:,:)=sum(dzv.*v);
  D_u(:,:)=sum(dzu);
  D_v(:,:)=sum(dzv);
  ubar(:,:)=hu./D_u;
  vbar(:,:)=hv./D_v;
  u=u-tridim(ubar,N);
  v=v-tridim(vbar,N);
%
% Mass conservation
%
  if conserv==1
    disp('Volume conservation enforcement ...')
    [hu,hv]=get_obcvolcons(hu,hv,pm,pn,rmask,obc);
%
% Get the stream function
%
    psi=get_psi(hu,hv,pm,pn,rmask); 
    hu(2:end-1,1:end)=-0.5*umask(2:end-1,1:end).*...
                      (psi(2:end,1:end)-psi(1:end-1,1:end)).*...
                      (pn(2:end-1,2:end)+pn(2:end-1,1:end-1));
    hv(1:end,2:end-1)=0.5*vmask(1:end,2:end-1).*...
                     (psi(1:end,2:end)-psi(1:end,1:end-1)).*...
                     (pm(2:end,2:end-1)+pm(1:end-1,2:end-1));
    [hu,hv]=get_obcvolcons(hu,hv,pm,pn,rmask,obc);
    ubar(:,:)=hu./D_u;
    vbar(:,:)=hv./D_v;
  end
  u=u+tridim(ubar,N);
  v=v+tridim(vbar,N);
%
% corners
%
  ubar(1,1)=0.5*(ubar(1,2)+ubar(2,1)); 
  ubar(end,1)=0.5*(ubar(end,2)+ubar(end-1,1)); 
  ubar(1,end)=0.5*(ubar(1,end-1)+ubar(2,end)); 
  ubar(end,end)=0.5*(ubar(end,end-1)+ubar(end-1,end)); 
  vbar(1,1)=0.5*(vbar(1,2)+vbar(2,1)); 
  vbar(end,1)=0.5*(vbar(end,2)+vbar(end-1,1)); 
  vbar(1,end)=0.5*(vbar(1,end-1)+vbar(2,end)); 
  vbar(end,end)=0.5*(vbar(end,end-1)+vbar(end-1,end)); 
  u(:,1,1)=0.5*(u(:,1,2)+u(:,2,1)); 
  u(:,end,1)=0.5*(u(:,end,2)+u(:,end-1,1)); 
  u(:,1,end)=0.5*(u(:,1,end-1)+u(:,2,end)); 
  u(:,end,end)=0.5*(u(:,end,end-1)+u(:,end-1,end)); 
  v(:,1,1)=0.5*(v(:,1,2)+v(:,2,1)); 
  v(:,end,1)=0.5*(v(:,end,2)+v(:,end-1,1)); 
  v(:,1,end)=0.5*(v(:,1,end-1)+v(:,2,end)); 
  v(:,end,end)=0.5*(v(:,end,end-1)+v(:,end-1,end)); 
%
%  Write into file
%
  disp('Writes into climatology file ...')
  nc{'u'}(l,:,:,:)=u;
  nc{'v'}(l,:,:,:)=v;
  nc{'ubar'}(l,:,:)=ubar;
  nc{'vbar'}(l,:,:)=vbar;
end
close(nc)
