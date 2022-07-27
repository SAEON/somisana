function extrfield = oainterp(londata,latdata,data,lon,lat,ro,savefile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function extrfield = oainterp(londata,latdata,data,lon,lat,ro)
%
%
% compute an objective analysis on a scalar field.
%
%   input: 
%  londata   : longitude of data points (vector)
%  latdata   : latitude of data points (vector)
%  data      : values of the data points (vector)
%  lon       : longitude of the estimated points (vector)
%  lat       : latitude of the estimated points (vector)
%  ro        : decorrelation scale
%  savefile  : to avoid recomputing r1 and r2 
%		2 do nothing
%		1 save r1 and r2 in tmp.mat
% 		0 load r1 and r2 from tmp.mat
%
%   output:
%  extrfield : estimated values (vector)
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
%  Derived from a fortran program of Alain Colin de 
%  Verdiere (UBO, 2000)
%
%  Updated    2-Oct-2006 by Xavier Capet and Pierrick Penven 
%                        (add the 'savefile option')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 5
  error('Not enough input arguments')
elseif nargin < 6
  disp('using default decorrelation scale:  ro = 500 km')
  ro = 5e5;
end
if nargin < 7 
  savefile=2;
end
%
mdata=mean(data);
data=data-mdata;
%
if savefile ~=0
  invro=1/ro;
  i=[1:1:length(londata)];
  j=[1:1:length(lon)];
  [I,J]=meshgrid(i,i);
  r1=spheric_dist(latdata(I),latdata(J),londata(I),londata(J));
%
  [I,J]=meshgrid(i,j);
  r2=spheric_dist(lat(J),latdata(I),lon(J),londata(I));
%
  if savefile ==1
    save tmp.mat r1 r2 invro;
  end
%
elseif savefile==0 
  load tmp.mat;
end
%
extrfield=mdata+(exp(-r2*invro)/exp(-r1*invro))*data;
%
return

