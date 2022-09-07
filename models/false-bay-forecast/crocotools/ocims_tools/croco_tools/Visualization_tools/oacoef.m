function coef = oacoef(londata,latdata,lon,lat,ro)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function extrfield = oacoef(londata,latdata,lon,lat,ro)
%
% compute an objective analysis on a scalar field.
%
%   input: 
%  londata   : longitude of data points (vector)
%  latdata   : latitude of data points (vector)
%  lon       : longitude of the estimated points (vector)
%  lat       : latitude of the estimated points (vector)
%  ro        : decorrelation scale
%
%   output:
%  coef : oa matrix
%
%  extrfield=mdata+coef*(data-mdata)
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
%  Derived from the fortran programs of Alain Colin de Verdiere (2000)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
  error('Not enough input arguments')
elseif nargin < 5
  disp('using default decorrelation scale:  ro = 500 km')
  ro = 5e5;
end
%
i=[1:1:length(londata)];
j=[1:1:length(lon)];
[I,J]=meshgrid(i,i);
r1=spheric_dist(latdata(I),latdata(J),londata(I),londata(J));
%
[I,J]=meshgrid(i,j);
r2=spheric_dist(lat(J),latdata(I),lon(J),londata(I));
%
coef=exp(-r2/ro)/exp(-r1/ro);
%
return
