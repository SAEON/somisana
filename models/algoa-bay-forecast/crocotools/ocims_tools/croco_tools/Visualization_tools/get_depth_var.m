function h=get_depth_var(var,z,var0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  get the depth of a specific value (var0) in a 3D CROCO variable (var)
%
%  var should be monotically increasing or decreasing with z 
%
%  Input:
%         var    CROCO 3D matrix
%         z      CROCO 3D matrix of the z levels
%         var0   Get the depth of this value
%  Output:
%         h      Depth of var0
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
[N,M,L]=size(z);
%
% Create a boolean matrix (0 if we are above var0)
%
a=var<var0;
%
%  Find the position of the level
% 
levs=squeeze(sum(a,1));
[imat,jmat]=meshgrid((1:L),(1:M));
pos=N*M*(imat-1)+N*(jmat-1)+levs;
pos(levs>=N)=1;
pos(levs<=1)=1;
%
% Do the vertical interpolation
%
z1=z(pos+1);
z2=z(pos);
v1=var(pos+1);
v2=var(pos);
h=(var0.*(z1-z2)-v2.*z1+v1.*z2)./(v1-v2);
%
zmin=squeeze(min(z));
zmax=squeeze(max(z));
h(levs>=N)=NaN;
h(levs<=1)=NaN;
h(h<zmin)=NaN;
h(h>zmax)=NaN;
%
return
