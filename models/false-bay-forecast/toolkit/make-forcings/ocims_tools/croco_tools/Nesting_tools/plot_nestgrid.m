function plot_nestgrid(h,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the embedded grid file.
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

if ~isempty(handles)
  set(handles.figure1,'HandleVisibility','on','CurrentAxes',handles.axes1);
  cla
end
nc=netcdf(handles.parentgrid);
if isempty(nc)
  disp('PLOT_NESTGRID : this is not a netcdf file !!!')
  return
end
rlon=nc{'lon_rho'}(:);
rlat=nc{'lat_rho'}(:);
plon=nc{'lon_psi'}(:);
plat=nc{'lat_psi'}(:);
mask=nc{'mask_rho'}(:);
mask(mask==0)=NaN;
h=nc{'h'}(:);
close(nc)
%
%
% Get the domain
%
if isempty(handles.lonmin)
  handles.lonmin=min(min(rlon));
end
if isempty(handles.lonmax)
  handles.lonmax=max(max(rlon));
end
if isempty(handles.latmin)
  handles.latmin=min(min(rlat));
end
if isempty(handles.latmax)
  handles.latmax=max(max(rlat));
end
%
% Do the plot
%
m_proj('mercator',...
       'lon',[handles.lonmin handles.lonmax],...
       'lat',[handles.latmin handles.latmax]);
m_pcolor(rlon,rlat,mask.*h);
shading flat
if ~isempty(handles.imin)
  lonbox=cat(1,plon(handles.jmin:handles.jmax,handles.imin),  ...
             plon(handles.jmax,handles.imin:handles.imax)' ,...
             plon(handles.jmax:-1:handles.jmin,handles.imax),...
             plon(handles.jmin,handles.imax:-1:handles.imin)' );
  latbox=cat(1,plat(handles.jmin:handles.jmax,handles.imin),  ...
             plat(handles.jmax,handles.imin:handles.imax)' ,...
             plat(handles.jmax:-1:handles.jmin,handles.imax),...
             plat(handles.jmin,handles.imax:-1:handles.imin)' );
  [px,py]=m_ll2xy(lonbox,latbox);
  hold on
  plot(px,py,'k')
  hold off
end
%
% Plot the river
%
if (~isempty(handles.Isrcparent)) & ~(isempty(handles.Jsrcparent))
  lon_src=rlon(handles.Jsrcparent+1,handles.Isrcparent+1);
  lat_src=rlat(handles.Jsrcparent+1,handles.Isrcparent+1);
  [px,py]=m_ll2xy(lon_src,lat_src);
  hold on
  plot(px,py,'ro')
  hold off
end

m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out');
set(findobj('tag','m_grid_color'),'facecolor','white');

return
