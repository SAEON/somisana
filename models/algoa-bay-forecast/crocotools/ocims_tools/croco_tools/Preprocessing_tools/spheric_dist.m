 
function dist=spheric_dist(lat1,lat2,lon1,lon2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function dist=spheric_dist(lat1,lat2,lon1,lon2)
%
% compute distances for a simple spheric earth
%
%   input:
%
%  lat1 : latitude of first point (matrix)
%  lon1 : longitude of first point (matrix)
%  lat2 : latitude of second point (matrix)
%  lon2 : longitude of second point (matrix)
%
%   output:
%  dist : distance from first point to second point (matrix)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Earth radius
%
R=6367442.76;
%
%  Determine proper longitudinal shift.
%
l=abs(lon2-lon1);
l(l>=180)=360-l(l>=180);
%                  
%  Convert Decimal degrees to radians.
%
deg2rad=pi/180;
lat1=lat1*deg2rad;
lat2=lat2*deg2rad;
l=l*deg2rad;
%
%  Compute the distances
%
dist=R*asin(sqrt(((sin(l).*cos(lat2)).^2)+(((sin(lat2).*cos(lat1))-...
         (sin(lat1).*cos(lat2).*cos(l))).^2)));
return
