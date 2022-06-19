function nc_add_swradbio_frc(fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add swradbio (solar short-wave radiation without diurnal cycle) 
%  in frc climatological atmopheric forcing file. 
%  Variable needed by biogeochemical model PISCES
%
%
%  Further Information:
%  http://www.crocoagrif.org
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
%
%  June 2014: G.Cambon (IRD/LEGOS)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nw=netcdf(fname,'write');
redef(nw)
%
% Add variables and attributes
%
nw{'swradbio'}= ncdouble('srf_time', 'eta_rho', 'xi_rho');
nw{'swradbio'}.long_name = ncchar('solar shortwave radiation - no night');
nw{'swradbio'}.long_name = 'solar shortwave radiation - no night';
nw{'swradbio'}.units = ncchar('Watts meter-2');
nw{'swradbio'}.units = 'Watts meter-2';
nw{'swradbio'}.positive = ncchar('downward flux, heating');
nw{'swradbio'}.positive = 'downward flux, heating';
nw{'swradbio'}.negative = ncchar('upward flux, cooling');
nw{'swradbio'}.negative = 'upward flux, cooling';
result = endef(nw);
close(nw)
