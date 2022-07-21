%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO initial file from Levitus Data
%
%  Extrapole and interpole temperature and salinity from a
%  Climatology to get initial conditions for
%  CROCO (initial netcdf files) .
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
%  P. Marchesiello & P. Penven - IRD 2005
%
%  Version of 21-Sep-2005
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title 
%
title='Climatology';
%
% Common parameters
%
crocotools_param

%  Data climatologies file names:
%
%    temp_month_data : monthly temperature climatology
%    temp_ann_data   : annual temperature climatology
%    salt_month_data : monthly salinity climatology
%    salt_ann_data   : annual salinity climatology
%
temp_month_data  = [climato_dir,'temp_month.cdf'];
temp_ann_data    = [climato_dir,'temp_ann.cdf'];
insitu2pot       = 1;   %1: transform in-situ temperature to potential temperature
salt_month_data  = [climato_dir,'salt_month.cdf'];
salt_ann_data    = [climato_dir,'salt_ann.cdf'];
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp([' Making initial file: ',ininame])
disp(' ')
disp([' Title: ',title])
%
% Initial file
%
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
create_inifile(ininame,grdname,title,...
               theta_s,theta_b,hc,N,...
               tini,'clobber',vtransform);
%
% Horizontal and vertical interp/extrapolations 
%
disp(' ')
disp(' Interpolations / extrapolations')
disp(' ')
disp(' Temperature...')
ext_tracers_ini(ininame,grdname,temp_month_data,temp_ann_data,...
            'temperature','temp','r',tini);
disp(' ')
disp(' Salinity...')
ext_tracers_ini(ininame,grdname,salt_month_data,salt_ann_data,...
             'salinity','salt','r',tini);
%
% Geostrophy
%
%  disp(' ')
%  disp(' Compute geostrophic currents')
%  geost_currents(ininame,grdname,oaname,frcname,zref,obc,0)
%
% Initial file
%
if (insitu2pot)
  disp(' ')
  disp(' Compute potential temperature from in-situ...')
  getpot(ininame,grdname)
end
if (makeplot == 1)
%
% Make a few plots
%
    disp(' ')
    disp(' Make a few plots...')
    test_clim(ininame,grdname,'temp',1,coastfileplot)
    figure
    test_clim(ininame,grdname,'salt',1,coastfileplot)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
