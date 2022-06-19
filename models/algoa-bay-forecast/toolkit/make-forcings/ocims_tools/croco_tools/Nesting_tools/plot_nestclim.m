function plot_nestclim(clim_file,grid_file,tracer,l)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the climatology and initial files.
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(clim_file);
var=squeeze(nc{tracer}(l,:,:,:));
[N M L]=size(var);
u=squeeze(nc{'u'}(l,N,:,:));
v=squeeze(nc{'v'}(l,N,:,:));
theta_s=nc{'theta_s'}(:);
vtransform=nc{'Vtransform'}(:);
if isempty(theta_s)
  theta_s=nc.theta_s(:);
  theta_b=nc.theta_b(:);
  hc=nc.hc(:);
else
  theta_b=nc{'theta_b'}(:);
  hc=nc{'hc'}(:);
end
if  ~exist('vtransform') | isempty(vtransform)
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
close(nc)
nc=netcdf(grid_file);

lat=nc{'lat_rho'}(:);
lon=nc{'lon_rho'}(:);
pm=nc{'pm'}(:);
h=nc{'h'}(:);
angle=nc{'angle'}(:);
mask=nc{'mask_rho'}(:);
warning off
mask=mask./mask;
warning on

jstep=round((M/3)-1);
image=0;
z = zlevs(h,0*h,theta_s,theta_b,hc,N,'r',vtransform);
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


figure
sst=squeeze(var(N,:,:));
[u,v,lonred,latred,maskred]=uv_vec2rho(u,v,lon,lat,angle,mask,3,[0 0 0 0]);
spd=sqrt(u.^2+v.^2);
pcolor(lon,lat,mask.*sst)
shading flat
hold on
quiver(lonred,latred,u,v,'k')
hold off
axis image
colorbar
title(['max speed : ',num2str(100*max(max(spd))),' cm/s'])


return



