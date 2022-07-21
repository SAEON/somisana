function create_bryfile(brywkbname,grdname,title,wkb_obc,...
                        time,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function create_bryfile(brywkbname,grdname,title,wkb_obc...
%                          time,cycle,clobber);
%
%   This function create the header of a Netcdf climatology 
%   file.
%
%   Input:
%
%   brywkbname   Netcdf climatology file name (character string).
%   grdname      Netcdf grid file name (character string).
%   wk_bobc      wkb open boundaries flag (1=open , [S E N W]).
%   time         time.(vector)
%   cycle        Length (days) for cycling the climatology.(Real)
%   clobber      Switch to allow or not writing over an existing
%                file.(character string)
% 
%  Further Information:  
%  http://www.brest.ird.fr/Roms_tools/
%  
%  This file is part of ROMSTOOLS
%
%  ROMSTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  ROMSTOOLS is distributed in the hope that it will be useful, but
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
disp([' Creating the file : ',brywkbname])
disp(' ')
%
%  Read the grid file
%
nc = netcdf(grdname, 'nowrite');
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
status=close(nc);
L=Lp-1;
M=Mp-1;
%
%  Create the boundary file
%
type = 'WKB BOUNDARY file' ; 
history = 'ROMS' ;
nc = netcdf(brywkbname,clobber);
result = redef(nc);
%
%  Create dimensions
%
nc('xi_u') = L;
nc('xi_v') = Lp;
nc('xi_rho') = Lp;
nc('eta_u') = Mp;
nc('eta_v') = M;
nc('eta_rho') = Mp;
nc('brywkb_time') = length(time);
nc('one') = 1;
%
%  Create variables and attributes
%
nc{'tstart'} = ncdouble('one') ;
nc{'tstart'}.long_name = ncchar('start processing day');
nc{'tstart'}.long_name = 'start processing day';
nc{'tstart'}.units = ncchar('day');
nc{'tstart'}.units = 'day';
%
nc{'tend'} = ncdouble('one') ;
nc{'tend'}.long_name = ncchar('end processing day');
nc{'tend'}.long_name = 'end processing day';
nc{'tend'}.units = ncchar('day');
nc{'tend'}.units = 'day';
%
%
nc{'brywkb_time'} = ncdouble('brywkb_time') ;
nc{'brywkb_time'}.long_name = ncchar('time for boundary climatology');
nc{'brywkb_time'}.long_name = 'time for boundary climatology';
nc{'brywkb_time'}.units = ncchar('day');
nc{'brywkb_time'}.units = 'day';
nc{'brywkb_time'}.calendar = ncchar('360.0 days in every year');
nc{'brywkb_time'}.calendar = '360.0 days in every year';
nc{'brywkb_time'}.cycle_length = cycle;
%
if wkb_obc(1)==1
%
%   Southern boundary
%
  nc{'wac_south'} = ncdouble('brywkb_time','xi_rho') ;
  nc{'wac_south'}.long_name = ncchar('southern boundary wave action density');
  nc{'wac_south'}.long_name = 'southern boundary wave action density';
  nc{'wac_south'}.units = ncchar('meter^3 second^-1');
  nc{'wac_south'}.units = 'meter^3 second^-1';
  nc{'wac_south'}.coordinates = ncchar('lon_rho brywkb_time');
  nc{'wac_south'}.coordinates = 'lon_rho brywkb_time';
%
  nc{'wkx_south'} = ncdouble('brywkb_time','xi_rho') ;
  nc{'wkx_south'}.long_name = ncchar('southern boundary xi-dir wavenumber vector');
  nc{'wkx_south'}.long_name = 'southern boundary xi-dir wavenumber vector';
  nc{'wkx_south'}.units = ncchar('radian/meter');
  nc{'wkx_south'}.units = 'radian/meter';
  nc{'wkx_south'}.coordinates = ncchar('lon_rho brywkb_time');
  nc{'wkx_south'}.coordinates = 'lon_rho brywkb_time';
%
  nc{'wke_south'} = ncdouble('brywkb_time','xi_rho') ;
  nc{'wke_south'}.long_name = ncchar('southern boundary eta-dir wavenumber vector');
  nc{'wke_south'}.long_name = 'southern boundary eta-dir wavenumber vector';
  nc{'wke_south'}.units = ncchar('radian/meter');
  nc{'wke_south'}.units = 'radian/meter';
  nc{'wke_south'}.coordinates = ncchar('lon_rho brywkb_time');
  nc{'wke_south'}.coordinates = 'lon_rho brywkb_time';
%
end
%
if wkb_obc(2)==1
%
%   Eastern boundary
%
  nc{'wac_east'} = ncdouble('brywkb_time','eta_rho') ;
  nc{'wac_east'}.long_name = ncchar('eastern boundary wave action density');
  nc{'wac_east'}.long_name = 'eastern boundary wave action density';
  nc{'wac_east'}.units = ncchar('meter^3 second^-1');
  nc{'wac_east'}.units = 'meter^3 second^-1';
  nc{'wac_east'}.coordinates = ncchar('lat_rho brywkb_time');
  nc{'wac_east'}.coordinates = 'lat_rho brywkb_time';
%
  nc{'wkx_east'} = ncdouble('brywkb_time','eta_rho') ;
  nc{'wkx_east'}.long_name = ncchar('eastern boundary xi-dir wavenumber vector');
  nc{'wkx_east'}.long_name = 'eastern boundary xi-dir wavenumber vector';
  nc{'wkx_east'}.units = ncchar('radian/meter');
  nc{'wkx_east'}.units = 'radian/meter';
  nc{'wkx_east'}.coordinates = ncchar('lat_rho brywkb_time');
  nc{'wkx_east'}.coordinates = 'lat_rho brywkb_time';
%
  nc{'wke_east'} = ncdouble('brywkb_time','eta_rho') ;
  nc{'wke_east'}.long_name = ncchar('eastern boundary eta-dir wavenumber vector');
  nc{'wke_east'}.long_name = 'eastern boundary eta-dir wavenumber vector';
  nc{'wke_east'}.units = ncchar('radian/meter');
  nc{'wke_east'}.units = 'radian/meter';
  nc{'wke_east'}.coordinates = ncchar('lat_rho brywkb_time');
  nc{'wke_east'}.coordinates = 'lat_rho brywkb_time';
%
end
%
if wkb_obc(3)==1
%
%   Northern boundary
%
  nc{'wac_north'} = ncdouble('brywkb_time','xi_rho') ;
  nc{'wac_north'}.long_name = ncchar('northern boundary wave action density');
  nc{'wac_north'}.long_name = 'northern boundary wave action density';
  nc{'wac_north'}.units = ncchar('meter^3 second^-1');
  nc{'wac_north'}.units = 'meter^3 second^-1';
  nc{'wac_north'}.coordinates = ncchar('lon_rho brywkb_time');
  nc{'wac_north'}.coordinates = 'lon_rho brywkb_time';
%
  nc{'wac_north'} = ncdouble('brywkb_time','xi_rho') ;
  nc{'wac_north'}.long_name = ncchar('northern boundary xi-dir wavenumber vector');
  nc{'wac_north'}.long_name = 'northern boundary xi-dir wavenumber vector';
  nc{'wac_north'}.units = ncchar('radian/meter');
  nc{'wac_north'}.units = 'radian/meter';
  nc{'wac_north'}.coordinates = ncchar('lon_rho brywkb_time');
  nc{'wac_north'}.coordinates = 'lon_rho brywkb_time';
%
  nc{'wac_north'} = ncdouble('brywkb_time','xi_rho') ;
  nc{'wac_north'}.long_name = ncchar('northern boundary eta-dir wavenumber vector');
  nc{'wac_north'}.long_name = 'northern boundary eta-dir wavenumber vector';
  nc{'wac_north'}.units = ncchar('radian/meter');
  nc{'wac_north'}.units = 'radian/meter';
  nc{'wac_north'}.coordinates = ncchar('lon_rho brywkb_time');
  nc{'wac_north'}.coordinates = 'lon_rho brywkb_time';
%
end
%
if wkb_obc(4)==1
%
%   Western boundary
%
  nc{'wac_west'} = ncdouble('brywkb_time','eta_rho') ;
  nc{'wac_west'}.long_name = ncchar('western boundary wave action density');
  nc{'wac_west'}.long_name = 'western boundary wave action density';
  nc{'wac_west'}.units = ncchar('meter^3 second^-1');
  nc{'wac_west'}.units = 'meter^3 second^-1';
  nc{'wac_west'}.coordinates = ncchar('lat_rho brywkb_time');
  nc{'wac_west'}.coordinates = 'lat_rho brywkb_time';
%
  nc{'wkx_west'} = ncdouble('brywkb_time','eta_rho') ;
  nc{'wkx_west'}.long_name = ncchar('western boundary xi-dir wavenumber vector');
  nc{'wkx_west'}.long_name = 'western boundary xi-dir wavenumber vector';
  nc{'wkx_west'}.units = ncchar('radian/meter');
  nc{'wkx_west'}.units = 'radian/meter';
  nc{'wkx_west'}.coordinates = ncchar('lat_rho brywkb_time');
  nc{'wkx_west'}.coordinates = 'lat_rho brywkb_time';
%
  nc{'wke_west'} = ncdouble('brywkb_time','eta_rho') ;
  nc{'wke_west'}.long_name = ncchar('western boundary eta-dir wavenumber vector');
  nc{'wke_west'}.long_name = 'western boundary eta-dir wavenumber vector';
  nc{'wke_west'}.units = ncchar('radian/meter');
  nc{'wke_west'}.units = 'radian/meter';
  nc{'wke_west'}.coordinates = ncchar('lon_rho brywkb_time');
  nc{'wke_west'}.coordinates = 'lat_rho brywkb_time';
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
nc.clim_file = ncchar(brywkbname);
nc.clim_file = brywkbname;
nc.grd_file = ncchar(grdname);
nc.grd_file = grdname;
nc.type = ncchar(type);
nc.type = type;
nc.history = ncchar(history);
nc.history = history;
%
% Leave define mode
%
result = endef(nc);
%
nc{'tstart'}(:) =  min([min(time) min(time) min(time)]); 
nc{'tend'}(:) =  max([max(time) max(time) max(time)]); 
nc{'brywkb_time'}(:) =  time; 
if wkb_obc(1)==1
  nc{'wac_south'}(:) =  0; 
  nc{'wkx_south'}(:) =  0; 
  nc{'wkx_south'}(:) =  0; 
end 
if wkb_obc(2)==1
  nc{'wac_east'}(:) =  0; 
  nc{'wkx_east'}(:) =  0; 
  nc{'wke_east'}(:) =  0; 
end 
if wkb_obc(3)==1
  nc{'wac_north'}(:) =  0; 
  nc{'wkx_north'}(:) =  0; 
  nc{'wke_north'}(:) =  0; 
end 
if wkb_obc(4)==1
  nc{'wac_west'}(:) =  0; 
  nc{'wkx_west'}(:) =  0; 
  nc{'wke_west'}(:) =  0; 
end 
close(nc)
return


