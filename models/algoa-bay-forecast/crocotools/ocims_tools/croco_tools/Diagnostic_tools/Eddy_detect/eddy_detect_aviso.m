%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Detect surface geostrophic eddies in AVISO absolute altimetry
%
%  Store the eddies properties into a netcdf file
%
%  The tracking should be done after to give an ID to each eddy
%  using tracking_eddies.m
%
%  Pierrick Penven, IRD, 2011.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
clear all
close all
%
% First date to process
%
%day_start=01;
%month_start=01;
%year_start=1993;
day_start=20;
month_start=12;
year_start=2014;
%
% Last date to process
%
day_end=27;
month_end=12;
year_end=2014;
%
% Dates are defined as days since Yorig/1/1 00:00
%
Yorig=1900;
%
% Number of days between AVISO frames
% 
dt=1; 
%
% Domain limits 
%
lonmin =   8;   % Minimum longitude [degree east]
lonmax =  22;   % Maximum longitude [degree east]
latmin = -38;   % Minimum latitudeF  [degree north]
latmax = -26;   % Maximum latitude  [degree north]
%
%
% Eddy detection parameters
%
%
dzeta=0.02;   % Interval [m] between the contours 
              % (should be around the precision of altimetry (~2cm ?))
%
Rmax=300;     % Maximum radius [km] of a close curved detected 
              % (to prevent taking an ocean gyre as a giant eddy)
	      % (should be larger than the largest mesoscale eddies: 300-400 km?)
%
Omin=-2e-12;  % Threshold for Okubo-Weiss parameter detection [s-2]
Omin=0;       % (Chelton (2007) used -2e12 , but here it work also with 0 !...)
%
Nhanning=2;   % Number of Hanning filter pass on the Okubo-Weiss parameter
              % (1 or 2 passes might help a bit still...)
%
% AVISO absolute dynamic topography directory and names
%
%
AVISO_DIR='../AVISO/MADT_RENAME';
AVISO_TYPE='madt';
%
alti_prefix=[AVISO_DIR,'/',AVISO_TYPE,'_'];
alti_suffix='.nc';
%
% Topography file to disregard altimetry data on the shelves (i.e. h<hmin)
%
usetopo=0; % option: 1 to use the topo (a topography file should be provided)
hmin=50;
%
TOPODIR = '../Topo/';
topofile = [TOPODIR,'etopo2.nc'];
% 
% Eddies file name
%
netcdf_eddyfile=['eddies_aviso_',num2str(year_start),...
                 '_',num2str(year_end),'.nc'];
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Create the eddy directory
%
nc=create_eddynetcdf(netcdf_eddyfile);
%
tstart=nearest_aviso_date(day_start,month_start,year_start,Yorig);
tend=nearest_aviso_date(day_end,month_end,year_end,Yorig);
%
% Get the grid
%
strdate=datestr(tstart+datenum(Yorig,1,1),26);
date=strdate([1 2 3 4 6 7 9 10]);
fname_madt =[alti_prefix,date,alti_suffix];
[lon,lat,zeta]=get_topex2014(lonmin,lonmax,latmin,latmax,fname_madt);
[lon,lat,f,pm,pn]=get_tpx_grid(lon,lat);
[dx,dy]=get_dx(lon,lat);
mask=isfinite(zeta);
%
% Get the bottom topography to remove coastal values
%
if usetopo==1
  h=interp_topo(lon,lat,dx,dy,toponame);
  h(mask==0)=0;
  mask(h<=hmin)=0;
end
%
% Main loop on time (and files)
%
indx=1;
for t=tstart:dt:tend
%
  strdate=datestr(t+datenum(Yorig,1,1),26);
  date=strdate([1 2 3 4 6 7 9 10]);
  disp(' ')
  disp(['Processing date ',strdate])
%
% Get the Aviso SSH
%
  fname_madt =[alti_prefix,date,alti_suffix];
  [lon0,lat0,zeta]=get_topex2014(lonmin,lonmax,latmin,latmax,fname_madt);
%
% Detect the eddies 
%
  [neddies,elon,elat,AREA,EKE,XI,RADIUS,...
   MAXZ,MINZ,MEANZ,AMP,Ueddy,Leddy]=...
   get_eddies_mixed(lon,lat,zeta,f,pm,pn,mask,...
		    dzeta,Rmax,Omin,Nhanning);
%
% Write in the eddy file
%
  for i=1:neddies
    indx=write_eddynetcdf(nc,indx,0,t,elon(i),elat(i),...
                          AREA(i),EKE(i),XI(i),RADIUS(i),...
                          MAXZ(i),MINZ(i),MEANZ(i),AMP(i),...
                          Ueddy(i),Leddy(i),0,0);
  end
%
% End of time loop
%
end
%
close(nc)
%
return
