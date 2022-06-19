function add_bry_pisces(bryname,obc,time,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 
% function add_bry_pisces(bryname,grdname,title,obc...            
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
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding PISCES data into file : ',bryname])
disp(' ')
%
%  Redefine the boundary file
%
nc = netcdf(bryname,clobber);
%%result = redef(nc);
%
%  Create dimensions
%
nc('dic_time')  = length(time);
nc('doc_time')  = length(time);
nc('no3_time')  = length(time);
nc('po4_time')  = length(time);
nc('talk_time') = length(time);
nc('si_time')   = length(time);
nc('fer_time')  = length(time);
nc('o2_time')   = length(time);
nc('one') = 1;
%
%  Create variables and attributes
%
nc{'dic_time'} = ncdouble('dic_time') ;
nc{'dic_time'}.long_name = ncchar('time for DIC climatology');
nc{'dic_time'}.long_name = 'time for DIC climatology';
nc{'dic_time'}.units = ncchar('day');
nc{'dic_time'}.units = 'day';
nc{'dic_time'}.cycle_length = cycle;%
%
nc{'talk_time'} = ncdouble('talk_time') ;
nc{'talk_time'}.long_name = ncchar('time for TALK climatology');
nc{'talk_time'}.long_name = 'time for TALK climatology';
nc{'talk_time'}.units = ncchar('day');
nc{'talk_time'}.units = 'day';
nc{'talk_time'}.cycle_length = cycle;%
%
nc{'no3_time'} = ncdouble('no3_time') ;
nc{'no3_time'}.long_name = ncchar('time for NO3 climatology')
nc{'no3_time'}.long_name = 'time for NO3 climatology';
nc{'no3_time'}.units = ncchar('day');
nc{'no3_time'}.units = 'day';
nc{'no3_time'}.cycle_length = cycle;%
%
nc{'po4_time'} = ncdouble('po4_time') ;
nc{'po4_time'}.long_name = ncchar('time for PO4 climatology');
nc{'po4_time'}.long_name = 'time for PO4 climatology';
nc{'po4_time'}.units = ncchar('day');
nc{'po4_time'}.units = 'day';
nc{'po4_time'}.cycle_length = cycle;%
%
nc{'si_time'} = ncdouble('si_time') ;
nc{'si_time'}.long_name = ncchar('time for Si climatology');
nc{'si_time'}.long_name = 'time for Si climatology';
nc{'si_time'}.units = ncchar('day');
nc{'si_time'}.units = 'day';
nc{'si_time'}.cycle_length = cycle;%
%
nc{'o2_time'} = ncdouble('o2_time') ;
nc{'o2_time'}.long_name = ncchar('time for O2 climatology');
nc{'o2_time'}.long_name = 'time for O2 climatology';
nc{'o2_time'}.units = ncchar('day');
nc{'o2_time'}.units = 'day';
nc{'o2_time'}.cycle_length = cycle;%
%
nc{'doc_time'} = ncdouble('doc_time') ;
nc{'doc_time'}.long_name = ncchar('time for DOC climatology');
nc{'doc_time'}.long_name = 'time for DOC climatology';
nc{'doc_time'}.units = ncchar('day');
nc{'doc_time'}.units = 'day';
nc{'doc_time'}.cycle_length = cycle;%
%
nc{'fer_time'} = ncdouble('fer_time') ;
nc{'fer_time'}.long_name = ncchar('time for FER climatology');
nc{'fer_time'}.long_name = 'time for FER climatology';
nc{'fer_time'}.units = ncchar('day');
nc{'fer_time'}.units = 'day';
nc{'fer_time'}.cycle_length = cycle;%
%
if obc(1)==1
%
%   Southern boundary
%
  nc{'NO3_south'} = ncdouble('no3_time','s_rho','xi_rho') ;
  nc{'NO3_south'}.long_name = ncchar('southern boundary NO3');
  nc{'NO3_south'}.long_name = 'southern boundary NO3';
  nc{'NO3_south'}.units = ncchar('mMol N m-3');
  nc{'NO3_south'}.units = 'mMol N m-3';
%
  nc{'PO4_south'} = ncdouble('po4_time','s_rho','xi_rho') ;
  nc{'PO4_south'}.long_name = ncchar('southern boundary PO4');
  nc{'PO4_south'}.long_name = 'southern boundary PO4';
  nc{'PO4_south'}.units = ncchar('mMol N m-3');
  nc{'PO4_south'}.units = 'mMol N m-3';
%
  nc{'Si_south'} = ncdouble('si_time','s_rho','xi_rho') ;
  nc{'Si_south'}.long_name = ncchar('southern boundary Si');
  nc{'Si_south'}.long_name = 'southern boundary Si';
  nc{'Si_south'}.units = ncchar('mMol N m-3');
  nc{'Si_south'}.units = 'mMol N m-3';
%
  nc{'O2_south'} = ncdouble('o2_time','s_rho','xi_rho') ;
  nc{'O2_south'}.long_name = ncchar('southern boundary O2');
  nc{'O2_south'}.long_name = 'southern boundary O2';
  nc{'O2_south'}.units = ncchar('mMol N m-3');
  nc{'O2_south'}.units = 'mMol N m-3';
%
  nc{'DIC_south'} = ncdouble('dic_time','s_rho','xi_rho') ;
  nc{'DIC_south'}.long_name = ncchar('southern boundary DIC');
  nc{'DIC_south'}.long_name = 'southern boundary DIC';
  nc{'DIC_south'}.units = ncchar('mMol N m-3');
  nc{'DIC_south'}.units = 'mMol N m-3';
%
  nc{'TALK_south'} = ncdouble('talk_time','s_rho','xi_rho') ;
  nc{'TALK_south'}.long_name = ncchar('southern boundary TALK');
  nc{'TALK_south'}.long_name = 'southern boundary TALK';
  nc{'TALK_south'}.units = ncchar('mMol N m-3');
  nc{'TALK_south'}.units = 'mMol N m-3';
%
  nc{'DOC_south'} = ncdouble('doc_time','s_rho','xi_rho') ;
  nc{'DOC_south'}.long_name = ncchar('southern boundary DOC');
  nc{'DOC_south'}.long_name = 'southern boundary DOC';
  nc{'DOC_south'}.units = ncchar('mMol N m-3');
  nc{'DOC_south'}.units = 'mMol N m-3';
%
  nc{'FER_south'} = ncdouble('fer_time','s_rho','xi_rho') ;
  nc{'FER_south'}.long_name = ncchar('southern boundary Iron');
  nc{'FER_south'}.long_name = 'southern boundary Iron';
  nc{'FER_south'}.units = ncchar('mMol N m-3');
  nc{'FER_south'}.units = 'mMol N m-3';
%
end
%
if obc(2)==1
%
%   Eastern boundary
%
  nc{'NO3_east'} = ncdouble('no3_time','s_rho','eta_rho') ;
  nc{'NO3_east'}.long_name = ncchar('eastern boundary NO3');
  nc{'NO3_east'}.long_name = 'eastern boundary NO3';
  nc{'NO3_east'}.units = ncchar('mMol N m-3');
  nc{'NO3_east'}.units = 'mMol N m-3';
%
  nc{'PO4_east'} = ncdouble('po4_time','s_rho','eta_rho') ;
  nc{'PO4_east'}.long_name = ncchar('eastern boundary PO4');
  nc{'PO4_east'}.long_name = 'eastern boundary PO4';
  nc{'PO4_east'}.units = ncchar('mMol N m-3');
  nc{'PO4_east'}.units = 'mMol N m-3';
%
  nc{'Si_east'} = ncdouble('si_time','s_rho','eta_rho') ;
  nc{'Si_east'}.long_name = ncchar('eastern boundary Si');
  nc{'Si_east'}.long_name = 'eastern boundary Si';
  nc{'Si_east'}.units = ncchar('mMol N m-3');
  nc{'Si_east'}.units = 'mMol N m-3';
%
  nc{'O2_east'} = ncdouble('o2_time','s_rho','eta_rho') ;
  nc{'O2_east'}.long_name = ncchar('eastern boundary O2');
  nc{'O2_east'}.long_name = 'eastern boundary O2';
  nc{'O2_east'}.units = ncchar('mMol N m-3');
  nc{'O2_east'}.units = 'mMol N m-3';
%
  nc{'DIC_east'} = ncdouble('dic_time','s_rho','eta_rho') ;
  nc{'DIC_east'}.long_name = ncchar('eastern boundary DIC');
  nc{'DIC_east'}.long_name = 'eastern boundary DIC';
  nc{'DIC_east'}.units = ncchar('mMol N m-3');
  nc{'DIC_east'}.units = 'mMol N m-3';
%
  nc{'TALK_east'} = ncdouble('talk_time','s_rho','eta_rho') ;
  nc{'TALK_east'}.long_name = ncchar('eastern boundary TALK');
  nc{'TALK_east'}.long_name = 'eastern boundary TALK';
  nc{'TALK_east'}.units = ncchar('mMol N m-3');
  nc{'TALK_east'}.units = 'mMol N m-3';
%
  nc{'DOC_east'} = ncdouble('doc_time','s_rho','eta_rho') ;
  nc{'DOC_east'}.long_name = ncchar('eastern boundary DOC');
  nc{'DOC_east'}.long_name = 'eastern boundary DOC';
  nc{'DOC_east'}.units = ncchar('mMol N m-3');
  nc{'DOC_east'}.units = 'mMol N m-3';
%
  nc{'FER_east'} = ncdouble('fer_time','s_rho','eta_rho') ;
  nc{'FER_east'}.long_name = ncchar('eastern boundary Iron');
  nc{'FER_east'}.long_name = 'eastern boundary Iron';
  nc{'FER_east'}.units = ncchar('mMol N m-3');
  nc{'FER_east'}.units = 'mMol N m-3';
%
end
%
if obc(3)==1
%
%   Northern boundary
%
  nc{'NO3_north'} = ncdouble('no3_time','s_rho','xi_rho') ;
  nc{'NO3_north'}.long_name = ncchar('northern boundary NO3');
  nc{'NO3_north'}.long_name = 'northern boundary NO3';
  nc{'NO3_north'}.units = ncchar('mMol N m-3');
  nc{'NO3_north'}.units = 'mMol N m-3';
%
  nc{'PO4_north'} = ncdouble('po4_time','s_rho','xi_rho') ;
  nc{'PO4_north'}.long_name = ncchar('northern boundary PO4');
  nc{'PO4_north'}.long_name = 'northern boundary PO4';
  nc{'PO4_north'}.units = ncchar('mMol N m-3');
  nc{'PO4_north'}.units = 'mMol N m-3';
%
  nc{'Si_north'} = ncdouble('si_time','s_rho','xi_rho') ;
  nc{'Si_north'}.long_name = ncchar('northern boundary Si');
  nc{'Si_north'}.long_name = 'northern boundary Si';
  nc{'Si_north'}.units = ncchar('mMol N m-3');
  nc{'Si_north'}.units = 'mMol N m-3';
%
  nc{'O2_north'} = ncdouble('o2_time','s_rho','xi_rho') ;
  nc{'O2_north'}.long_name = ncchar('northern boundary O2');
  nc{'O2_north'}.long_name = 'northern boundary O2';
  nc{'O2_north'}.units = ncchar('mMol N m-3');
  nc{'O2_north'}.units = 'mMol N m-3';
%
  nc{'DIC_north'} = ncdouble('dic_time','s_rho','xi_rho') ;
  nc{'DIC_north'}.long_name = ncchar('northern boundary DIC');
  nc{'DIC_north'}.long_name = 'northern boundary DIC';
  nc{'DIC_north'}.units = ncchar('mMol N m-3');
  nc{'DIC_north'}.units = 'mMol N m-3';
%
  nc{'TALK_north'} = ncdouble('talk_time','s_rho','xi_rho') ;
  nc{'TALK_north'}.long_name = ncchar('northern boundary TALK');
  nc{'TALK_north'}.long_name = 'northern boundary TALK';
  nc{'TALK_north'}.units = ncchar('mMol N m-3');
  nc{'TALK_north'}.units = 'mMol N m-3';
%
  nc{'DOC_north'} = ncdouble('doc_time','s_rho','xi_rho') ;
  nc{'DOC_north'}.long_name = ncchar('northern boundary DOC');
  nc{'DOC_north'}.long_name = 'northern boundary DOC';
  nc{'DOC_north'}.units = ncchar('mMol N m-3');
  nc{'DOC_north'}.units = 'mMol N m-3';
%
  nc{'FER_north'} = ncdouble('fer_time','s_rho','xi_rho') ;
  nc{'FER_north'}.long_name = ncchar('northern boundary Iron');
  nc{'FER_north'}.long_name = 'northern boundary Iron';
  nc{'FER_north'}.units = ncchar('mMol N m-3');
  nc{'FER_north'}.units = 'mMol N m-3';
%
end
%
if obc(4)==1
%
%   Western boundary
%
  nc{'NO3_west'} = ncdouble('no3_time','s_rho','eta_rho') ;
  nc{'NO3_west'}.long_name = ncchar('western boundary NO3');
  nc{'NO3_west'}.long_name = 'western boundary NO3';
  nc{'NO3_west'}.units = ncchar('mMol N m-3');
  nc{'NO3_west'}.units = 'mMol N m-3';
%
  nc{'PO4_west'} = ncdouble('po4_time','s_rho','eta_rho') ;
  nc{'PO4_west'}.long_name = ncchar('western boundary PO4');
  nc{'PO4_west'}.long_name = 'western boundary PO4';
  nc{'PO4_west'}.units = ncchar('mMol N m-3');
  nc{'PO4_west'}.units = 'mMol N m-3';
%
  nc{'Si_west'} = ncdouble('si_time','s_rho','eta_rho') ;
  nc{'Si_west'}.long_name = ncchar('western boundary Si');
  nc{'Si_west'}.long_name = 'western boundary Si';
  nc{'Si_west'}.units = ncchar('mMol N m-3');
  nc{'Si_west'}.units = 'mMol N m-3';
%
  nc{'O2_west'} = ncdouble('o2_time','s_rho','eta_rho') ;
  nc{'O2_west'}.long_name = ncchar('western boundary O2');
  nc{'O2_west'}.long_name = 'western boundary O2';
  nc{'O2_west'}.units = ncchar('mMol N m-3');
  nc{'O2_west'}.units = 'mMol N m-3';
%
  nc{'DIC_west'} = ncdouble('dic_time','s_rho','eta_rho') ;
  nc{'DIC_west'}.long_name = ncchar('western boundary DIC');
  nc{'DIC_west'}.long_name = 'western boundary DIC';
  nc{'DIC_west'}.units = ncchar('mMol N m-3');
  nc{'DIC_west'}.units = 'mMol N m-3';
%
  nc{'TALK_west'} = ncdouble('talk_time','s_rho','eta_rho') ;
  nc{'TALK_west'}.long_name = ncchar('western boundary TALK');
  nc{'TALK_west'}.long_name = 'western boundary TALK';
  nc{'TALK_west'}.units = ncchar('mMol N m-3');
  nc{'TALK_west'}.units = 'mMol N m-3';
%
  nc{'DOC_west'} = ncdouble('doc_time','s_rho','eta_rho') ;
  nc{'DOC_west'}.long_name = ncchar('western boundary DOC');
  nc{'DOC_west'}.long_name = 'western boundary DOC';
  nc{'DOC_west'}.units = ncchar('mMol N m-3');
  nc{'DOC_west'}.units = 'mMol N m-3';
%
  nc{'FER_west'} = ncdouble('fer_time','s_rho','eta_rho') ;
  nc{'FER_west'}.long_name = ncchar('western boundary Iron');
  nc{'FER_west'}.long_name = 'western boundary Iron';
  nc{'FER_west'}.units = ncchar('mMol N m-3');
  nc{'FER_west'}.units = 'mMol N m-3';
%
end
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
nc{'dic_time'}(:) = time;
nc{'doc_time'}(:) = time;
nc{'no3_time'}(:) = time;
nc{'po4_time'}(:) = time;
nc{'talk_time'}(:) = time;
nc{'si_time'}(:) = time;
nc{'fer_time'}(:) = time;
nc{'o2_time'}(:) = time;
if obc(1)==1
  nc{'NO3_south'}(:)  =  0;
  nc{'PO4_south'}(:)  =  0;
  nc{'Si_south'}(:) =  0;
  nc{'O2_south'}(:)   =  0;
  nc{'DIC_south'}(:)  =  0;
  nc{'TALK_south'}(:) =  0;
  nc{'DOC_south'}(:)  =  0;
  nc{'FER_south'}(:)  =  0;
end 
if obc(2)==1
  nc{'NO3_east'}(:)  =  0;
  nc{'PO4_east'}(:)  =  0;
  nc{'Si_east'}(:) =  0;
  nc{'O2_east'}(:)   =  0;
  nc{'DIC_east'}(:)  =  0;
  nc{'TALK_east'}(:) =  0;
  nc{'DOC_east'}(:)  =  0;
  nc{'FER_east'}(:)  =  0;
end 
if obc(3)==1
  nc{'NO3_north'}(:)  =  0;
  nc{'PO4_north'}(:)  =  0;
  nc{'Si_north'}(:) =  0;
  nc{'O2_north'}(:)   =  0;
  nc{'DIC_north'}(:)  =  0;
  nc{'TALK_north'}(:) =  0;
  nc{'DOC_north'}(:)  =  0;
  nc{'FER_north'}(:)  =  0;
end 
if obc(4)==1
  nc{'NO3_west'}(:)  =  0;
  nc{'PO4_west'}(:)  =  0;
  nc{'Si_west'}(:) =  0;
  nc{'O2_west'}(:)   =  0;
  nc{'DIC_west'}(:)  =  0;
  nc{'TALK_west'}(:) =  0;
  nc{'DOC_west'}(:)  =  0;
  nc{'FER_west'}(:)  =  0;
end 
close(nc)
return

