function  create_bulk(blkname,parentname,grdname,title,bulkt,bulkc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf heat flux bulk bulk file
%       blkname: name of the bulk file
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
%  Copyright (c) 2005 by Patrick Marchesiello
%  e-mail:Patrick.Marchesiello@ird.fr  
%
%  Updated 14-Oct-2005 add sustr,svstr,uwnd,vwnd vars
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(grdname);
L=length(nc('xi_psi'));
M=length(nc('eta_psi'));
result=close(nc);
Lp=L+1;
Mp=M+1;

nw = netcdf(blkname, 'clobber');
result = redef(nw);

%
%  Create dimensions
%
nw('xi_rho') = Lp;
nw('eta_rho') = Mp;
nw('xi_psi') = L;
nw('eta_psi') = M;
nw('xi_u') = L;
nw('eta_u') = Mp;
nw('xi_v') = Lp;
nw('eta_v') = M;
nw('bulk_time') = length(bulkt);
%
%  Create variables and attributes
%
nw{'bulk_time'}              = ncdouble('bulk_time');
nw{'bulk_time'}.long_name    = ncchar('bulk formulation execution time');
nw{'bulk_time'}.long_name    = 'bulk formulation execution time';
nw{'bulk_time'}.units        = ncchar('days');
nw{'bulk_time'}.units        = 'days';
nw{'bulk_time'}.cycle_length = bulkc;

nw{'tair'}             = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'tair'}.long_name   = ncchar('surface air temperature');
nw{'tair'}.long_name   = 'surface air temperature';
nw{'tair'}.units       = ncchar('Celsius');
nw{'tair'}.units       = 'Celsius';

nw{'rhum'}             = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'rhum'}.long_name   = ncchar('relative humidity');
nw{'rhum'}.long_name   = 'relative humidity';
nw{'rhum'}.units       = ncchar('fraction');
nw{'rhum'}.units       = 'fraction';

nw{'prate'}            = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'prate'}.long_name  = ncchar('precipitation rate');
nw{'prate'}.long_name  = 'precipitation rate';
nw{'prate'}.units      = ncchar('cm day-1');
nw{'prate'}.units      = 'cm day-1';

nw{'wspd'}             = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'wspd'}.long_name   = ncchar('wind speed 10m');
nw{'wspd'}.long_name   = 'wind speed 10m';
nw{'wspd'}.units       = ncchar('m s-1');
nw{'wspd'}.units       = 'm s-1';

nw{'radlw'}            = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'radlw'}.long_name  = ncchar('net outgoing longwave radiation');
nw{'radlw'}.long_name  = 'net outgoing longwave radiation';
nw{'radlw'}.units      = ncchar('Watts meter-2');
nw{'radlw'}.units      = 'Watts meter-2';
nw{'radlw'}.positive   = ncchar('upward flux, cooling water');
nw{'radlw'}.positive   = 'upward flux, cooling water';

nw{'radlw_in'}            = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'radlw_in'}.long_name  = ncchar('downward longwave radiation');
nw{'radlw_in'}.long_name  = 'downward longwave radiation';
nw{'radlw_in'}.units      = ncchar('Watts meter-2');
nw{'radlw_in'}.units      = 'Watts meter-2';
nw{'radlw_in'}.positive   = ncchar('downward flux, cooling water');
nw{'radlw_in'}.positive   = 'downward flux, cooling water';

nw{'radsw'}            = ncdouble('bulk_time', 'eta_rho', 'xi_rho');
nw{'radsw'}.long_name  = ncchar('solar shortwave radiation');
nw{'radsw'}.long_name  = 'shortwave radiation';
nw{'radsw'}.units      = ncchar('Watts meter-2');
nw{'radsw'}.units      = 'Watts meter-2';
nw{'radsw'}.positive   = ncchar('downward flux, heating water');
nw{'radsw'}.positive   = 'downward flux, heating water';

nw{'sustr'} = ncdouble('bulk_time', 'eta_u', 'xi_u');
nw{'sustr'}.long_name = ncchar('surface u-momentum stress');
nw{'sustr'}.long_name = 'surface u-momentum stress';
nw{'sustr'}.units = ncchar('Newton meter-2');
nw{'sustr'}.units = 'Newton meter-2';

nw{'svstr'} = ncdouble('bulk_time', 'eta_v', 'xi_v');
nw{'svstr'}.long_name = ncchar('surface v-momentum stress');
nw{'svstr'}.long_name = 'surface v-momentum stress';
nw{'svstr'}.units = ncchar('Newton meter-2');
nw{'svstr'}.units = 'Newton meter-2';

nw{'uwnd'} = ncdouble('bulk_time', 'eta_u', 'xi_u');
nw{'uwnd'}.long_name = ncchar('10m u-wind component');
nw{'uwnd'}.long_name = 'u-wind';
nw{'uwnd'}.units = ncchar('meter second-1');
nw{'uwnd'}.units = 'm/s';

nw{'vwnd'} = ncdouble('bulk_time', 'eta_v', 'xi_v');
nw{'vwnd'}.long_name = ncchar('10m v-wind component');
nw{'vwnd'}.long_name = 'v-wind';
nw{'vwnd'}.units = ncchar('meter second-1');
nw{'vwnd'}.units = 'm/s';

result = endef(nw);

%
% Create global attributes
%

nw.title = ncchar(title);
nw.title = title;
nw.date = ncchar(date);
nw.date = date;
nw.grd_file = ncchar(grdname);
nw.grd_file = grdname;
nw.type = ncchar('CROCO bulk file');
nw.type = 'CROCO bulk file';
nw.parent_file = ncchar(parentname);
nw.parent_file = parentname;

%
% Write time variables
%

nw{'bulk_time'}(:) = bulkt;

close(nw);
