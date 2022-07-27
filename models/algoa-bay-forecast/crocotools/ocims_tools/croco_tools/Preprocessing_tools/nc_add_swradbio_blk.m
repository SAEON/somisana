function nc_add_swradbio_blk(fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add radswbio (solar short-wave radiation without diurnal cycle) 
%  field in bulk climatological atmopheric forcing file. 
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
nw{'radswbio'}= ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'radswbio'}.long_name = ncchar('solar shortwave radiation - no night');
nw{'radswbio'}.long_name = 'solar shortwave radiation - no night';
nw{'radswbio'}.units = ncchar('Watts meter-2');
nw{'radswbio'}.units = 'Watts meter-2';
nw{'radswbio'}.positive = ncchar('downward flux, heating');
nw{'radswbio'}.positive = 'downward flux, heating';
nw{'radswbio'}.negative = ncchar('upward flux, cooling');
nw{'radswbio'}.negative = 'upward flux, cooling';
result = endef(nw);
close(nw)
