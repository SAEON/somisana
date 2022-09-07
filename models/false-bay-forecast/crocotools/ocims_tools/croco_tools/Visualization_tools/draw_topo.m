function [C,h]=draw_topo(fname,npts,levs,options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add topography to the plot
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
  disp('Default level: 500 m')
  levs=[500 500];
end
if nargin < 3
  disp('Default option: k')
  options='k';
end

[lat,lon,mask]=read_latlonmask(fname,'r');
nc=netcdf(fname);
topo=nc{'h'}(:);
close(nc);
lat=rempoints(lat,npts);
lon=rempoints(lon,npts);
mask=rempoints(mask,npts);
topo=rempoints(topo,npts);
warning off
mask=mask./mask;
warning on

[C,h]=m_contour(lon,lat,mask.*topo,levs,options);

if ~hold_state, hold off; 
end
return
