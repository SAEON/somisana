function  create_grid(L,M,grdname,title)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf gridfile
%       L: total number of psi points in x direction  
%       M: total number of psi points in y direction  
%       grdname: name of the grid file
%       title: title in the netcdf file  
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lp=L+1;
Mp=M+1;

nw = netcdf(grdname, 'clobber');
%result = redef(nw);

%
%  Create dimensions
%

nw('xi_u') = L;
nw('eta_u') = Mp;
nw('xi_v') = Lp;
nw('eta_v') = M;
nw('xi_rho') = Lp;
nw('eta_rho') = Mp;
nw('xi_psi') = L;
nw('eta_psi') = M;
nw('one') = 1;
nw('two') = 2;
nw('four') = 4;
nw('bath') = 1;

%
%  Create variables and attributes
%

nw{'xl'} = ncdouble('one');
nw{'xl'}.long_name = ncchar('domain length in the XI-direction');
nw{'xl'}.long_name = 'domain length in the XI-direction';
nw{'xl'}.units = ncchar('meter');
nw{'xl'}.units = 'meter';

nw{'el'} = ncdouble('one');
nw{'el'}.long_name = ncchar('domain length in the ETA-direction');
nw{'el'}.long_name = 'domain length in the ETA-direction';
nw{'el'}.units = ncchar('meter');
nw{'el'}.units = 'meter';

nw{'depthmin'} = ncdouble('one');
nw{'depthmin'}.long_name = ncchar('Shallow bathymetry clipping depth');
nw{'depthmin'}.long_name = 'Shallow bathymetry clipping depth';
nw{'depthmin'}.units = ncchar('meter');
nw{'depthmin'}.units = 'meter';

nw{'depthmax'} = ncdouble('one');
nw{'depthmax'}.long_name = ncchar('Deep bathymetry clipping depth');
nw{'depthmax'}.long_name = 'Deep bathymetry clipping depth';
nw{'depthmax'}.units = ncchar('meter');
nw{'depthmax'}.units = 'meter';

nw{'spherical'} = ncchar('one');
nw{'spherical'}.long_name = ncchar('Grid type logical switch');
nw{'spherical'}.long_name = 'Grid type logical switch';
nw{'spherical'}.option_T = ncchar('spherical');
nw{'spherical'}.option_T = 'spherical';

nw{'angle'} = ncdouble('eta_rho', 'xi_rho');
nw{'angle'}.long_name = ncchar('angle between xi axis and east');
nw{'angle'}.long_name = 'angle between xi axis and east';
nw{'angle'}.units = ncchar('degree');
nw{'angle'}.units = 'degree';

nw{'h'} = ncdouble('eta_rho', 'xi_rho');
nw{'h'}.long_name = ncchar('Final bathymetry at RHO-points');
nw{'h'}.long_name = 'Final bathymetry at RHO-points';
nw{'h'}.units = ncchar('meter');
nw{'h'}.units = 'meter';

nw{'hraw'} = ncdouble('bath', 'eta_rho', 'xi_rho');
nw{'hraw'}.long_name = ncchar('Working bathymetry at RHO-points');
nw{'hraw'}.long_name = 'Working bathymetry at RHO-points';
nw{'hraw'}.units = ncchar('meter');
nw{'hraw'}.units = 'meter';

nw{'alpha'} = ncdouble('eta_rho', 'xi_rho');
nw{'alpha'}.long_name = ncchar('Weights between coarse and fine grids at RHO-points');
nw{'alpha'}.long_name = 'Weights between coarse and fine grids at RHO-points';

nw{'f'} = ncdouble('eta_rho', 'xi_rho');
nw{'f'}.long_name = ncchar('Coriolis parameter at RHO-points');
nw{'f'}.long_name = 'Coriolis parameter at RHO-points';
nw{'f'}.units = ncchar('second-1');
nw{'f'}.units = 'second-1';

nw{'pm'} = ncdouble('eta_rho', 'xi_rho');
nw{'pm'}.long_name = ncchar('curvilinear coordinate metric in XI');
nw{'pm'}.long_name = 'curvilinear coordinate metric in XI';
nw{'pm'}.units = ncchar('meter-1');
nw{'pm'}.units = 'meter-1';

nw{'pn'} = ncdouble('eta_rho', 'xi_rho');
nw{'pn'}.long_name = ncchar('curvilinear coordinate metric in ETA');
nw{'pn'}.long_name = 'curvilinear coordinate metric in ETA';
nw{'pn'}.units = ncchar('meter-1');
nw{'pn'}.units = 'meter-1';

nw{'dndx'} = ncdouble('eta_rho', 'xi_rho');
nw{'dndx'}.long_name = ncchar('xi derivative of inverse metric factor pn');
nw{'dndx'}.long_name = 'xi derivative of inverse metric factor pn';
nw{'dndx'}.units = ncchar('meter');
nw{'dndx'}.units = 'meter';

nw{'dmde'} = ncdouble('eta_rho', 'xi_rho');
nw{'dmde'}.long_name = ncchar('eta derivative of inverse metric factor pm');
nw{'dmde'}.long_name = 'eta derivative of inverse metric factor pm';
nw{'dmde'}.units = ncchar('meter');
nw{'dmde'}.units = 'meter';

nw{'x_rho'} = ncdouble('eta_rho', 'xi_rho');
nw{'x_rho'}.long_name = ncchar('x location of RHO-points');
nw{'x_rho'}.long_name = 'x location of RHO-points';
nw{'x_rho'}.units = ncchar('meter');
nw{'x_rho'}.units = 'meter';

nw{'x_u'} = ncdouble('eta_u', 'xi_u');
nw{'x_u'}.long_name = ncchar('x location of U-points');
nw{'x_u'}.long_name = 'x location of U-points';
nw{'x_u'}.units = ncchar('meter');
nw{'x_u'}.units = 'meter';

nw{'x_v'} = ncdouble('eta_v', 'xi_v');
nw{'x_v'}.long_name = ncchar('x location of V-points');
nw{'x_v'}.long_name = 'x location of V-points';
nw{'x_v'}.units = ncchar('meter');
nw{'x_v'}.units = 'meter';

nw{'x_psi'} = ncdouble('eta_psi', 'xi_psi');
nw{'x_psi'}.long_name = ncchar('x location of PSI-points');
nw{'x_psi'}.long_name = 'x location of PSI-points';
nw{'x_psi'}.units = ncchar('meter');
nw{'x_psi'}.units = 'meter';

nw{'y_rho'} = ncdouble('eta_rho', 'xi_rho');
nw{'y_rho'}.long_name = ncchar('y location of RHO-points');
nw{'y_rho'}.long_name = 'y location of RHO-points';
nw{'y_rho'}.units = ncchar('meter');
nw{'y_rho'}.units = 'meter';

nw{'y_u'} = ncdouble('eta_u', 'xi_u');
nw{'y_u'}.long_name = ncchar('y location of U-points');
nw{'y_u'}.long_name = 'y location of U-points';
nw{'y_u'}.units = ncchar('meter');
nw{'y_u'}.units = 'meter';

nw{'y_v'} = ncdouble('eta_v', 'xi_v');
nw{'y_v'}.long_name = ncchar('y location of V-points');
nw{'y_v'}.long_name = 'y location of V-points';
nw{'y_v'}.units = ncchar('meter');
nw{'y_v'}.units = 'meter';

nw{'y_psi'} = ncdouble('eta_psi', 'xi_psi');
nw{'y_psi'}.long_name = ncchar('y location of PSI-points');
nw{'y_psi'}.long_name = 'y location of PSI-points';
nw{'y_psi'}.units = ncchar('meter');
nw{'y_psi'}.units = 'meter';

nw{'lon_rho'} = ncdouble('eta_rho', 'xi_rho');
nw{'lon_rho'}.long_name = ncchar('longitude of RHO-points');
nw{'lon_rho'}.long_name = 'longitude of RHO-points';
nw{'lon_rho'}.units = ncchar('degree_east');
nw{'lon_rho'}.units = 'degree_east';

nw{'lon_u'} = ncdouble('eta_u', 'xi_u');
nw{'lon_u'}.long_name = ncchar('longitude of U-points');
nw{'lon_u'}.long_name = 'longitude of U-points';
nw{'lon_u'}.units = ncchar('degree_east');
nw{'lon_u'}.units = 'degree_east';

nw{'lon_v'} = ncdouble('eta_v', 'xi_v');
nw{'lon_v'}.long_name = ncchar('longitude of V-points');
nw{'lon_v'}.long_name = 'longitude of V-points';
nw{'lon_v'}.units = ncchar('degree_east');
nw{'lon_v'}.units = 'degree_east';

nw{'lon_psi'} = ncdouble('eta_psi', 'xi_psi');
nw{'lon_psi'}.long_name = ncchar('longitude of PSI-points');
nw{'lon_psi'}.long_name = 'longitude of PSI-points';
nw{'lon_psi'}.units = ncchar('degree_east');
nw{'lon_psi'}.units = 'degree_east';

nw{'lat_rho'} = ncdouble('eta_rho', 'xi_rho');
nw{'lat_rho'}.long_name = ncchar('latitude of RHO-points');
nw{'lat_rho'}.long_name = 'latitude of RHO-points';
nw{'lat_rho'}.units = ncchar('degree_north');
nw{'lat_rho'}.units = 'degree_north';

nw{'lat_u'} = ncdouble('eta_u', 'xi_u');
nw{'lat_u'}.long_name = ncchar('latitude of U-points');
nw{'lat_u'}.long_name = 'latitude of U-points';
nw{'lat_u'}.units = ncchar('degree_north');
nw{'lat_u'}.units = 'degree_north';

nw{'lat_v'} = ncdouble('eta_v', 'xi_v');
nw{'lat_v'}.long_name = ncchar('latitude of V-points');
nw{'lat_v'}.long_name = 'latitude of V-points';
nw{'lat_v'}.units = ncchar('degree_north');
nw{'lat_v'}.units = 'degree_north';

nw{'lat_psi'} = ncdouble('eta_psi', 'xi_psi');
nw{'lat_psi'}.long_name = ncchar('latitude of PSI-points');
nw{'lat_psi'}.long_name = 'latitude of PSI-points';
nw{'lat_psi'}.units = ncchar('degree_north');
nw{'lat_psi'}.units = 'degree_north';

nw{'mask_rho'} = ncdouble('eta_rho', 'xi_rho');
nw{'mask_rho'}.long_name = ncchar('mask on RHO-points');
nw{'mask_rho'}.long_name = 'mask on RHO-points';
nw{'mask_rho'}.option_0 = ncchar('land');
nw{'mask_rho'}.option_0 = 'land';
nw{'mask_rho'}.option_1 = ncchar('water');
nw{'mask_rho'}.option_1 = 'water';

nw{'mask_u'} = ncdouble('eta_u', 'xi_u');
nw{'mask_u'}.long_name = ncchar('mask on U-points');
nw{'mask_u'}.long_name = 'mask on U-points';
nw{'mask_u'}.option_0 = ncchar('land');
nw{'mask_u'}.option_0 = 'land';
nw{'mask_u'}.option_1 = ncchar('water');
nw{'mask_u'}.option_1 = 'water';

nw{'mask_v'} = ncdouble('eta_v', 'xi_v');
nw{'mask_v'}.long_name = ncchar('mask on V-points');
nw{'mask_v'}.long_name = 'mask on V-points';
nw{'mask_v'}.option_0 = ncchar('land');
nw{'mask_v'}.option_0 = 'land';
nw{'mask_v'}.option_1 = ncchar('water');
nw{'mask_v'}.option_1 = 'water';

nw{'mask_psi'} = ncdouble('eta_psi', 'xi_psi');
nw{'mask_psi'}.long_name = ncchar('mask on PSI-points');
nw{'mask_psi'}.long_name = 'mask on PSI-points';
nw{'mask_psi'}.option_0 = ncchar('land');
nw{'mask_psi'}.option_0 = 'land';
nw{'mask_psi'}.option_1 = ncchar('water');
nw{'mask_psi'}.option_1 = 'water';

%result = endef(nw);

%
% Create global attributes
%

nw.title = ncchar(title);
nw.title = title;
nw.date = ncchar(date);
nw.date = date;
nw.type = ncchar('CROCO grid file');
nw.type = 'CROCO grid file';

close(nw);
