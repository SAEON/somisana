function add_bry_bioebus(bryname,obc,time_no3,time_o2,time_zoo,time_phyto,time_chla,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 
% function add_bry_bioebus(bryname,grdname,title,obc...            
%                         theta_s,theta_b,hc,N,...                
%                         time,cycle,clobber);                    
%                                                                 
%   This function create the header of a Netcdf climatology       
%   file.                                                         
%                                                                 
%   Input:                                                        
%                                                                 
%   bryname      Netcdf climatology file name (character string). 
%   obc          open boundaries flag (1=open , [S E N W]).       
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
%  Pierrick Penven, IRD, 2005.                                    %
%  Olivier Aumont the master, IRD, 2006.                          %
%  Patricio Marchesiello, chief, IRD, 2007.                       %
%  Christophe Eugene Raoul Menkes, the slave, IRD, 2007.          %
%  Gildas Cambon, IRD, 2011                                       %
%  Gildas Cambon, IRD, 2013 : Add oxygen processing               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding BIOEBUS BGC data into file : ',bryname])
disp(' ')
%
%  Redefine the boundary file
%
nc = netcdf(bryname,clobber);
%%result = redef(nc);
%
%  Create dimenPHYTOons
%
nc('no3_time')  = length(time_no3);
nc('o2_time')  = length(time_o2);
nc('chla_time')  = length(time_chla);
nc('sphyto_time') = length(time_phyto);
nc('lphyto_time') = length(time_phyto);
nc('szoo_time')   = length(time_zoo);
nc('lzoo_time')   = length(time_zoo);
nc('one') = 1;
%
%  Create variables and attributes
%
nc{'no3_time'} = ncdouble('no3_time') ;
nc{'no3_time'}.long_name = ncchar('time for NO3 climatology')
nc{'no3_time'}.long_name = 'time for NO3 climatology';
nc{'no3_time'}.units = ncchar('day');
nc{'no3_time'}.units = 'day';
nc{'no3_time'}.cycle_length = cycle;%
%
nc{'o2_time'} = ncdouble('o2_time') ;
nc{'o2_time'}.long_name = ncchar('time for O2 climatology')
nc{'o2_time'}.long_name = 'time for O2 climatology';
nc{'o2_time'}.units = ncchar('day');
nc{'o2_time'}.units = 'day';
nc{'o2_time'}.cycle_length = cycle;
%
nc{'chla_time'} = ncdouble('chla_time') ;
nc{'chla_time'}.long_name = ncchar('time for CHLA climatology');
nc{'chla_time'}.long_name = 'time for CHLA climatology';
nc{'chla_time'}.units = ncchar('day');
nc{'chla_time'}.units = 'day';
nc{'chla_time'}.cycle_length = cycle;%
%
nc{'sphyto_time'} = ncdouble('sphyto_time') ;
nc{'sphyto_time'}.long_name = ncchar('time for SPHYTO climatology');
nc{'sphyto_time'}.long_name = 'time for SPHYTO climatology';
nc{'sphyto_time'}.units = ncchar('day');
nc{'sphyto_time'}.units = 'day';
nc{'sphyto_time'}.cycle_length = cycle;%
%
nc{'lphyto_time'} = ncdouble('lphyto_time') ;
nc{'lphyto_time'}.long_name = ncchar('time for LPHYTO climatology');
nc{'lphyto_time'}.long_name = 'time for LPHYTO climatology';
nc{'lphyto_time'}.units = ncchar('day');
nc{'lphyto_time'}.units = 'day';
nc{'lphyto_time'}.cycle_length = cycle;%
%
nc{'szoo_time'} = ncdouble('szoo_time') ;
nc{'szoo_time'}.long_name = ncchar('time for SZOO climatology');
nc{'szoo_time'}.long_name = 'time for SZOO climatology';
nc{'szoo_time'}.units = ncchar('day');
nc{'szoo_time'}.units = 'day';
nc{'szoo_time'}.cycle_length = cycle;%
%
nc{'lzoo_time'} = ncdouble('lzoo_time') ;
nc{'lzoo_time'}.long_name = ncchar('time for LZOO climatology');
nc{'lzoo_time'}.long_name = 'time for LZOO climatology';
nc{'lzoo_time'}.units = ncchar('day');
nc{'lzoo_time'}.units = 'day';
nc{'lzoo_time'}.cycle_length = cycle;%
%
%
if obc(1)==1
%
%   Southern boundary
%
  disp('Process Southern boundary')
  
  nc{'NO3_south'} = ncdouble('no3_time','s_rho','xi_rho') ;
  nc{'NO3_south'}.long_name = ncchar('southern boundary NO3');
  nc{'NO3_south'}.long_name = 'southern boundary NO3';
  nc{'NO3_south'}.units = ncchar('mMol N m-3');
  nc{'NO3_south'}.units = 'mMol N m-3';
%
  nc{'O2_south'} = ncdouble('o2_time','s_rho','xi_rho') ;
  nc{'O2_south'}.long_name = ncchar('southern boundary O2');
  nc{'O2_south'}.long_name = 'southern boundary O2';
  nc{'O2_south'}.units = ncchar('mMol O m-3');
  nc{'O2_south'}.units = 'mMol N m-3';
  %
  nc{'CHLA_south'} = ncdouble('chla_time','s_rho','xi_rho') ;
  nc{'CHLA_south'}.long_name = ncchar('southern boundary CHLA');
  nc{'CHLA_south'}.long_name = 'southern boundary CHLA';
  nc{'CHLA_south'}.units = ncchar('mMol N m-3');
  nc{'CHLA_south'}.units = 'mMol N m-3';
%
  nc{'SPHYTO_south'} = ncdouble('sphyto_time','s_rho','xi_rho') ;
  nc{'SPHYTO_south'}.long_name = ncchar('southern boundary SPHYTO');
  nc{'SPHYTO_south'}.long_name = 'southern boundary SPHYTO';
  nc{'SPHYTO_south'}.units = ncchar('mMol N m-3');
  nc{'SPHYTO_south'}.units = 'mMol N m-3';
%
  nc{'LPHYTO_south'} = ncdouble('lphyto_time','s_rho','xi_rho') ;
  nc{'LPHYTO_south'}.long_name = ncchar('southern boundary LPHYTO');
  nc{'LPHYTO_south'}.long_name = 'southern boundary LPHYTO';
  nc{'LPHYTO_south'}.units = ncchar('mMol N m-3');
  nc{'LPHYTO_south'}.units = 'mMol N m-3';
%
  nc{'SZOO_south'} = ncdouble('szoo_time','s_rho','xi_rho') ;
  nc{'SZOO_south'}.long_name = ncchar('southern boundary SZOO');
  nc{'SZOO_south'}.long_name = 'southern boundary SZOO';
  nc{'SZOO_south'}.units = ncchar('mMol N m-3');
  nc{'SZOO_south'}.units = 'mMol N m-3';
%
  nc{'LZOO_south'} = ncdouble('lzoo_time','s_rho','xi_rho') ;
  nc{'LZOO_south'}.long_name = ncchar('southern boundary LZOO');
  nc{'LZOO_south'}.long_name = 'southern boundary LZOO';
  nc{'LZOO_south'}.units = ncchar('mMol N m-3');
  nc{'LZOO_south'}.units = 'mMol N m-3';
%
end
%
if obc(2)==1
%
%   Eastern boundary
%
  disp('Process Eastern boundary')
  
  nc{'NO3_east'} = ncdouble('no3_time','s_rho','eta_rho') ;
  nc{'NO3_east'}.long_name = ncchar('eastern boundary NO3');
  nc{'NO3_east'}.long_name = 'eastern boundary NO3';
  nc{'NO3_east'}.units = ncchar('mMol N m-3');
  nc{'NO3_east'}.units = 'mMol N m-3';
%
  nc{'O2_east'} = ncdouble('o2_time','s_rho','eta_rho') ;
  nc{'O2_east'}.long_name = ncchar('eastern boundary O2');
  nc{'O2_east'}.long_name = 'eastern boundary O2';
  nc{'O2_east'}.units = ncchar('mMol O m-3');
  nc{'O2_east'}.units = 'mMol N m-3';
  %
  nc{'CHLA_east'} = ncdouble('chla_time','s_rho','eta_rho') ;
  nc{'CHLA_east'}.long_name = ncchar('eastern boundary CHLA');
  nc{'CHLA_east'}.long_name = 'eastern boundary CHLA';
  nc{'CHLA_east'}.units = ncchar('mMol N m-3');
  nc{'CHLA_east'}.units = 'mMol N m-3';
%
  nc{'SZOO_east'} = ncdouble('szoo_time','s_rho','eta_rho') ;
  nc{'SZOO_east'}.long_name = ncchar('eastern boundary SZOO');
  nc{'SZOO_east'}.long_name = 'eastern boundary SZOO';
  nc{'SZOO_east'}.units = ncchar('mMol N m-3');
  nc{'SZOO_east'}.units = 'mMol N m-3';
%
  nc{'LZOO_east'} = ncdouble('lzoo_time','s_rho','eta_rho') ;
  nc{'LZOO_east'}.long_name = ncchar('eastern boundary LZOO');
  nc{'LZOO_east'}.long_name = 'eastern boundary LZOO';
  nc{'LZOO_east'}.units = ncchar('mMol N m-3');
  nc{'LZOO_east'}.units = 'mMol N m-3';
%
  nc{'SPHYTO_east'} = ncdouble('sphyto_time','s_rho','eta_rho') ;
  nc{'SPHYTO_east'}.long_name = ncchar('eastern boundary SPHYTO');
  nc{'SPHYTO_east'}.long_name = 'eastern boundary SPHYTO';
  nc{'SPHYTO_east'}.units = ncchar('mMol N m-3');
  nc{'SPHYTO_east'}.units = 'mMol N m-3';
%
  nc{'LPHYTO_east'} = ncdouble('lphyto_time','s_rho','eta_rho') ;
  nc{'LPHYTO_east'}.long_name = ncchar('eastern boundary LPHYTO');
  nc{'LPHYTO_east'}.long_name = 'eastern boundary LPHYTO';
  nc{'LPHYTO_east'}.units = ncchar('mMol N m-3');
  nc{'LPHYTO_east'}.units = 'mMol N m-3';
%
end
%
if obc(3)==1
%
%   Northern boundary
%
  disp('Process Northern boundary')
  
  nc{'NO3_north'} = ncdouble('no3_time','s_rho','xi_rho') ;
  nc{'NO3_north'}.long_name = ncchar('northern boundary NO3');
  nc{'NO3_north'}.long_name = 'northern boundary NO3';
  nc{'NO3_north'}.units = ncchar('mMol N m-3');
  nc{'NO3_north'}.units = 'mMol N m-3';
%
  nc{'O2_north'} = ncdouble('o2_time','s_rho','xi_rho') ;
  nc{'O2_north'}.long_name = ncchar('northern boundary O2');
  nc{'O2_north'}.long_name = 'northern boundary O2';
  nc{'O2_north'}.units = ncchar('mMol O m-3');
  nc{'O2_north'}.units = 'mMol N m-3';
%
  nc{'CHLA_north'} = ncdouble('chla_time','s_rho','xi_rho') ;
  nc{'CHLA_north'}.long_name = ncchar('northern boundary CHLA');
  nc{'CHLA_north'}.long_name = 'northern boundary CHLA';
  nc{'CHLA_north'}.units = ncchar('mMol N m-3');
  nc{'CHLA_north'}.units = 'mMol N m-3';
%
  nc{'SZOO_north'} = ncdouble('szoo_time','s_rho','xi_rho') ;
  nc{'SZOO_north'}.long_name = ncchar('northern boundary SZOO');
  nc{'SZOO_north'}.long_name = 'northern boundary SZOO';
  nc{'SZOO_north'}.units = ncchar('mMol N m-3');
  nc{'SZOO_north'}.units = 'mMol N m-3';
%
  nc{'LZOO_north'} = ncdouble('lzoo_time','s_rho','xi_rho') ;
  nc{'LZOO_north'}.long_name = ncchar('northern boundary LZOO');
  nc{'LZOO_north'}.long_name = 'northern boundary LZOO';
  nc{'LZOO_north'}.units = ncchar('mMol N m-3');
  nc{'LZOO_north'}.units = 'mMol N m-3';
%
  nc{'SPHYTO_north'} = ncdouble('sphyto_time','s_rho','xi_rho') ;
  nc{'SPHYTO_north'}.long_name = ncchar('northern boundary SPHYTO');
  nc{'SPHYTO_north'}.long_name = 'northern boundary SPHYTO';
  nc{'SPHYTO_north'}.units = ncchar('mMol N m-3');
  nc{'SPHYTO_north'}.units = 'mMol N m-3';
%
  nc{'LPHYTO_north'} = ncdouble('lphyto_time','s_rho','xi_rho') ;
  nc{'LPHYTO_north'}.long_name = ncchar('northern boundary LPHYTO');
  nc{'LPHYTO_north'}.long_name = 'northern boundary LPHYTO';
  nc{'LPHYTO_north'}.units = ncchar('mMol N m-3');
  nc{'LPHYTO_north'}.units = 'mMol N m-3';
%
end
%
if obc(4)==1
%
%   Western boundary
%
   disp('Process Western boundary')
 
  nc{'NO3_west'} = ncdouble('no3_time','s_rho','eta_rho') ;
  nc{'NO3_west'}.long_name = ncchar('western boundary NO3');
  nc{'NO3_west'}.long_name = 'western boundary NO3';
  nc{'NO3_west'}.units = ncchar('mMol N m-3');
  nc{'NO3_west'}.units = 'mMol N m-3';
%
  nc{'O2_west'} = ncdouble('o2_time','s_rho','eta_rho') ;
  nc{'O2_west'}.long_name = ncchar('western boundary O2');
  nc{'O2_west'}.long_name = 'western boundary O2';
  nc{'O2_west'}.units = ncchar('mMol O m-3');
  nc{'O2_west'}.units = 'mMol N m-3';
%
  nc{'CHLA_west'} = ncdouble('chla_time','s_rho','eta_rho') ;
  nc{'CHLA_west'}.long_name = ncchar('western boundary CHLA');
  nc{'CHLA_west'}.long_name = 'western boundary CHLA';
  nc{'CHLA_west'}.units = ncchar('mMol N m-3');
  nc{'CHLA_west'}.units = 'mMol N m-3';
%
  nc{'SPHYTO_west'} = ncdouble('sphyto_time','s_rho','eta_rho') ;
  nc{'SPHYTO_west'}.long_name = ncchar('western boundary SPHYTO');
  nc{'SPHYTO_west'}.long_name = 'western boundary SPHYTO';
  nc{'SPHYTO_west'}.units = ncchar('mMol N m-3');
  nc{'SPHYTO_west'}.units = 'mMol N m-3';
%
  nc{'LPHYTO_west'} = ncdouble('lphyto_time','s_rho','eta_rho') ;
  nc{'LPHYTO_west'}.long_name = ncchar('western boundary LPHYTO');
  nc{'LPHYTO_west'}.long_name = 'western boundary LPHYTO';
  nc{'LPHYTO_west'}.units = ncchar('mMol N m-3');
  nc{'LPHYTO_west'}.units = 'mMol N m-3';
%
  nc{'SZOO_west'} = ncdouble('szoo_time','s_rho','eta_rho') ;
  nc{'SZOO_west'}.long_name = ncchar('western boundary SZOO');
  nc{'SZOO_west'}.long_name = 'western boundary SZOO';
  nc{'SZOO_west'}.units = ncchar('mMol N m-3');
  nc{'SZOO_west'}.units = 'mMol N m-3';
%
  nc{'LZOO_west'} = ncdouble('lzoo_time','s_rho','eta_rho') ;
  nc{'LZOO_west'}.long_name = ncchar('western boundary LZOO');
  nc{'LZOO_west'}.long_name = 'western boundary LZOO';
  nc{'LZOO_west'}.units = ncchar('mMol N m-3');
  nc{'LZOO_west'}.units = 'mMol N m-3';
%
end
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
nc{'szoo_time'}(:) = time_zoo;
nc{'lzoo_time'}(:) = time_zoo;
nc{'sphyto_time'}(:) = time_phyto;
nc{'lphyto_time'}(:) = time_phyto;
nc{'no3_time'}(:) = time_no3;
nc{'o2_time'}(:) = time_o2;
nc{'chla_time'}(:) = time_chla;
if obc(1)==1
  nc{'NO3_south'}(:)  =  0;
  nc{'O2_south'}(:)  =  0;
  nc{'CHLA_south'}(:)  =  0;
  nc{'SPHYTO_south'}(:) =  0;
  nc{'LPHYTO_south'}(:) =  0;
  nc{'SZOO_south'}(:)   =  0;
  nc{'LZOO_south'}(:)   =  0;
end 
if obc(2)==1
  nc{'NO3_east'}(:)  =  0;
  nc{'O2_east'}(:)  =  0;
  nc{'CHLA_east'}(:)  =  0;
  nc{'SPHYTO_east'}(:) =  0;
  nc{'LPHYTO_east'}(:) =  0;
  nc{'SZOO_east'}(:)   =  0;
  nc{'LZOO_east'}(:)   =  0;
end 
if obc(3)==1
  nc{'NO3_north'}(:)  =  0;
  nc{'O2_north'}(:)  =  0;
  nc{'CHLA_north'}(:)  =  0;
  nc{'SPHYTO_north'}(:) =  0;
  nc{'LPHYTO_north'}(:) =  0;
  nc{'SZOO_north'}(:)   =  0;
  nc{'LZOO_north'}(:)   =  0;
end 
if obc(4)==1
  nc{'NO3_west'}(:)  =  0;
  nc{'O2_west'}(:)  =  0;
  nc{'CHLA_west'}(:)  =  0;
  nc{'SPHYTO_west'}(:) =  0;
  nc{'LPHYTO_west'}(:) =  0;
  nc{'SZOO_west'}(:)   =  0;
  nc{'LZOO_west'}(:)   =  0;
end 
close(nc)
return

