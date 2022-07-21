%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO boundary file
%
%  Extrapole and interpole fields from a
%  climatology to get boundary conditions for
%  CROCO (boundary netcdf file) .
%
%  Data input format (netcdf):
%     variable(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA98/
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    1-Sep-2006 by Pierrick Penven
%  Pierrick Penven, IRD, 2005.                                    %
%  Olivier Aumont the master, IRD, 2006.                          %
%  Patricio Marchesiello, chief, IRD, 2007.                       %
%  Christophe Eugene Raoul Menkes, the slave, IRD, 2007.          %
%  Elodie Gutknecht, 2013

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  WARNING !!!!!! THIS ASSUMES THAT THE TIME FOR BIOEBUS INITIAL.
%  IS THE SAME AS THE CLIM T AND S. ELSE, CHANGE THE PROGRAM
%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
Roa;
%
% Set times and cycles: seasonal climatology for all data
%
%
%  Data climatologies file names:
%
%
no3_seas_data=[climato_dir,'no3_month.cdf'];
no3_ann_data=[climato_dir,'no3_ann.cdf'];
o2_seas_data=[climato_dir,'o2_month.cdf'];
o2_ann_data=[climato_dir,'o2_ann.cdf'];
chla_seas_data=[chla_dir,'chla_seas.cdf'];
chla_ann_data=[chla_dir,'chla_seas.cdf'];
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp([' Making the file: ',bryname])
disp([' Adding the BGC variables'])
disp(' ')
disp([' Title: ',CROCO_title])
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
nc=netcdf(grdname,'r');
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
hmax=max(max(nc{'h'}(:)));
close(nc);
% %
%Get the time of data
%
nc=netcdf(no3_seas_data,'r');
time_no3=nc{'T'}(:);
close(nc)
time_no3=(time_no3)*30;
%
nc=netcdf(o2_seas_data,'r');
time_o2=nc{'T'}(:);
close(nc)
time_o2=(time_o2)*30;
%
nc=netcdf(chla_seas_data,'r');
time_chla=nc{'T'}(:);
close(nc)
time_chla=(time_chla)*30;
time_zoo=time_chla;
time_phyto=time_chla;
cycle=360;
%
% Redefine the boundary file
%
if (makebry)
  disp(' ')
  disp(' Redefine the boundary file...')
  if  ~exist('vtransform')
      vtransform=1; %Old Vtransform
      disp([' NO VTRANSFORM parameter found'])
      disp([' USE TRANSFORM default value vtransform = 1'])
  end
disp('')
  disp('======================================================== ')
  disp('=> You need the croco_bry_Z.nc file created by make_bry.m ')
  disp('======================================================== ')

  add_bry_bioebus(bryname,obc,time_no3,time_o2,time_zoo,time_phyto,time_chla,cycle,'write');
  
end
%
% Redefine the boundary file in Z-coordinates
%
if (makeZbry)
  disp(' ')
  disp(' Redefine the boundary Z-file...')
%
% get Z
%
    nc=netcdf(no3_ann_data,'r');
  Z=nc{'Z'}(:);
  kmax=max(find(Z<hmax))-1;
  Z=Z(1:kmax);
  close(nc)
  add_bry_bioebus_Z(Zbryname,obc,Z,time_no3,time_o2,time_zoo,time_phyto,time_chla,cycle,'write');
  disp(' ')
  disp(' Horizontal extrapolations')
%
% Loop on the lateral boundaries 
%
  for obcndx=1:4
    if obc(obcndx)==1
      if obcndx==1
        disp(' Processing southern boundary...')
		disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
	suffix='_south';
      elseif obcndx==2
        disp(' Processing eastern boundary...')
		disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
	suffix='_east';
      elseif obcndx==3
        disp(' Processing northern boundary...')
		disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
	suffix='_north';
      elseif obcndx==4
        disp(' Processing western boundary...')
		disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
	suffix='_west';
	  end
      %
	  disp('============================================')
	  disp('  Nitrate...')
      disp(' ')
	  cff=1;
      bry_interp_bgc(Zbryname,lon,lat,no3_seas_data,no3_ann_data,...
               'nitrate',['NO3',suffix],obcndx,Roa);            
      %
      disp('============================================')
	  disp('  Oxygen...')
      disp(' ')
	  cff=1;
      bry_interp_bgc(Zbryname,lon,lat,o2_seas_data,o2_ann_data,...
               'oxygen',['O2',suffix],obcndx,Roa);        
      %
	  disp('============================================')
	  disp('  Chlorophylle...(computed from Chla data)')
      disp(' ')
	  cff=1;
	  bry_interp_bgc_chloro(bryname,grdname,bryname,lon,lat,chla_seas_data,chla_ann_data,...
		'Chlorophylle',['CHLA',suffix],obcndx,cff,Roa);
      %
	  disp('============================================')
	  disp('  Small Phytoplankton...(computed from Chla data)')
      disp(' ')
	  cff=0.1;       
	  bry_interp_bgc_chloro(bryname,grdname,bryname,lon,lat,chla_seas_data,chla_ann_data,...
               'Phytoplancton,',['SPHYTO',suffix],obcndx,cff,Roa);        
      %
	  disp('============================================')
	  disp('  Large Phytoplankton...(computed from Chla data)')
      disp(' ')
	  cff=0.4;       
	  bry_interp_bgc_chloro(bryname,grdname,bryname,lon,lat,chla_seas_data,chla_ann_data,...
               'Phytoplancton,',['LPHYTO',suffix],obcndx,cff,Roa);        
      %
	  disp('============================================')
      disp('  Small Zooplankton...(computed from Chla data)')
      disp(' ')
	  cff=0.2;     
	  bry_interp_bgc_chloro(bryname,grdname,bryname,lon,lat,chla_seas_data,chla_ann_data,...
               'Zooplankton',['SZOO',suffix],obcndx,cff,Roa);   
      %
	  disp('============================================')
      disp('  Large Zooplankton...(computed from Chla data)')
      disp(' ')
	  cff=0.3;     
	  bry_interp_bgc_chloro(bryname,grdname,bryname,lon,lat,chla_seas_data,chla_ann_data,...
               'Zooplankton',['LZOO',suffix],obcndx,cff,Roa);     
    end
  end
end
%
% Vertical interpolations 
%
if (makebry)
  disp(' ')
  disp(' Vertical interpolations')
%
% Loop on the lateral boundaries 
%
  for obcndx=1:4
    if obc(obcndx)==1
      if obcndx==1
        disp(' Processing southern boundary...')
	suffix='_south';
      elseif obcndx==2
        disp(' Processing eastern boundary...')
	suffix='_east';
      elseif obcndx==3
        disp(' Processing northern boundary...')
	suffix='_north';
      elseif obcndx==4
        disp(' Processing western boundary...')
	suffix='_west';
      end
      disp(' ')
      disp('  Nitrate...')
      vinterp_bry_bgc(bryname,grdname,Zbryname,'no3_time',['NO3',suffix],obcndx);
      disp('=====')
      disp('  Oxygen...')
       vinterp_bry_bgc(bryname,grdname,Zbryname,'o2_time',['O2',suffix],obcndx);
    end
  end
end
%
% Make a few plots
%
if makeplot==1
disp(' ')
disp(' Make a few plots...')
test_bry(bryname,grdname,'NO3',1,obc)
figure
test_bry(bryname,grdname,'O2',1,obc)
figure
test_bry(bryname,grdname,'CHLA',1,obc)
figure
test_bry(bryname,grdname,'SPHYTO',1,obc)
figure
test_bry(bryname,grdname,'LPHYTO',1,obc)
figure
test_bry(bryname,grdname,'SZOO',1,obc)
figure
test_bry(bryname,grdname,'LZOO',1,obc)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
