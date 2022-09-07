%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the statistics of eddies for each year.
%
%  For the cyclones
%
%	N_CYCL		: Number of eddies
%	AREA_CYCL	: Mean area
%	RAD_CYCL	: Mean radius
%	SPD_CYCL	: Mean propagation speed
%	E_CYCL		: Mean energy
%	XI_CYCL		: Mean vorticity
%	A_CYCL		: Mean amplitude
%	U_CYCL		: Mean U-velocity
%	V_CYCL		: Mean V-velocity
%
%  Same thing for the anticyclones
%
%	N_ACYCL
%	AREA_ACYCL
%	RAD_ACYCL
%	SPD_ACYCL
%	E_ACYCL
%	XI_ACYCL
%	A_ACYCL
%	U_ACYCL
%	V_ACYCL
%
%  Same thing for all the eddies
%
%	N_TOT
%	AREA_TOT
%	RAD_TOT
%	SPD_TOT
%	E_TOT
%	XI_TOT
%	A_TOT
%	U_TOT
%	V_TOT
%
%  The statistics are made in an Lagrangian approach:
%  each individual eddy is counted only once (even if it has 
%  a long duration).
%
%  Pierrick Penven, IRD, 2011.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
clear all
close all 
%
% Domain limits
%
lonmin =   8;   % Minimum longitude [degree east]
lonmax =  22;   % Maximum longitude [degree east]
latmin = -38;   % Minimum latitudeF  [degree north]
latmax = -26;   % Maximum latitude  [degree north]
%
% First year to process
%
year_start=2014;
%year_start=10;
%
% Last year to process
%
year_end=2014;
%year_end=10;
%
% Dates are defined as days since Yorig/1/1 00:00
%
Yorig=1900;
%Yorig=NaN;
%
eddyfile='eddies_aviso_2014_2014_select.nc';
%eddyfile='eddies_croco_10_10_select.nc';
statsfile='eddies_stats_lagran_aviso_2014_2014.mat';
%statsfile='eddies_stats_lagran_croco_10_10.mat';
%
% Eddies minimum life duration [days] 
% (to filter eddies out which have a too short duration)
%
eddy_life=7; % days
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Years
%
Y=[year_start:year_end];
Nyears=length(Y)
yndx=1:Nyears;
%
% Check the number of eddy files
%
nc=netcdf(eddyfile);
disp('Read Ids...')
ID_all=nc{'ID'}(:);
disp('Read time...')
time_all=nc{'time'}(:);
disp('Read lon...')
lon_all=nc{'lon'}(:);
disp('Read lat...')
lat_all=nc{'lat'}(:);
disp('Read Area...')
Area_all=nc{'Area'}(:);
disp('Read Ener...')
Ener_all=nc{'Energy'}(:);
disp('Read Vort...')
Vort_all=nc{'Vorticity'}(:);
disp('Read Radius...')
Radius_all=nc{'Radius'}(:);
disp('Read Ampl...')
Ampl_all=nc{'Amplitude'}(:);
disp('Read U...')
U_all=nc{'U'}(:);
disp('Read V...')
V_all=nc{'V'}(:);
close(nc)
%
% Loop on the eddies
%
ngood=0*yndx;
AREA_CYCL=ngood;
AREA_ACYCL=ngood;
AREA_TOT=ngood;
RAD_CYCL=ngood;
RAD_ACYCL=ngood;
RAD_TOT=ngood;
SPD_CYCL=ngood;
SPD_ACYCL=ngood;
SPD_TOT=ngood;
E_CYCL=ngood;
E_ACYCL=ngood;
E_TOT=ngood;
A_CYCL=ngood;
A_ACYCL=ngood;
A_TOT=ngood;
XI_CYCL=ngood;
XI_ACYCL=ngood;
XI_TOT=ngood;
N_CYCL=ngood;
N_ACYCL=ngood;
N_TOT=ngood;
U_CYCL=ngood;
U_ACYCL=ngood;
U_TOT=ngood;
V_CYCL=ngood;
V_ACYCL=ngood;
V_TOT=ngood;
%

for i=1:max(ID_all)
%
  indx=find(ID_all==i);
%
% Read all the eddy properties
% 
  teddy=time_all(indx);
  lon_eddy=lon_all(indx);
  lat_eddy=lat_all(indx);
  Area_eddy=Area_all(indx);
  EKE_eddy=Ener_all(indx);
  Vort_eddy=Vort_all(indx);
  Radius_eddy=Radius_all(indx);
  Ampl_eddy=Ampl_all(indx);
  U_eddy=U_all(indx);
  V_eddy=V_all(indx);
%
  EKE_eddy(EKE_eddy==NaN)=0;
  EKE_eddy=EKE_eddy./Area_eddy;
  SPD_eddy=sqrt(U_eddy.^2+V_eddy.^2);
  duration=teddy(end)-teddy(1);
%
% Find out the part which is inside the domain
%  
  inarea=(lon_eddy>=lonmin & lon_eddy<=lonmax &...
          lat_eddy>=latmin & lat_eddy<=latmax);
%
% Select the eddies which where in the domain and
% which lived long enough
%  
  if (duration>=eddy_life & max(inarea)>=1)
%
    time_eddy=mean(teddy(inarea==1));
    if isfinite(Yorig)
      [y_eddy m_eddy d_eddy h_eddy min_eddy sec_eddy]=...
                    datevec(time_eddy+datenum(Yorig,1,1));
    else
      y_eddy=floor(1+time_eddy/360);
    end

%
    tndx=find(Y==y_eddy);
    ngood(tndx)=ngood(tndx)+1;
%
% Get the mean properties of the eddies when they are in the domain
%  
    AREA=mean(Area_eddy(inarea==1));
    RADIUS=mean(Radius_eddy(inarea==1));
    EKE=mean(EKE_eddy(inarea==1));
    XI=mean(Vort_eddy(inarea==1));
    AMP=mean(Ampl_eddy(inarea==1));
    SPD=mean(SPD_eddy(inarea==1));
    U=mean(U_eddy(inarea==1));
    V=mean(V_eddy(inarea==1));
%
    HEMISPHERE=sign(mean(lat_eddy(inarea==1)));
    ISCYCL=(sign(XI)==sign(HEMISPHERE));
%
    if ISCYCL==1
      AREA_CYCL(tndx)=AREA_CYCL(tndx)+AREA;
      RAD_CYCL(tndx)=RAD_CYCL(tndx)+RADIUS;
      SPD_CYCL(tndx)=SPD_CYCL(tndx)+SPD;
      E_CYCL(tndx)=E_CYCL(tndx)+EKE;
      XI_CYCL(tndx)=XI_CYCL(tndx)+XI;
      A_CYCL(tndx)=A_CYCL(tndx)+AMP;
      U_CYCL(tndx)=U_CYCL(tndx)+U;
      V_CYCL(tndx)=V_CYCL(tndx)+V;
      N_CYCL(tndx)=N_CYCL(tndx)+1;      
    else
      AREA_ACYCL(tndx)=AREA_ACYCL(tndx)+AREA;
      RAD_ACYCL(tndx)=RAD_ACYCL(tndx)+RADIUS;
      SPD_ACYCL(tndx)=SPD_ACYCL(tndx)+SPD;
      E_ACYCL(tndx)=E_ACYCL(tndx)+EKE;
      XI_ACYCL(tndx)=XI_ACYCL(tndx)+XI;
      A_ACYCL(tndx)=A_ACYCL(tndx)+AMP;
      U_ACYCL(tndx)=U_ACYCL(tndx)+U;
      V_ACYCL(tndx)=V_ACYCL(tndx)+V;
      N_ACYCL(tndx)=N_ACYCL(tndx)+1;   
    end

    AREA_TOT(tndx)=AREA_TOT(tndx)+AREA;
    RAD_TOT(tndx)=RAD_TOT(tndx)+RADIUS;
    SPD_TOT(tndx)=SPD_TOT(tndx)+SPD;
    E_TOT(tndx)=E_TOT(tndx)+EKE;
    XI_TOT(tndx)=XI_TOT(tndx)+XI;
    A_TOT(tndx)=A_TOT(tndx)+AMP;
    U_TOT(tndx)=U_TOT(tndx)+U;
    V_TOT(tndx)=V_TOT(tndx)+V;
    N_TOT(tndx)=N_TOT(tndx)+1;   
  end
end
%
AREA_CYCL=AREA_CYCL./N_CYCL;
RAD_CYCL=RAD_CYCL./N_CYCL;
SPD_CYCL=SPD_CYCL./N_CYCL;
E_CYCL=E_CYCL./N_CYCL;
XI_CYCL=XI_CYCL./N_CYCL;
A_CYCL=A_CYCL./N_CYCL;
U_CYCL=U_CYCL./N_CYCL;
V_CYCL=V_CYCL./N_CYCL;

AREA_ACYCL=AREA_ACYCL./N_ACYCL;
RAD_ACYCL=RAD_ACYCL./N_ACYCL;
SPD_ACYCL=SPD_ACYCL./N_ACYCL;
E_ACYCL=E_ACYCL./N_ACYCL;
XI_ACYCL=XI_ACYCL./N_ACYCL;
A_ACYCL=A_ACYCL./N_ACYCL;
U_ACYCL=U_ACYCL./N_ACYCL;
V_ACYCL=V_ACYCL./N_ACYCL;

AREA_TOT=AREA_TOT./N_TOT;
RAD_TOT=RAD_TOT./N_TOT;
SPD_TOT=SPD_TOT./N_TOT;
E_TOT=E_TOT./N_TOT;
XI_TOT=XI_TOT./N_TOT;
A_TOT=A_TOT./N_TOT;
U_TOT=U_TOT./N_TOT;
V_TOT=V_TOT./N_TOT;

save([statsfile],'Y','AREA_CYCL','RAD_CYCL','SPD_CYCL',...
     'E_CYCL','XI_CYCL','A_CYCL','U_CYCL','V_CYCL','AREA_ACYCL',...
     'RAD_ACYCL','SPD_ACYCL','E_ACYCL','XI_ACYCL','A_ACYCL',...
     'U_ACYCL','V_ACYCL','AREA_TOT','RAD_TOT','SPD_TOT',...
     'E_TOT','XI_TOT','A_TOT','U_TOT','V_TOT',...
     'N_TOT','N_CYCL','N_ACYCL',...
     'lonmin','lonmax','latmin','latmax')













