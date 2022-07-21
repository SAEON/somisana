function add_bry_npzd_Z(zbryname,obc,Z,time_no3,time_o2,time_zoo,time_phyto,time_chla,cycle,clobber);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%   function add_bry_npzd_Z(zbryname,obc,...                    %
%                             Z,time,cycle,clobber);              %
%                                                                 %
%   This function create the header of a Netcdf climatology       %
%   file.                                                         %
%                                                                 %
%   Input:                                                        %
%                                                                 %
%   zbryname     Netcdf climatology file name (character string). %
%   obc          open boundaries flag (1=open , [S E N W]).       %
%   Z            Depth of vertical levels.(Vector)                %
%   time         time.(vector)                                    %
%   cycle        Length (days) for cycling the climatology.(Real) %
%   clobber      Switch to allow or not writing over an existing  %
%                file.(character string)                          %
%                                                                 %
%  Pierrick Penven, IRD, 2005.                                    %
%  Olivier Aumont the master, IRD, 2006.                          %
%  Patricio Marchesiello, chief, IRD, 2007.                       %
%  Christophe Eugene Raoul Menkes, the slave, IRD, 2007.          %
%  Gildas Cambon, IRD/LEGOS, 2013 : Add O2 processing             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding NPZD data into file : ',zbryname])
disp(' ')
%
%  Create the boundary file
%
nc = netcdf(zbryname,clobber);
%%result = redef(nc);
%
%  Create dimensions
%
nc('no3_time') = length(time_no3);
nc('o2_time') = length(time_o2);
nc('chla_time') = length(time_chla);
nc('zoo_time') = length(time_zoo);
nc('phyto_time') = length(time_phyto);
nc('one') = 1;
%
%  Create variables and attributes
%
nc{'no3_time'} = ncdouble('no3_time') ;
nc{'no3_time'}.long_name = ncchar('time for NO3 climatology')
nc{'no3_time'}.long_name = 'time for NO3 climatology';
nc{'no3_time'}.units = ncchar('day');
nc{'no3_time'}.units = 'day';
nc{'no3_time'}.cycle_length = cycle;
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
nc{'phyto_time'} = ncdouble('phyto_time') ;
nc{'phyto_time'}.long_name = ncchar('time for PHYTO climatology');
nc{'phyto_time'}.long_name = 'time for PHYTO climatology';
nc{'phyto_time'}.units = ncchar('day');
nc{'phyto_time'}.units = 'day';
nc{'phyto_time'}.cycle_length = cycle;%
%
nc{'zoo_time'} = ncdouble('zoo_time') ;
nc{'zoo_time'}.long_name = ncchar('time for ZOO climatology');
nc{'zoo_time'}.long_name = 'time for ZOO climatology';
nc{'zoo_time'}.units = ncchar('day');
nc{'zoo_time'}.units = 'day';
nc{'zoo_time'}.cycle_length = cycle;
%

if obc(1)==1
%
%   Southern boundary
%
  nc{'NO3_south'} = ncdouble('no3_time','Z','xi_rho') ;
  nc{'NO3_south'}.long_name = ncchar('southern boundary NO3');
  nc{'NO3_south'}.long_name = 'southern boundary NO3';
  nc{'NO3_south'}.units = ncchar('mMol N m-3');
  nc{'NO3_south'}.units = 'mMol N m-3';
%
  nc{'O2_south'} = ncdouble('no3_time','Z','xi_rho') ;
  nc{'O2_south'}.long_name = ncchar('southern boundary O2');
  nc{'O2_south'}.long_name = 'southern boundary O2';
  nc{'O2_south'}.units = ncchar('mMol O m-3');
  nc{'O2_south'}.units = 'mMol O m-3';
%
  nc{'CHLA_south'} = ncdouble('chla_time','Z','xi_rho') ;
  nc{'CHLA_south'}.long_name = ncchar('southern boundary CHLA');
  nc{'CHLA_south'}.long_name = 'southern boundary CHLA';
  nc{'CHLA_south'}.units = ncchar('mMol N m-3');
  nc{'CHLA_south'}.units = 'mMol N m-3';
%
  nc{'ZOO_south'} = ncdouble('zoo_time','Z','xi_rho') ;
  nc{'ZOO_south'}.long_name = ncchar('southern boundary ZOO');
  nc{'ZOO_south'}.long_name = 'southern boundary ZOO';
  nc{'ZOO_south'}.units = ncchar('mMol N m-3');
  nc{'ZOO_south'}.units = 'mMol N m-3';
%
  nc{'PHYTO_south'} = ncdouble('phyto_time','Z','xi_rho') ;
  nc{'PHYTO_south'}.long_name = ncchar('southern boundary PHYTO');
  nc{'PHYTO_south'}.long_name = 'southern boundary PHYTO';
  nc{'PHYTO_south'}.units = ncchar('mMol N m-3');
  nc{'PHYTO_south'}.units = 'mMol N m-3';
end
%
if obc(2)==1
%
%   Eastern boundary
%
  nc{'NO3_east'} = ncdouble('no3_time','Z','eta_rho') ;
  nc{'NO3_east'}.long_name = ncchar('eastern boundary NO3');
  nc{'NO3_east'}.long_name = 'eastern boundary NO3';
  nc{'NO3_east'}.units = ncchar('mMol N m-3');
  nc{'NO3_east'}.units = 'mMol N m-3';
%
  nc{'O2_east'} = ncdouble('o2_time','Z','eta_rho') ;
  nc{'O2_east'}.long_name = ncchar('eastern boundary O2');
  nc{'O2_east'}.long_name = 'eastern boundary O2';
  nc{'O2_east'}.units = ncchar('mMol O m-3');
  nc{'O2_east'}.units = 'mMol O m-3';
%
  nc{'CHLA_east'} = ncdouble('chla_time','Z','eta_rho') ;
  nc{'CHLA_east'}.long_name = ncchar('eastern boundary CHLA');
  nc{'CHLA_east'}.long_name = 'eastern boundary CHLA';
  nc{'CHLA_east'}.units = ncchar('mMol N m-3');
  nc{'CHLA_east'}.units = 'mMol N m-3';
%
  nc{'ZOO_east'} = ncdouble('zoo_time','Z','eta_rho') ;
  nc{'ZOO_east'}.long_name = ncchar('eastern boundary ZOO');
  nc{'ZOO_east'}.long_name = 'eastern boundary ZOO';
  nc{'ZOO_east'}.units = ncchar('mMol N m-3');
  nc{'ZOO_east'}.units = 'mMol N m-3';
%
  nc{'PHYTO_east'} = ncdouble('phyto_time','Z','eta_rho') ;
  nc{'PHYTO_east'}.long_name = ncchar('eastern boundary PHYTO');
  nc{'PHYTO_east'}.long_name = 'eastern boundary PHYTO';
  nc{'PHYTO_east'}.units = ncchar('mMol N m-3');
  nc{'PHYTO_east'}.units = 'mMol N m-3';
%
end
%
if obc(3)==1
%
%   Northern boundary
%
  nc{'NO3_north'} = ncdouble('no3_time','Z','xi_rho') ;
  nc{'NO3_north'}.long_name = ncchar('northern boundary NO3');
  nc{'NO3_north'}.long_name = 'northern boundary NO3';
  nc{'NO3_north'}.units = ncchar('mMol N m-3');
  nc{'NO3_north'}.units = 'mMol N m-3';
%
  nc{'O2_north'} = ncdouble('o2_time','Z','xi_rho') ;
  nc{'O2_north'}.long_name = ncchar('northern boundary O2');
  nc{'O2_north'}.long_name = 'northern boundary O2';
  nc{'O2_north'}.units = ncchar('mMol O m-3');
  nc{'O2_north'}.units = 'mMol O m-3';
%
  nc{'CHLA_north'} = ncdouble('chla_time','Z','xi_rho') ;
  nc{'CHLA_north'}.long_name = ncchar('northern boundary CHLA');
  nc{'CHLA_north'}.long_name = 'northern boundary CHLA';
  nc{'CHLA_north'}.units = ncchar('mMol N m-3');
  nc{'CHLA_north'}.units = 'mMol N m-3';
%
  nc{'ZOO_north'} = ncdouble('zoo_time','Z','xi_rho') ;
  nc{'ZOO_north'}.long_name = ncchar('northern boundary ZOO');
  nc{'ZOO_north'}.long_name = 'northern boundary ZOO';
  nc{'ZOO_north'}.units = ncchar('mMol N m-3');
  nc{'ZOO_north'}.units = 'mMol N m-3';
%
  nc{'PHYTO_north'} = ncdouble('phyto_time','Z','xi_rho') ;
  nc{'PHYTO_north'}.long_name = ncchar('northern boundary PHYTO');
  nc{'PHYTO_north'}.long_name = 'northern boundary PHYTO';
  nc{'PHYTO_north'}.units = ncchar('mMol N m-3');
  nc{'PHYTO_north'}.units = 'mMol N m-3';
%
end
%
if obc(4)==1
%
%   Western boundary
%
  nc{'NO3_west'} = ncdouble('no3_time','Z','eta_rho') ;
  nc{'NO3_west'}.long_name = ncchar('western boundary NO3');
  nc{'NO3_west'}.long_name = 'western boundary NO3';
  nc{'NO3_west'}.units = ncchar('mMol N m-3');
  nc{'NO3_west'}.units = 'mMol N m-3';
%
  nc{'O2_west'} = ncdouble('no3_time','Z','eta_rho') ;
  nc{'O2_west'}.long_name = ncchar('western boundary O2');
  nc{'O2_west'}.long_name = 'western boundary O2';
  nc{'O2_west'}.units = ncchar('mMol O m-3');
  nc{'O2_west'}.units = 'mMol O m-3';
%
  nc{'CHLA_west'} = ncdouble('chla_time','Z','eta_rho') ;
  nc{'CHLA_west'}.long_name = ncchar('western boundary CHLA');
  nc{'CHLA_west'}.long_name = 'western boundary CHLA';
  nc{'CHLA_west'}.units = ncchar('mMol N m-3');
  nc{'CHLA_west'}.units = 'mMol N m-3';
%
  nc{'ZOO_west'} = ncdouble('zoo_time','Z','eta_rho') ;
  nc{'ZOO_west'}.long_name = ncchar('western boundary ZOO');
  nc{'ZOO_west'}.long_name = 'western boundary ZOO';
  nc{'ZOO_west'}.units = ncchar('mMol N m-3');
  nc{'ZOO_west'}.units = 'mMol N m-3';
%
  nc{'PHYTO_west'} = ncdouble('phyto_time','Z','eta_rho') ;
  nc{'PHYTO_west'}.long_name = ncchar('western boundary PHYTO');
  nc{'PHYTO_west'}.long_name = 'western boundary PHYTO';
  nc{'PHYTO_west'}.units = ncchar('mMol N m-3');
  nc{'PHYTO_west'}.units = 'mMol N m-3';
%
end
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
nc{'no3_time'}(:) = time_no3;
nc{'o2_time'}(:) = time_no3;
nc{'chla_time'}(:) = time_chla;
nc{'zoo_time'}(:) = time_zoo;
nc{'phyto_time'}(:) = time_phyto;
if obc(1)==1
  nc{'NO3_south'}(:)  =  0;
  nc{'O2_south'}(:)  =  0;
  nc{'CHLA_south'}(:)  =  0;
  nc{'ZOO_south'}(:) =  0;
  nc{'PHYTO_south'}(:)   =  0;
end
if obc(2)==1 
  nc{'NO3_east'}(:)  =  0;
  nc{'O2_east'}(:)  =  0;
  nc{'CHLA_east'}(:)  =  0;
  nc{'ZOO_east'}(:) =  0;
  nc{'PHYTO_east'}(:)   =  0;
end 
if obc(3)==1 
  nc{'NO3_north'}(:)  =  0;
  nc{'O2_north'}(:)  =  0;
  nc{'CHLA_north'}(:)  =  0;
  nc{'ZOO_north'}(:) =  0;
  nc{'PHYTO_north'}(:)   =  0;
end 
if obc(4)==1 
  nc{'NO3_west'}(:)  =  0;
  nc{'O2_west'}(:)  =  0;
  nc{'CHLA_west'}(:)  =  0;
  nc{'ZOO_west'}(:) =  0;
  nc{'PHYTO_west'}(:)   =  0;
end 
close(nc)
return


