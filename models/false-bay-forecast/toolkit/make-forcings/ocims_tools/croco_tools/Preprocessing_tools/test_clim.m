function test_clim(clim_file,grid_file,tracer,l,coastfileplot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    1-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


niceplot=1;
%
nc=netcdf(clim_file,'r');
var=squeeze(nc{tracer}(l,:,:,:));
[N M L]=size(var);
u=squeeze(nc{'u'}(l,N,:,:));
v=squeeze(nc{'v'}(l,N,:,:));
theta_s=nc{'theta_s'}(:);
if isempty(theta_s)
  theta_s=nc.theta_s(:);
  theta_b=nc.theta_b(:);
  hc=nc.hc(:);
else
  theta_b=nc{'theta_b'}(:);
  hc=nc{'hc'}(:);
  vtransform=nc{'Vtransform'}(:);
    if  ~exist('vtransform')
      vtransform=1; %Old Vtransform
      disp([' NO VTRANSFORM parameter found'])
      disp([' USE TRANSFORM default value vtransform = 1'])
    end
end
close(nc)
%
% Get the grid
%
      nc=netcdf(grid_file,'r');
lat=nc{'lat_rho'}(:);
lon=nc{'lon_rho'}(:);
pm=nc{'pm'}(:);
h=nc{'h'}(:);
angle=nc{'angle'}(:);
mask=nc{'mask_rho'}(:);
mask(mask==0)=NaN;
%
% plot the sections
%
jstep=ceil((M/3)-1);
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
% $$$   x
% $$$   squeeze(z(:,j,:))
% $$$   field
  
  pcolor(x,squeeze(z(:,j,:)),field) 
  drawnow
  colorbar
  shading interp
  hold on
  plot(xrad,-topo,'k')
  hold off
  title([tracer,', time index=',num2str(l),' - j=',num2str(j)])
end
%
% Surface plot
%
figure
field=squeeze(var(N,:,:));
[ured,vred,lonred,latred,maskred]=uv_vec2rho(u,v,lon,lat,angle,mask,3,[0 0 0 0]);
spd=sqrt(ured.^2+vred.^2);
if niceplot==1
  domaxis=[min(min(lon)) max(max(lon)) min(min(lat)) max(max(lat))];
  m_proj('mercator',...
     'lon',[domaxis(1) domaxis(2)],...
     'lat',[domaxis(3) domaxis(4)]);
  m_pcolor(lon,lat,mask.*field);
  shading flat
  colorbar
  hold on
  m_quiver(lonred,latred,ured,vred,'k');
  if ~isempty(coastfileplot)
    m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
  end
  hold off
  title([tracer,', max speed=',num2str(100*max(max(spd)),2),....
         ' cm/s, time index=',num2str(l)])
  m_grid('box','fancy',...
         'xtick',5,'ytick',5,'tickdir','out',...
	 'fontsize',7);
else
  imagesc(mask.*field)
  colorbar
  title([tracer, ', time index=',num2str(l)])
end


