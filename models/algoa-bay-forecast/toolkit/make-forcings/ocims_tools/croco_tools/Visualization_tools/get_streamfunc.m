function [lat,lon,mask,psi]=get_streamfunc(hisfile,gridfile,tindex,vlevel,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute a streamfunction from an horizontal vector field
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
[umask,vmask,pmask]=uvp_mask(rmask);
nc=netcdf(gridfile);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
close(nc);
%
% Get the currents
%
if vlevel==0
  u=umask.*get_hslice(hisfile,gridfile,'ubar',tindex,vlevel,'u');
  v=vmask.*get_hslice(hisfile,gridfile,'vbar',tindex,vlevel,'v');
else
  u=umask.*get_hslice(hisfile,gridfile,'u',tindex,vlevel,'u');
  v=vmask.*get_hslice(hisfile,gridfile,'v',tindex,vlevel,'v');
end
umask=~isnan(u2rho_2d(u));
vmask=~isnan(v2rho_2d(v));
u(isnan(u))=0;
v(isnan(v))=0;
mask=umask.*vmask;

%
% Boundary conditions
%
[u,v]=get_obcvolcons(u,v,pm,pn,mask,[1 1 1 1]);
psi=coef.*psi2rho(get_psi(u,v,pm,pn,mask));
