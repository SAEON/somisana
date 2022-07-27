function [lat,lon,mask,lambda2]=get_okubo(hisfile,gridfile,tindex,vlevel,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the Okubo-Weiss parameter
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
[lat,lon,mask]=read_latlonmask(gridfile,'r');
mask(2:end-1,2:end-1)=mask(1:end-2,1:end-2).*...
                      mask(1:end-2,2:end-1).*...
                      mask(1:end-2,3:end).*...
                      mask(2:end-1,1:end-2).*...
                      mask(2:end-1,2:end-1).*...
                      mask(2:end-1,3:end).*...
                      mask(3:end,1:end-2).*...
                      mask(3:end,2:end-1).*...
                      mask(3:end,3:end);
nc=netcdf(gridfile);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
close(nc);
%
% Get the currents
%
if vlevel==0
  u=get_hslice(hisfile,gridfile,'ubar',tindex,vlevel,'u');
  v=get_hslice(hisfile,gridfile,'vbar',tindex,vlevel,'v');
else
  u=get_hslice(hisfile,gridfile,'u',tindex,vlevel,'u');
  v=get_hslice(hisfile,gridfile,'v',tindex,vlevel,'v');
end
%
% Get vorticity at rho points
%
lambda2=coef.*mask.*okubo_croco(u,v,pm,pn);
