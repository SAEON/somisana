function z = zlevs_1d(h, zeta, theta_s, theta_b, hc, N, type, vtransform)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function z = zlevs_1d(h, zeta, theta_s, theta_b, hc, N, type, vtransform)
%
%  this function compute the depth of rho or w points for CROCO
%
%  On Input:
%
%    type    'r': rho point 'w': w point
%    oldnew     : old (Song, 1994) or new s-coord (Sasha, 2006)
%
%  On Output:
%
%    z=z(k)       Depths (m) of RHO- or W-points (1D matrix).
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M, L] = size(h);
%
% Set S-Curves in domain [-1 < sc < 0] at vertical W- and RHO-points.
%
cff1 = 1./sinh(theta_s);
cff2 = 0.5/tanh(0.5*theta_s);
if type=='w'
  sc = ((0:N) - N) / N;
  N = N + 1;
else
  sc=((1:N)-N-0.5) / N;
end

Cs = (1.-theta_b) * cff1 * sinh(theta_s * sc)...
    + theta_b * (cff2 * tanh(theta_s * (sc + 0.5)) - 0.5);
%
% Create S-coordinate system: based on model topography h(i,j),
% fast-time-averaged free-surface field and vertical coordinate
% transformation metrics compute evolving depths of of the three-
% dimensional model grid.
%
z=zeros(N,1);
if (vtransform==1)
    disp('--- using old s-coord')
    hinv=1./h;
    cff=hc*(sc-Cs);
    cff1=Cs;
    cff2=sc+1;
    for k=1:N
        z0=cff(k)+cff1(k)*h;
        z(k)=z0+zeta.*(1.+z0.*hinv);
    end
elseif (vtransform==2)
    disp('--- using new s-coord')
    hinv=1./(h+hc);
    cff=hc*sc;
    cff1=Cs;
    for k=1:N
        z(k)=zeta+(zeta+h).*(cff(k)+cff1(k)*h).*hinv;
    end
else
    error('wrong argument in zlevs_1d');
end

return

