%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO climatology file
%
%  Extrapole and interpole temperature and salinity from a
%  Climatology to get boundary and initial conditions for
%  CROCO (climatology and initial netcdf files) .
%  Get data from ORCA 05 climatology
%
%  Data input format (netcdf):
%     temperature(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : ORCA 05 Lionel Gourdeau 2005
%
%  Lefevre Jerome, IRD, 2005.
%
%  Version of 10-AUG-2005
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
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
%grdname='croco_fd_plat_3000m_grd.nc';
grdname='croco_grd.nc';
clmname='croco_clm_r05.nc';
ininame='croco_ini_r05.nc';
oaname ='croco_oa_r05.nc';

%
%  Vertical grid parameters
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!   THESE MUST IDENTICAL IN THE .IN FILE   !!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
theta_s=6.;
theta_b=0.;
hc=5;
N=30; % number of vertical levels (rho)
%
%  Open boundaries switches
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!   MUST BE CONFORM TO THE CPP SWITCHES    !!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
obc=[1 0 1 1]; % open boundaries (1=open , [S E N W])
%
%  Day of initialisationbarotropic_currents
%
tini=15;  
%
% Set times and cycles: monthly climatology for all data
%
time=[15:30:345];    % time 
cycle=365;           % cycle
%
%  Data climatology file name:
%
Dir_Data='/export/serveraid_vol0/CROCO_HOME/croco_tools/DATA_PACIFIC/ORCA05_clim/'
datafile=[Dir_Data,'ORCA05_monthly_clim.cdf'];
%
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
  disp(' Create the climatology file.barotropic_currents..')
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
    nc=netcdf(datafile,'r');
  Z=nc{'Z'}(:);
  close(nc)
  create_oafile(oaname,grdname,title,Z,...
                time,cycle,'clobber');
%
% Horizontal extrapolations 
%
  disp(' ')
  disp(' Horizontal interpolations')
  disp(' ')
  disp(' Temperature...')
  int_data_orca(oaname,datafile,'temp','lon_rho','lat_rho','TEMP','lonT','latT',1);
  disp(' ')
  disp(' Salinity...')
  int_data_orca(oaname,datafile,'salt','lon_rho','lat_rho','SALT','lonT','latT',1);
  disp(' ')
  disp(' U...')
  int_data_orca(oaname,datafile,'u','lon_u','lat_u','U','lonU','latT',1);
  disp(' ')
  disp(' V...')
  int_data_orca(oaname,datafile,'v','lon_v','lat_v','V','lonT','latV',1);
  disp(' ')
  disp(' ZETA...')
  int_data_orca(oaname,datafile,'zeta','lon_rho','lat_rho','SSH','lonT','latT',0);
  
  ncoa=netcdf(oaname,'write');
  ncoa{'ssh'}(:,:,:)=ncoa{'zeta'}(:,:,:);
  close(ncoa)
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
  disp(' ')
  disp(' ZETA...')
  rem_avg_zeta(clmname,grdname,oaname)
  disp(' ')
  disp(' UBAR & VBAR...')
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
  ncini=netcdf(ininame,'write');
ncclm=netcdf(clmname,'r');		 
		 
  tindex=find(time==tini)
  if isempty(tindex),
    disp('Error : Indice for tini is not found, chek')		 ;
  end  
  disp(' ')
  disp(' Temperature...')
  ncini{'temp'}(1,:,:,:)=ncclm{'temp'}(tindex,:,:,:);
  disp(' ')
  disp(' Salinity ...')
  ncini{'salt'}(1,:,:,:)=ncclm{'salt'}(tindex,:,:,:);
  disp(' ')
  disp(' U ...')
  ncini{'u'}(1,:,:,:)=ncclm{'u'}(tindex,:,:,:);
  disp(' ')
  disp(' V ...')
  ncini{'v'}(1,:,:,:)=ncclm{'v'}(tindex,:,:,:);  
  disp(' ')
  disp(' UBAR & VBAR...')  
  ncini{'ubar'}(1,:,:)=ncclm{'ubar'}(tindex,:,:);    
  ncini{'vbar'}(1,:,:)=ncclm{'vbar'}(tindex,:,:);
   ncini{'vbar'}(1,5,5)  
  disp(' ')
  disp(' ZETA...')      
  ncini{'zeta'}(1,:,:)=ncclm{'zeta'}(tindex,:,:);  
   ncini{'zeta'}(1,5,5) 
  close(ncini);
  close(ncclm);
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
