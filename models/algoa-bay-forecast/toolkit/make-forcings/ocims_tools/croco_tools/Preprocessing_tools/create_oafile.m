function create_oafile(oaname,grdname,title,Z,...
                       time,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function nc=create_oafile(oaname,grdname,title,Z,...
%                       time,cycle,clobber);
%
%   This function create the header of a Netcdf OA
%   file. ie an intermediate file on a Z-grid.
%
%   Input: 
% 
%   oaname       Netcdf OA file name (character string).
%   grdname      Netcdf grid file name (character string).
%   Z            Vertical levels.(Vector)  
%   time         OA time.(Vector) 
%   clobber      Switch to allow or not writing over an existing
%                file.(character string) 
%
%   Output
%
%   nc       Output netcdf object.
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
disp(' ')
disp([' Creating the file : ',oaname])
disp(' ')
%
%  Read the grid file
%
nc = netcdf(grdname, 'nowrite');
lonr=nc{'lon_rho'}(:);
latr=nc{'lat_rho'}(:);
lonu=nc{'lon_u'}(:);
latu=nc{'lat_u'}(:);
lonv=nc{'lon_v'}(:);
latv=nc{'lat_v'}(:);
close(nc);
[Mp,Lp]=size(lonr);
L=Lp-1;
M=Mp-1;
%
%  Create the climatology file
%
type = 'OA file' ; 
history = 'CROCO' ;
nc = netcdf(oaname,clobber);
%result = redef(nc);
%
%  Create dimensions
%
nc('xi_rho') = Lp;
nc('eta_rho') = Mp;
nc('xi_u') = L;
nc('eta_v') = M;
nc('Z') = length(Z);
nc('tracer') = 2;
nc('tclm_time') = length(time);
nc('sclm_time') = length(time);
nc('uclm_time') = length(time);
nc('vclm_time') = length(time);
nc('v2d_time')  = length(time);
nc('v3d_time')  = length(time);
nc('ssh_time')  = length(time);
nc('zeta_time') = length(time);
nc('one') = 1;
%
%  Create variables
%
nc{'lon_rho'} = ncdouble('eta_rho','xi_rho') ;
nc{'lat_rho'} = ncdouble('eta_rho','xi_rho') ;
nc{'lon_u'} = ncdouble('eta_rho','xi_u') ;
nc{'lat_u'} = ncdouble('eta_rho','xi_u') ;
nc{'lon_v'} = ncdouble('eta_v','xi_rho') ;
nc{'lat_v'} = ncdouble('eta_v','xi_rho') ;
nc{'Z'} = ncdouble('Z') ;
nc{'tclm_time'} = ncdouble('tclm_time') ;
nc{'sclm_time'} = ncdouble('sclm_time') ;
nc{'uclm_time'} = ncdouble('uclm_time') ;
nc{'vclm_time'} = ncdouble('vclm_time') ;
nc{'v2d_time'} = ncdouble('v2d_time') ;
nc{'v3d_time'} = ncdouble('v3d_time') ;
nc{'ssh_time'} = ncdouble('ssh_time') ;
nc{'zeta_time'} = ncdouble('zeta_time') ;
nc{'temp'} = ncdouble('tclm_time','Z','eta_rho','xi_rho') ;
nc{'salt'} = ncdouble('sclm_time','Z','eta_rho','xi_rho') ;
nc{'u'} = ncdouble('uclm_time','Z','eta_rho','xi_u') ;
nc{'v'} = ncdouble('vclm_time','Z','eta_v','xi_rho') ;
nc{'ubar'} = ncdouble('uclm_time','eta_rho','xi_u') ;
nc{'vbar'} = ncdouble('vclm_time','eta_v','xi_rho') ;
nc{'SSH'} = ncdouble('ssh_time','eta_rho','xi_rho') ;
nc{'zeta'} = ncdouble('zeta_time','eta_rho','xi_rho') ;
%
%  Create attributes
%
nc{'lon_rho'}.long_name = ncchar('longitude of RHO-points');
nc{'lon_rho'}.long_name = 'longitude of RHO-points';
nc{'lon_rho'}.units = ncchar('degree_east');
nc{'lon_rho'}.units = 'degree_east';
%
nc{'lat_rho'}.latg_name = ncchar('latitude of RHO-points');
nc{'lat_rho'}.latg_name = 'latitude of RHO-points';
nc{'lat_rho'}.units = ncchar('degree_north');
nc{'lat_rho'}.units = 'degree_north';
%
nc{'lon_u'}.long_name = ncchar('longitude of U-points');
nc{'lon_u'}.long_name = 'longitude of U-points';
nc{'lon_u'}.units = ncchar('degree_east');
nc{'lon_u'}.units = 'degree_east';
%
nc{'lat_u'}.latg_name = ncchar('latitude of U-points');
nc{'lat_u'}.latg_name = 'latitude of U-points';
nc{'lat_u'}.units = ncchar('degree_north');
nc{'lat_u'}.units = 'degree_north';
%
nc{'lon_v'}.long_name = ncchar('longitude of V-points');
nc{'lon_v'}.long_name = 'longitude of V-points';
nc{'lon_v'}.units = ncchar('degree_east');
nc{'lon_v'}.units = 'degree_east';
%
nc{'lat_v'}.latg_name = ncchar('latitude of V-points');
nc{'lat_v'}.latg_name = 'latitude of V-points';
nc{'lat_v'}.units = ncchar('degree_north');
nc{'lat_v'}.units = 'degree_north';
%
nc{'Z'}.long_name = ncchar('Depth');
nc{'Z'}.long_name = 'Depth';
nc{'Z'}.units = ncchar('m');
nc{'Z'}.units = 'm';
%
nc{'tclm_time'}.long_name = ncchar('time for temperature climatology');
nc{'tclm_time'}.long_name = 'time for temperature climatology';
nc{'tclm_time'}.units = ncchar('day');
nc{'tclm_time'}.units = 'day';
nc{'tclm_time'}.cycle_length = cycle;
%
nc{'sclm_time'}.long_name = ncchar('time for salinity climatology');
nc{'sclm_time'}.long_name = 'time for salinity climatology';
nc{'sclm_time'}.units = ncchar('day');
nc{'sclm_time'}.units = 'day';
nc{'sclm_time'}.cycle_length = cycle;
%
nc{'uclm_time'}.long_name = ncchar('time for u climatology');
nc{'uclm_time'}.long_name = 'time for u climatology';
nc{'uclm_time'}.units = ncchar('day');
nc{'uclm_time'}.units = 'day';
nc{'uclm_time'}.cycle_length = cycle;
%
nc{'vclm_time'}.long_name = ncchar('time for v climatology');
nc{'vclm_time'}.long_name = 'time for v climatology';
nc{'vclm_time'}.units = ncchar('day');
nc{'vclm_time'}.units = 'day';
nc{'vclm_time'}.cycle_length = cycle;
%
nc{'v2d_time'}.long_name = ncchar('time for 2D velocity climatology');
nc{'v2d_time'}.long_name = 'time for 2D velocity climatology';
nc{'v2d_time'}.units = ncchar('day');
nc{'v2d_time'}.units = 'day';
nc{'v2d_time'}.cycle_length = cycle;
%
nc{'v3d_time'}.long_name = ncchar('time for 3D velocity climatology');
nc{'v3d_time'}.long_name = 'time for 3D velocity climatology';
nc{'v3d_time'}.units = ncchar('day');
nc{'v3d_time'}.units = 'day';
nc{'v3d_time'}.cycle_length = cycle;
%
nc{'ssh_time'}.long_name = ncchar('time for sea surface height');
nc{'ssh_time'}.long_name = 'time for sea surface height';
nc{'ssh_time'}.units = ncchar('day');
nc{'ssh_time'}.units = 'day';
nc{'ssh_time'}.cycle_length = cycle;
%
nc{'zeta_time'}.long_name = ncchar('time for zeta climatology');
nc{'zeta_time'}.long_name = 'time for zeta climatology';
nc{'zeta_time'}.units = ncchar('day');
nc{'zeta_time'}.units = 'day';
nc{'zeta_time'}.cycle_length = cycle;
%
nc{'temp'}.long_name = ncchar('potential temperature');
nc{'temp'}.long_name = 'potential temperature';
nc{'temp'}.units = ncchar('Celsius');
nc{'temp'}.units = 'Celsius';
%
nc{'salt'}.long_name = ncchar('salinity');
nc{'salt'}.long_name = 'salinity';
nc{'salt'}.units = ncchar('PSU');
nc{'salt'}.units = 'PSU';
%
nc{'u'}.long_name = ncchar('u-momentum component');
nc{'u'}.long_name = 'u-momentum component';
nc{'u'}.units = ncchar('meter second-1');
nc{'u'}.units = 'meter second-1';
%
nc{'v'}.long_name = ncchar('v-momentum component');
nc{'v'}.long_name = 'v-momentum component';
nc{'v'}.units = ncchar('meter second-1');
nc{'v'}.units = 'meter second-1';
%
nc{'ubar'}.long_name = ncchar('vertically integrated u-momentum component');
nc{'ubar'}.long_name = 'vertically integrated u-momentum component';
nc{'ubar'}.units = ncchar('meter second-1');
nc{'ubar'}.units = 'meter second-1';
%
nc{'vbar'}.long_name = ncchar('vertically integrated v-momentum component');
nc{'vbar'}.long_name = 'vertically integrated v-momentum component';
nc{'vbar'}.units = ncchar('meter second-1');
nc{'vbar'}.units = 'meter second-1';
%
nc{'SSH'}.long_name = ncchar('sea surface height');
nc{'SSH'}.long_name = 'sea surface height';
nc{'SSH'}.units = ncchar('meter');
nc{'SSH'}.units = 'meter';
%
nc{'zeta'}.long_name = ncchar('sea surface height');
nc{'zeta'}.long_name = 'sea surface height';
nc{'zeta'}.units = ncchar('meter');
nc{'zeta'}.units = 'meter';
%
% Create global attributes
%
nc.title = ncchar(title);
nc.title = title;
nc.date = ncchar(date);
nc.date = date;
nc.grd_file = ncchar(grdname);
nc.grd_file = grdname;
nc.type = ncchar(type);
nc.type = type;
nc.history = ncchar(history);
nc.history = history;
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
nc{'Z'}(:) =  Z; 
nc{'lon_rho'}(:) =  lonr; 
nc{'lat_rho'}(:) =  latr; 
nc{'lon_u'}(:) =  lonu; 
nc{'lat_u'}(:) =  latu; 
nc{'lon_v'}(:) =  lonv; 
nc{'lat_v'}(:) =  latv; 
nc{'tclm_time'}(:) = time; 
nc{'sclm_time'}(:) = time; 
nc{'uclm_time'}(:) = time; 
nc{'vclm_time'}(:) = time; 
nc{'v2d_time'}(:) =   time; 
nc{'v3d_time'}(:) =   time; 
nc{'ssh_time'}(:) =   time;
nc{'zeta_time'}(:) = time;
nc{'u'}(:) =  0; 
nc{'v'}(:) =  0;
nc{'ubar'}(:) =  0; 
nc{'vbar'}(:) =  0;
nc{'SSH'}(:) =  0; 
nc{'zeta'}(:) =  0; 
nc{'temp'}(:) =  0; 
nc{'salt'}(:) =  0; 
close(nc)
return


