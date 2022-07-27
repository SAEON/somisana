function [lat,lon,mask,r]=get_rfact(hisfile,gridfile,tindex,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the r-factor
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
%  Updated 15 Nov 2006 by P. Penven - remove vlevel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lat,lon,mask]=read_latlonmask(gridfile,'r');
nc=netcdf(gridfile);
h=nc{'h'}(:);
close(nc)
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;
rx=u2rho_2d(abs(h(1:M,2:L)-h(1:M,1:Lm))./(h(1:M,2:L)+h(1:M,1:Lm)));
ry=v2rho_2d(abs(h(2:M,1:L)-h(1:Mm,1:L))./(h(2:M,1:L)+h(1:Mm,1:L)));
r=sqrt(rx.^2+ry.^2);
r=coef.*mask.*r;
return
%
