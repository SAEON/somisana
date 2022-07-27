%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add radswbio/swradbio (solar short-wave radiation without diurnal cycle) 
%  in frc/bulk climatological atmopheric forcing files. 
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
clear all
close all

disp(['Add swradbio: daily averaged solar short wave radiation     '])
disp(['Creating variables and attributes for forcing and bulk ' ...
      'files'])

crocotools_param
%
% Open the frc file
% 
if (makefrc)
disp(['Add swradbio: daily averaged solar short wave radiation'])
disp(['No change needed in this climato case                  '])
disp(['Creating variables and attributes for frc files        '])
end
nc_add_swradbio_frc(frcname,'r');
%
nw=netcdf(frcname,'write');
swrad1=nw{'swrad'}(:);
nw{'swradbio'}(:) = swrad1;
close(nw)
%
% Open the bulk time
%
if (makeblk)
disp(['Add radswbio: daily averaged solar short wave radiation'])
disp(['No change needed in this climato case                  '])
disp(['Creating variables and attributes for bulk files       '])
end
nc_add_swradbio_blk(blkname);
%
nw=netcdf(blkname,'write');
radsw1=nw{'radsw'}(:);
nw{'radswbio'}(:) = radsw1;
close(nw)
%
