%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%  Pierrick Penven, IRD, 2005.                                    %
%  Olivier Aumont the master, IRD, 2006.                          %
%  Patricio Marchesiello, chief, IRD, 2007.                       %
%  Christophe Eugene Raoul Menkes, the slave, IRD, 2007.          %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  WARNING !!!!!! THIS ASSUMES THAT THE TIME FOR PISCES INITIAL.
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
% Set times and cycles: monthly climatology for all data
%
time=woa_time;             % time 
cycle=woa_cycle;           % cycle 
%
%  Data climatologies file names:
%
%
no3_seas_data  = [woapisces_dir,'no3_seas.cdf'];
no3_ann_data   = [woapisces_dir,'no3_ann.cdf'];
po4_seas_data  = [woapisces_dir,'po4_seas.cdf'];
po4_ann_data   = [woapisces_dir,'po4_ann.cdf'];
o2_seas_data   = [woapisces_dir,'o2_seas.cdf'];
o2_ann_data    = [woapisces_dir,'o2_ann.cdf'];
sio3_seas_data = [woapisces_dir,'sio3_seas.cdf'];
sio3_ann_data  = [woapisces_dir,'sio3_ann.cdf'];
dic_seas_data  = [woapisces_dir,'dic_seas.cdf'];
dic_ann_data   = [woapisces_dir,'dic_ann.cdf'];
talk_seas_data = [woapisces_dir,'talk_seas.cdf'];
talk_ann_data  = [woapisces_dir,'talk_ann.cdf'];
doc_seas_data  = [woapisces_dir,'doc_seas.cdf'];
doc_ann_data   = [woapisces_dir,'doc_ann.cdf'];
fer_seas_data  = [woapisces_dir,'fer_seas.cdf'];
fer_ann_data   = [woapisces_dir,'fer_ann.cdf'];
dust_seas_data = [woapisces_dir,'dust_seas.cdf'];
dust_ann_data  = [woapisces_dir,'dust_ann.cdf'];
if strcmp(climato_dir,cars2009_dir);
    err_msg=sprintf(['Error : you need to use woadir when creating the croco_oa.nc (Z) \n'...
                     'file to be compatible with PISCES'])
    error(err_msg)
end
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp([' Making the file: ',bryname])
disp([' Adding the PISCES variables'])
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
%
% Redefine the boundary file
%
if (makebry)
  disp(' ')
  disp(' Redefine the boundary file...')
  disp('')
  disp('======================================================== ')
  disp('=> You need the croco_bry_Z.nc file created by make_bry.m ')
  disp('======================================================== ')
  add_bry_pisces(bryname,obc,time,cycle,'write');
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
  add_bry_pisces_Z(Zbryname,obc,Z,time,cycle,'write');
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
      disp('  Nitrate...')
      bry_interp_pisces(Zbryname,lon,lat,no3_seas_data,no3_ann_data,...
               'nitrate',['NO3',suffix],obcndx,Roa);        
      disp('  Phosphate...')
      bry_interp_pisces(Zbryname,lon,lat,po4_seas_data,po4_ann_data,...
               'phosphate',['PO4',suffix],obcndx,Roa);        
      disp('  Silicate...')
      bry_interp_pisces(Zbryname,lon,lat,sio3_seas_data,sio3_ann_data,...
               'silicate',['Si',suffix],obcndx,Roa);        
      disp('  Oxygen...')
      bry_interp_pisces(Zbryname,lon,lat,o2_seas_data,o2_ann_data,...
               'oxygen',['O2',suffix],obcndx,Roa);        
      disp('  Dissolved Inorganic Carbon...')
      bry_interp_pisces(Zbryname,lon,lat,dic_seas_data,dic_ann_data,...
               'dic',['DIC',suffix],obcndx,Roa);        
      disp('  Total Alkalinity...')
      bry_interp_pisces(Zbryname,lon,lat,talk_seas_data,talk_ann_data,...
               'talk',['TALK',suffix],obcndx,Roa);        
      disp('  Dissolved Organic Carbon...')
      bry_interp_pisces(Zbryname,lon,lat,doc_seas_data,doc_ann_data,...
               'doc',['DOC',suffix],obcndx,Roa);        
      disp('  Iron...')
      bry_interp_pisces(Zbryname,lon,lat,fer_seas_data,fer_ann_data,...
               'fer',['FER',suffix],obcndx,Roa);        
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
      vinterp_bry(bryname,grdname,Zbryname,['NO3',suffix],obcndx);
      disp(' ')
      disp('  Phosphate...')
      vinterp_bry(bryname,grdname,Zbryname,['PO4',suffix],obcndx);
      disp(' ')
      disp('  Silica...')
      vinterp_bry(bryname,grdname,Zbryname,['Si',suffix],obcndx);
      disp(' ')
      disp('  Oxygen ...')
      vinterp_bry(bryname,grdname,Zbryname,['O2',suffix],obcndx);
      disp(' ')
      disp('  Dissolved Inorganic Carbon...')
      vinterp_bry(bryname,grdname,Zbryname,['DIC',suffix],obcndx);
      disp(' ')
      disp('  Total Alkalinity...')
      vinterp_bry(bryname,grdname,Zbryname,['TALK',suffix],obcndx);
      disp(' ')
      disp('  Dissolved Organic Carbon...')
      vinterp_bry(bryname,grdname,Zbryname,['DOC',suffix],obcndx);
      disp(' ')
      disp('  Iron...')
      vinterp_bry(bryname,grdname,Zbryname,['FER',suffix],obcndx);
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
test_bry(bryname,grdname,'PO4',1,obc)
figure
test_bry(bryname,grdname,'Si',1,obc)
figure
test_bry(bryname,grdname,'O2',1,obc)
figure
test_bry(bryname,grdname,'DIC',6,obc)
figure
test_bry(bryname,grdname,'TALK',6,obc)
figure
test_bry(bryname,grdname,'DOC',6,obc)
figure
test_bry(bryname,grdname,'FER',6,obc)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
