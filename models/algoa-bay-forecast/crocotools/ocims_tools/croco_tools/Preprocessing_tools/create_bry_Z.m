function create_bry_Z(zbryname,grdname,title,obc,...
                      Z,time,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This function create the header of a Netcdf boundary
%   file (on a z grid).
%
%   Input:
%
%   zbryname     Netcdf climatology file name (character string).
%   grdname      Netcdf grid file name (character string).
%   obc          open boundaries flag (1=open , [S E N W]).
%   Z            Depth of vertical levels.(Vector)
%   time         time.(vector) 
%   cycle        Length (days) for cycling the climatology.(Real)
%   clobber      Switch to allow or not writing over an existing 
%                file.(character string)
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
disp([' Creating the file : ',zbryname])
disp(' ')
%
%  Read the grid file and check the topography
%
nc = netcdf(grdname, 'nowrite');
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
close(nc);
L=Lp-1;
M=Mp-1;
%
%  Create the boundary file
%
type = 'BOUNDARY Z (or OA) file' ; 
history = 'CROCO' ;
nc = netcdf(zbryname,clobber);
%%result = redef(nc);
%
%  Create dimensions
%
nc('xi_u') = L;
nc('xi_rho') = Lp;
nc('eta_v') = M;
nc('eta_rho') = Mp;
nc('Z') = length(Z);
nc('bry_time') = length(time);
nc('one') = 1;
%
%  Create variables and attributes
%
nc{'Z'} = ncdouble('Z') ;
nc{'Z'}.long_name = ncchar('Depth');
nc{'Z'}.long_name = 'Depth';
nc{'Z'}.units = ncchar('m');
nc{'Z'}.units = 'm';
%
nc{'bry_time'} = ncdouble('bry_time') ;
nc{'bry_time'}.long_name = ncchar('time for temperature climatology');
nc{'bry_time'}.long_name = 'time for temperature climatology';
nc{'bry_time'}.units = ncchar('day');
nc{'bry_time'}.units = 'day';
nc{'bry_time'}.cycle_length = cycle;%
%
if obc(1)==1
%
%   Southern boundary
%
  nc{'temp_south'} = ncdouble('bry_time','Z','xi_rho') ;
  nc{'temp_south'}.long_name = ncchar('southern boundary potential temperature');
  nc{'temp_south'}.long_name = 'southern boundary potential temperature';
  nc{'temp_south'}.units = ncchar('Celsius');
  nc{'temp_south'}.units = 'Celsius';
%
  nc{'salt_south'} = ncdouble('bry_time','Z','xi_rho') ;
  nc{'salt_south'}.long_name = ncchar('southern boundary salinity');
  nc{'salt_south'}.long_name = 'southern boundary salinity';
  nc{'salt_south'}.units = ncchar('PSU');
  nc{'salt_south'}.units = 'PSU';
%
end
%
if obc(2)==1
%
%   Eastern boundary
%
  nc{'temp_east'} = ncdouble('bry_time','Z','eta_rho') ;
  nc{'temp_east'}.long_name = ncchar('eastern boundary potential temperature');
  nc{'temp_east'}.long_name = 'eastern boundary potential temperature';
  nc{'temp_east'}.units = ncchar('Celsius');
  nc{'temp_east'}.units = 'Celsius';
%
  nc{'salt_east'} = ncdouble('bry_time','Z','eta_rho') ;
  nc{'salt_east'}.long_name = ncchar('eastern boundary salinity');
  nc{'salt_east'}.long_name = 'eastern boundary salinity';
  nc{'salt_east'}.units = ncchar('PSU');
  nc{'salt_east'}.units = 'PSU';
%
end
%
if obc(3)==1
%
%   Northern boundary
%
  nc{'temp_north'} = ncdouble('bry_time','Z','xi_rho') ;
  nc{'temp_north'}.long_name = ncchar('northern boundary potential temperature');
  nc{'temp_north'}.long_name = 'northern boundary potential temperature';
  nc{'temp_north'}.units = ncchar('Celsius');
  nc{'temp_north'}.units = 'Celsius';
%
  nc{'salt_north'} = ncdouble('bry_time','Z','xi_rho') ;
  nc{'salt_north'}.long_name = ncchar('northern boundary salinity');
  nc{'salt_north'}.long_name = 'northern boundary salinity';
  nc{'salt_north'}.units = ncchar('PSU');
  nc{'salt_north'}.units = 'PSU';
%
end
%
if obc(4)==1
%
%   Western boundary
%
  nc{'temp_west'} = ncdouble('bry_time','Z','eta_rho') ;
  nc{'temp_west'}.long_name = ncchar('western boundary potential temperature');
  nc{'temp_west'}.long_name = 'western boundary potential temperature';
  nc{'temp_west'}.units = ncchar('Celsius');
  nc{'temp_west'}.units = 'Celsius';
%
  nc{'salt_west'} = ncdouble('bry_time','Z','eta_rho') ;
  nc{'salt_west'}.long_name = ncchar('western boundary salinity');
  nc{'salt_west'}.long_name = 'western boundary salinity';
  nc{'salt_west'}.units = ncchar('PSU');
  nc{'salt_west'}.units = 'PSU';
%
end
%
%
% Create global attributes
%
nc.title = ncchar(title);
nc.title = title;
nc.date = ncchar(date);
nc.date = date;
nc.clim_file = ncchar(zbryname);
nc.clim_file = zbryname;
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
nc{'bry_time'}(:) =  time; 
if obc(1)==1
  nc{'temp_south'}(:) =  0; 
  nc{'salt_south'}(:) =  0;
end 
if obc(2)==1 
  nc{'temp_east'}(:) =  0; 
  nc{'salt_east'}(:) =  0;
end 
if obc(3)==1 
  nc{'temp_north'}(:) =  0; 
  nc{'salt_north'}(:) =  0;
end 
if obc(4)==1 
  nc{'temp_west'}(:) =  0; 
  nc{'salt_west'}(:) =  0;
end 
close(nc)
return


