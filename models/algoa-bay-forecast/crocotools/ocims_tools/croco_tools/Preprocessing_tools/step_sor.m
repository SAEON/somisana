%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  1 Step of the elliptic solver (SOR) used in get_psi.m
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
%  Contribution of S. Herbette (UBO)
%
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
% Adpated from a matlab script of S. Herbette (UBO)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Get the right hand side terms of the equations
%
rhs(2:end-1,2:end-1)=...
a2(2:end-1,2:end-1).*psi(2:end-1,3:end)+...
a3(2:end-1,2:end-1).*psi(2:end-1,1:end-2)+...
a4(2:end-1,2:end-1).*psi(3:end,2:end-1)+...
a5(2:end-1,2:end-1).*psi(1:end-2,2:end-1)+...
b1(2:end-1,2:end-1).*psi(2:end-1,2:end-1)+...
b2(2:end-1,2:end-1).*xi(2:end-1,2:end-1);
%
% Step PSI
%
psi(ijeven==parity)=psi(ijeven==parity)-...
                    W.*rhs(ijeven==parity)./...
                    b1(ijeven==parity);
%
% Advance the surrelaxation parameter
%
W=1/(1-J2*W/4);
%
% Apply the mask (not the islands bcpsi~=0)
%
psi(pmask==0 & bcpsi~=0)=bcpsi(pmask==0 & bcpsi~=0);
%
%
%
return
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
