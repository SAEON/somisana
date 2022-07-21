%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO boundary file
%
%  Extrapole and interpole temperature and salinity from a
%  climatology to get boundary conditions for
%  CROCO (boundary netcdf file) .
%  Get the velocities and sea surface elevation via a 
%  geostrophic computation.
%
%  Data input format (netcdf):
%     temperature(T, Z, Y, X)
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
%  Data climatologies file names:
%
%    temp_month_data : monthly temperature climatology
%    temp_ann_data   : annual temperature climatology
%    salt_month_data : monthly salinity climatology
%    salt_ann_data   : annual salinity climatology
%
temp_month_data=[climato_dir,'temp_month.cdf']
temp_ann_data=[climato_dir,'temp_ann.cdf']
salt_month_data=[climato_dir,'salt_month.cdf']
salt_ann_data=[climato_dir,'salt_ann.cdf']
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%

%
% Title
%
disp(' ')
disp([' Making the file: ',bryname])
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



%----------------------------------------------------------------------------
% Create the boundary file
%----------------------------------------------------------------------------
if (makebry)
    disp(' ')
    disp(' Create the boundary file...')
    if  ~exist('vtransform')
        vtransform=1; %Old Vtransform
        disp([' NO VTRANSFORM parameter found'])
        disp([' USE TRANSFORM default value vtransform = 1'])
    end
  create_bryfile(bryname,grdname,CROCO_title,obc,...
                 theta_s,theta_b,hc,N,...
                 woa_time,woa_cycle,'clobber',vtransform);
end

%
% Create the boundary file in Z-coordinates
%
if (makeZbry)
  disp(' ')
  disp(' Create the boundary Z-file...')
%
% get Z
%
    nc=netcdf(temp_ann_data,'r');
  Z=nc{'Z'}(:);
  kmax=max(find(Z<hmax))-1;
  Z=Z(1:kmax);
  close(nc)
  create_bry_Z(Zbryname,grdname,CROCO_title,obc,...
                Z,woa_time,woa_cycle,'clobber');
  disp(' ')
  disp(' Horizontal extrapolations')
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
      disp('  Temperature...')
      bry_interp(Zbryname,lon,lat,temp_month_data,temp_ann_data,...
               'temperature',['temp',suffix],obcndx,Roa);
      disp('  Salinity...')
      bry_interp(Zbryname,lon,lat,salt_month_data,salt_ann_data,...
               'salinity',['salt',suffix],obcndx,Roa);        
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
      disp('  Temperature...')
      vinterp_bry(bryname,grdname,Zbryname,['temp',suffix],obcndx);
      disp(' ')
      disp('  Salinity...')
      vinterp_bry(bryname,grdname,Zbryname,['salt',suffix],obcndx);
      if (insitu2pot)
        disp(' ')
        disp('  Compute potential temperature from in-situ...')
        getpot_bry(bryname,grdname,obcndx)
      end

%
% Geostrophy
%
      disp(' ')
      disp('  Compute geostrophic currents')
      geost_currents_bry(bryname,grdname,Zbryname,frcname,zref,obcndx)
    end
  end

%
% Remove avg SSH
%
  rmavgssh(bryname,grdname,obc)

end



%----------------------------------------------------------------------------
% Make a few plots
%----------------------------------------------------------------------------
if makeplot==1
  disp(' ')
  disp(' Make a few plots...')
  test_bry(bryname,grdname,'temp',1,obc)
  figure
  test_bry(bryname,grdname,'salt',1,obc)
  figure
  test_bry(bryname,grdname,'u',1,obc)
  figure
  test_bry(bryname,grdname,'v',1,obc)
  figure
  test_bry(bryname,grdname,'temp',6,obc)
  figure
  test_bry(bryname,grdname,'salt',6,obc)
  figure
  test_bry(bryname,grdname,'u',6,obc)
  figure
  test_bry(bryname,grdname,'v',6,obc)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
