function plot_nestforcing(child_frc,thefield,thetime,skip)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the embedded forcing file.
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
npts=[0 0 0 0];
i=0;
for time=thetime
  i=i+1;
  
  subplot(2,length(thetime),i)


  nc=netcdf(child_frc);
  parent_frc=nc.parent_file(:);
  child_grd=nc.grd_file(:);
  u=nc{'sustr'}(time,:,:);
  v=nc{'svstr'}(time,:,:);
  if thefield(1:3)=='spd'
    fieldc=sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
    fieldname='wind speed';
  else
    fieldc=nc{thefield}(time,:,:);
    fieldname=nc{thefield}.long_name(:);
  end
  result=close(nc);

  nc=netcdf(child_grd);
  parent_grd=nc.parent_grid(:);
  refinecoeff=nc{'refine_coef'}(:);
  lonc=nc{'lon_rho'}(:);
  latc=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  angle=nc{'angle'}(:);
  result=close(nc);
  warning off
  mask=mask./mask;
  warning on
  [ured,vred,lonred,latred,maskred]=...
  uv_vec2rho(u,v,lonc,latc,angle,mask,skip*refinecoeff,npts);
  pcolor(lonc,latc,mask.*fieldc)
  shading interp
  axis image
  caxis([min(min(fieldc)) max(max(fieldc))])
  colorbar
  hold on
  quiver(lonred,latred,ured,vred,'k')
  hold off
  axis([min(min(lonc)) max(max(lonc)) min(min(latc)) max(max(latc))])


  subplot(2,length(thetime),i+length(thetime))

  nc=netcdf(parent_frc);
  u=nc{'sustr'}(time,:,:);
  v=nc{'svstr'}(time,:,:);
  if thefield(1:3)=='spd'
    field=sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
    fieldname='wind speed';
  else
    field=nc{thefield}(time,:,:);
    fieldname=nc{thefield}.long_name(:);
  end
  result=close(nc);
  nc=netcdf(parent_grd);
  lon=nc{'lon_rho'}(:);
  lat=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  angle=nc{'angle'}(:);
  result=close(nc);
  warning off
  mask=mask./mask;
  warning on
  [ured,vred,lonred,latred,maskred]=...
  uv_vec2rho(u,v,lon,lat,angle,mask,skip,npts);
  pcolor(lon,lat,mask.*field)
  shading interp
  axis image
  caxis([min(min(fieldc)) max(max(fieldc))])
  colorbar
  hold on
  quiver(lonred,latred,ured,vred,'k')
  hold off
  axis([min(min(lonc)) max(max(lonc)) min(min(latc)) max(max(latc))])
end


return



