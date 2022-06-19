function [lat,lon,mask,ke]=get_ke(hisfile,gridfile,tindex,vlevel,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the kinetic Energy
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
[lat,lon,mask]=read_latlonmask(gridfile,'r');
if vlevel==0
  u=u2rho_2d(get_hslice(hisfile,gridfile,'ubar',...
             tindex,vlevel,'u'));
  v=v2rho_2d(get_hslice(hisfile,gridfile,'vbar',...
             tindex,vlevel,'v'));
else
  u=u2rho_2d(get_hslice(hisfile,gridfile,'u',...
             tindex,vlevel,'u'));
  v=v2rho_2d(get_hslice(hisfile,gridfile,'v',...
             tindex,vlevel,'v'));
end
ke=coef.*mask.*0.5.*(u.^2+v.^2);
