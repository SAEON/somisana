%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO climatology file
%
%  Extrapole and interpole temperature and salinity from a
%  Climatology to get boundary and initial conditions for
%  CROCO (climatology and initial netcdf files) .
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
%  Data source : IRI/LDEO Climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA98/
%
%  Pierrick Penven, IRD, 2002.
%
%  Version of 10-Oct-2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
%  Title 
%
title='Climatology';
%
%  Switches for selecting what to process (1=ON)
%
makeclim=1; %1: process boundary data
makeoa=1;   %1: process oa data
makeini=1;  %1: process initial data
%
%  Grid file name - Climatology file name
%  Initial file name - OA file name
%
grdname='croco_grd.nc';
clmname='croco_clm.nc';
ininame='croco_ini.nc';
oaname ='croco_oa.nc';
%
%  Day of initialisation
%
tini=15;
%
% Set times and cycles: monthly climatology for all data
%
time=[15:30:345];    % time
cycle=360;           % cycle
%
%  Data climatologies file names:
%
%    monthtemp : monthly temperature climatology
%    monthsalt : monthly salinity climatology
%
monthtemp='../croco_Pacifico/croco_pacific_temp.nc';
monthsalt='../croco_Pacifico/croco_pacific_salt.nc';
monthu='../croco_Pacifico/croco_pacific_u.nc';
monthv='../croco_Pacifico/croco_pacific_v.nc';
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp([' Making the clim: ',clmname])
disp(' ')
disp([' Title: ',title])
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
nc=netcdf(grdname,'r');
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
hmax=max(max(nc{'h'}(:)));
close(nc);
%
% Create the climatology file
%
if (makeclim)
  disp(' ')
  disp(' Create the climatology file...')
  create_climfile(clmname,grdname,title,...
                  theta_s,theta_b,hc,N,...
                  time,cycle,'clobber');
end
%
% Create the OA file
%
if (makeoa)
  disp(' ')
  disp(' Create the OA file...')
    nc=netcdf(monthtemp,'r');
  Z=nc{'DEPTH'}(1:30);
  close(nc)
  create_oafile(oaname,grdname,title,Z,...
                time,cycle,'clobber');
%
% Horizontal extrapolations 
%
  disp(' ')
  disp(' Horizontal extrapolations')
  disp(' ')
  disp(' Temperature...')
  ext_crocopacific(oaname,monthtemp,'TEMP','temp','tclm_time','r');
  disp(' ')
  disp(' Salinity...')
  ext_crocopacific(oaname,monthsalt,'SALT','salt','sclm_time','r');
  disp(' ')
  disp(' U...')
  ext_crocopacific(oaname,monthu,'U','u','uclm_time','u');
  disp(' ')
  disp(' V...')
  ext_crocopacific(oaname,monthv,'V','v','vclm_time','v');
end
%
% Vertical interpolations 
%
if (makeclim)
  disp(' ')
  disp(' Vertical interpolations')
  disp(' ')
  disp(' Temperature...')
  vinterp_clm(clmname,grdname,oaname,'temp','tclm_time','Z',0,'r');
  disp(' ')
  disp(' Salinity...')
  vinterp_clm(clmname,grdname,oaname,'salt','sclm_time','Z',0,'r');
  disp(' ')
  disp(' U...')
  vinterp_clm(clmname,grdname,oaname,'u','uclm_time','Z',0,'u');
  disp(' ')
  disp(' V...')
  vinterp_clm(clmname,grdname,oaname,'v','vclm_time','Z',0,'v');
%
% Compute barotropic currents
%
  disp(' ')
  disp(' Compute barotropic currents')
  barotropic_currents(clmname,grdname,obc)
end
%
% Initial file
%
if (makeini)
  disp(' ')
  disp(' Initial')
  create_inifile(ininame,grdname,title,...
                 theta_s,theta_b,hc,N,...
                 tini,'clobber');
  disp(' ')
  disp(' Temperature...')
  vinterp_clm(ininame,grdname,oaname,'temp','tclm_time','Z',tini,'r',1);
  disp(' ')
  disp(' Salinity...')
  vinterp_clm(ininame,grdname,oaname,'salt','sclm_time','Z',tini,'r',1);
end		 
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
test_clim(clmname,grdname,'temp',1)
figure
test_clim(clmname,grdname,'salt',1)
figure
test_clim(clmname,grdname,'temp',6)
figure
test_clim(clmname,grdname,'salt',6)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
