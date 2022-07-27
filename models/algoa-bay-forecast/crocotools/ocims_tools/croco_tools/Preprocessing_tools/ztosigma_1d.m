function vnew = ztosigma_1d(var,z,depth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function  vnew = ztosigma_1d(var,z,depth)
%
% This function transform a variable from z to sigma coordinates
%    warning: the variable must be in the form: var(k,i)
%
% On Input:
%
%    var     Variable z (2D matrix).
%    z       Sigma depths (m) of RHO- or W-points (2D matrix).
%    depth   z depth (vector; meters, negative).
% 
% On Output:
%
%    vnew    Variable sigma (2D matrix).
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

[Ns,Mp]=size(z);
[Nz]=length(depth);
vnew=0*z;
%
% Find the grid position of the nearest vertical levels
%
for ks=1:Ns
  sigmalev=squeeze(z(ks,:))';
  thezlevs=0.*sigmalev;
  for kz=1:Nz
    thezlevs(sigmalev>depth(kz))=thezlevs(sigmalev>depth(kz))+1;
  end
  if max(max(thezlevs))>=Nz | min(min(thezlevs))<=0
    disp(['min sigma level = ',num2str(min(min(min(z)))),...
           ' - min z level = ',num2str(min(depth))])
    disp(['max sigma level = ',num2str(max(max(max(z)))),...
           ' - max z level = ',num2str(max(depth))])
  end
  jmat=(1:Mp)';
  pos=Nz*(jmat-1)+thezlevs;
  z1=depth(thezlevs);
  z2=depth(thezlevs+1);
  v1=var(pos);
  v2=var(pos+1);
  vnew(ks,:)=(((v1-v2).*sigmalev+v2.*z1-v1.*z2)./(z1-z2))';
end
return
