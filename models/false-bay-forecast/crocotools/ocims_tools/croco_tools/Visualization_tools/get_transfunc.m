function [lat,lon,rmask,psi]=get_transfunc(hisfile,gridfile,tindex,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the vertically integrated transport function
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Get the grid parameters
%
[lat,lon,rmask]=read_latlonmask(gridfile,'r');
rmask(isnan(rmask))=0;
nc=netcdf(gridfile);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
h=nc{'h'}(:);
close(nc);
[umask,vmask,pmask]=uvp_mask(rmask);
%
% Get the currents
%
ubar=get_hslice(hisfile,gridfile,'ubar',tindex,0,'u');
vbar=get_hslice(hisfile,gridfile,'vbar',tindex,0,'v');
zeta=get_hslice(hisfile,gridfile,'zeta',tindex,0,'r');
Du=ubar.*rho2u_2d(h+zeta);
Dv=vbar.*rho2v_2d(h+zeta);

%
% Boundary conditions
%
[Du,Dv]=get_obcvolcons(Du,Dv,pm,pn,rmask,[1 1 1 1]);
psi=1e-6*coef.*psi2rho(get_psi(Du,Dv,pm,pn,rmask));
