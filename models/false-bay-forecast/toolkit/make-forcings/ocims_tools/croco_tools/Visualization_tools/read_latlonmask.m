function [lat,lon,mask]=read_latlonmask(fname,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function [lat,lon,mask]=read_latlonmask(fname,type);
%
% read the latitude, the longitude and the mask from a
% netcdf CROCO file 
%
% input:
%
%  fname    CROCO file name
%  type    type of the variable (character):
%             r for 'rho'
%             w for 'w'
%             u for 'u'
%             v for 'v'
%
% output:
%
%  lat      Latitude  (2D matrix) 
%  lon      Longitude (2D matrix) 
%  mask     Mask (2D matrix) (1:sea - nan:land)
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

nc=netcdf(fname);
lat=readlat(nc);
lon=readlon(nc);
mask=nc{'mask_rho'}(:);
if isempty(mask)
  mask=1+0*lon;
end
close(nc);
%
[Mp,Lp]=size(mask);
%
if (type=='u')
  lat=rho2u_2d(lat);
  lon=rho2u_2d(lon);
  mask=mask(:,1:Lp-1).*mask(:,2:Lp);
end
if (type=='v')
  lat=rho2v_2d(lat);
  lon=rho2v_2d(lon);
  mask=mask(1:Mp-1,:).*mask(2:Mp,:);
end
%
mask(mask==0)=NaN;
%
return
