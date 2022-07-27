%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  get_transport_func: Compute a streamfunction for a transport
% between two depths.
%
% problem: for the moment work with 1 island max
%
%  Pierrick Penven 2015
%
%                                             
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%
crocotools_param
%
% Directory and file names
%
directory=[RUN_dir,'SCRATCH/'];
model='croco';
%
% CROCO average name
%
fname=[directory,model,'_Smean.nc'];
%
% Time index: 5 annual mean
%
l=5;
%
%  !!! WARNING weak point: vtransform should be the one used for CROCO
%
vtransform=1;
%
% Lower level (NaN=bottom)
%
z1=-1000;
%
% Upper level (NaN=surface)
%
z2=NaN;
%
% Output matlab file
%
outname='transport_croco.mat';
%
% Read data
%
nc=netcdf(fname);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
rmask=nc{'mask_rho'}(:);
h=nc{'h'}(:);
theta_s=nc.theta_s(:);
theta_b=nc.theta_b(:);
hc=nc.hc(:);
N=length(nc('s_rho'));
zeta=squeeze(nc{'zeta'}(l,:,:));
u=squeeze(nc{'u'}(l,:,:,:));
v=squeeze(nc{'v'}(l,:,:,:));
T=squeeze(nc{'temp'}(l,:,:,:));
close(nc);
%
%  Get the transport between the surface and z0
%
%
%
zw=zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
zr=zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
%
[u,hu]=vintegr2(u,rho2u_3d(zw),rho2u_3d(zr),z1,z2);
[v,hv]=vintegr2(v,rho2v_3d(zw),rho2v_3d(zr),z1,z2);
[T,h0]=vintegr2(T,zw,zr,z1,z2);
%
% Compute PSI
%
[u,v]=get_obcvolcons(u,v,pm,pn,rmask,[1 1 1 1]);
[psi0,psi1,island]=get_psi0(u,v,pm,pn,rmask);  
if sum(sum(island))==0
  A=0;
else
  A=get_a(u,v,psi0,psi1,island,pm,pn);
end
psi=psi0+A*psi1;
mask=rmask;
mask(mask==0)=NaN;
save(outname,'lon','lat','mask','u','v','psi','h','z1','z2')
%
% PLot
%
plot_transport(outname)
