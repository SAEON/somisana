close all
clear all
clim_file='croco_clm.nc';
ini_file='croco_ini.nc';
grid_file='croco_grd.nc';
tracer='temp'
l=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the climatology and initial files.
% pierrick 1/2000
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(clim_file,'r');
var=squeeze(nc{tracer}(l,:,:,:));
[N M L]=size(var);
theta_s=nc{'theta_s'}(:);
if isempty(theta_s)
  theta_s=nc.theta_s(:);
  theta_b=nc.theta_b(:);
  hc=nc.hc(:);
else
  theta_b=nc{'theta_b'}(:);
  hc=nc{'hc'}(:);
end
close(nc)
nc=netcdf(grid_file,'r');
lat=nc{'lat_rho'}(:);
lon=nc{'lon_rho'}(:);
pm=nc{'pm'}(:);
h=nc{'h'}(:);
angle=nc{'angle'}(:);
mask=nc{'mask_rho'}(:);
close(nc)
mask(mask==0)=NaN;
nc=netcdf(ini_file,'r');
var=var-squeeze(nc{tracer}(l,:,:,:));
close(nc)

jstep=round((M/3)-1);
image=0;
z = zlevs(h,0*h,theta_s,theta_b,hc,N,'r');
for j=1:jstep:M
  index=j;
  image=image+1;
  subplot(2,2,image)
  field=squeeze(var(:,j,:));
  topo=squeeze(h(j,:));
  mask_vert=squeeze(mask(j,:));
  dx=1./squeeze(pm(j,:));
  xrad(1)=0;
  for i=2:L
    xrad(i)=xrad(i-1)+0.5*(dx(i)+dx(i-1));
  end
  x=zeros(N,L);
  masksection=zeros(N,L);
  for i=1:L
    for k=1:N
      x(k,i)=xrad(i);
      masksection(k,i)=mask_vert(i);
    end
  end
  xrad=xrad/1000;
  x=x/1000;
  field=masksection.*field;
  pcolor(x,squeeze(z(:,j,:)),field) 
  colorbar
  shading interp
  hold on
  plot(xrad,-topo,'k')
  hold off
  title(num2str(j))
end
