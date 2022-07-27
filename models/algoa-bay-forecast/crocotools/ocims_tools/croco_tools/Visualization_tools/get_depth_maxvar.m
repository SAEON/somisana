function h=get_depth_maxvar(var,z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the depth of the maximum of a 3D CROCO variable
%
%  Input:
%         var CROCO 3D matrix
%         z   CROCO 3D matrix of the z levels
%  Output:
%         h   Depth of the maximum of var
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
varmax=var-tridim(squeeze(max(var)),N);
a=(varmax==0);
%
% remove the points that have more or less than 1 max..
%
m1=squeeze(sum(a));
m3=tridim(m1,N);
a(m3~=1)=0;
b=squeeze(a(N,:,:))+m1~=1;
a(N,:,:)=b;
%
% Get the depth
%
h=z(a==1);
h=reshape(h,M,L);
%
zmin=squeeze(min(z));
zmax=squeeze(max(z));
h(h<zmin)=NaN;
h(h>zmax)=NaN;

return
