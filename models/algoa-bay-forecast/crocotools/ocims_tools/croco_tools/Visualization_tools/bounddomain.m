function h=bounddomain(lon,lat);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function h=bounddomain(lon,lat);
%
% draw a line along the boundaries of the model domain
%
% input:
%
%  lat      Latitude (2D matrix) 
%  lon      Longitude (2D matrix) 
%
% output:
%
%  h        line handle (scalar)
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    10-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Mp,Lp]=size(lon);
imin=1;
imax=Lp;
jmin=1;
jmax=Mp;
xsquare=cat(1,lon(jmin:jmax,imin),  ...
                lon(jmax,imin:imax)' ,...
                lon(jmax:-1:jmin,imax),...
                lon(jmin,imax:-1:imin)' );
ysquare=cat(1,lat(jmin:jmax,imin),  ...
                lat(jmax,imin:imax)' ,...
                lat(jmax:-1:jmin,imax),...
                lat(jmin,imax:-1:imin)' );
h=m_line(xsquare,ysquare);
return
