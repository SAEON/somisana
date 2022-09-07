function  create_nesteddust(dustname,parentname,grdname,title,dustt,dustc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf dust forcing file (for PISCES)
%       dustname: name of the dust file
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%  Update : Gildas Cambon 13 Oct 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(grdname);
L=length(nc('xi_psi'));
M=length(nc('eta_psi'));
close(nc);
Lp=L+1;
Mp=M+1;
nw = netcdf(dustname, 'clobber');
redef(nw);
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
nw('dust_time') = length(dustt);
%
%  Create variables and attributes
%
nw{'dust_time'} = ncdouble('dust_time');
nw{'dust_time'}.long_name = ncchar('dust time');
nw{'dust_time'}.long_name = 'dust time';
nw{'dust_time'}.units = ncchar('days');
nw{'dust_time'}.units = 'days';
nw{'dust_time'}.cycle_length = dustc;
nw{'dust_time'}.field = ncchar('time, scalar, series');
nw{'dust_time'}.field = 'time, scalar, series';

nw{'dust'} = ncdouble('dust_time', 'eta_rho', 'xi_rho');
nw{'dust'}.long_name = ncchar('Fe Dust Deposition');
nw{'dust'}.long_name = 'Fe Dust Deposition';
nw{'dust'}.units = ncchar('nmol Fe m-3');
nw{'dust'}.units = 'nmol Fe m-3';
nw{'dust'}.field = ncchar('Fe Dust Deposition, scalar, series');
nw{'dust'}.field = 'Fe Dust Deposition, scalar, series';

endef(nw);

%
% Create global attributes
%

nw.title = ncchar(title);
nw.title = title;
nw.date = ncchar(date);
nw.date = date;
nw.grd_file = ncchar(grdname);
nw.grd_file = grdname;
nw.parent_file = ncchar(parentname);
nw.parent_file = parentname;

%
% Write time variables
%

nw{'dust_time'}(:) = dustt;


close(nw);
return
