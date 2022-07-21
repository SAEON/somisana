function h=add_speed_vec(fname,gname,tindex,level,skp,npts,...
                         scale,x0,y0,u_unit,units,...
                         fontsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  h=add_speed_vec(fname,gname,tindex,level,skp,npts,...
%                         scale,x0,y0,u_unit,units,...
%                         fontsize)
%
%  Add speed vectors on a plot.
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold_state = ishold;
%
% Defaults values
%

if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  disp('Default time index: 1')
  tindex=1;
end
if nargin < 3
  disp('Default level: -10 m')
  level= -10;
end
if nargin < 4
  disp('Default skip parameter: 1')
  skp=1;
end
if nargin < 5
  disp('Default boundary remove: [0 0 0 0]')
  npts=[0 0 0 0];
end
if nargin < 6
  disp('Default scale: 1')
  scale=1;
end

[lat,lon,mask]=read_latlonmask(gname,'r');
nc=netcdf(gname);
angle=nc{'angle'}(:);
if isempty(angle)
 disp('Warning: no angle found in history file')
 angle=0*lat;
end
close(nc);
mask(mask==0)=NaN;


if level==0
  u=get_hslice(fname,gname,'ubar',tindex,level,'u');
  v=get_hslice(fname,gname,'vbar',tindex,level,'v');
else
  u=get_hslice(fname,gname,'u',tindex,level,'u');
  v=get_hslice(fname,gname,'v',tindex,level,'v');
end
[u,v,lon,lat,mask]=uv_vec2rho(u,v,lon,lat,angle,mask,skp,npts);
  
if nargin < 8
  u=u*scale/20;
  v=v*scale/20;
  h=m_quiver_cst(lon,lat,u,v,0,'k');
else
  h=m_quiver_fix(lon,lat,u,v,scale,x0,y0,u_unit,units,...
                         fontsize);
end
if ~hold_state, hold off; 
end
return
