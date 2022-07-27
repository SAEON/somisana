%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add N2O data in input CROCO files from Global Atlas (WOA or CARS)
%
%  N2O distribution from Nevison et al. (2003) formulation
%
%  Data input format (netcdf):
%     variable(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%
%  Elodie Gutknecht, 2013
%  Gildas Cambon, 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%
%  Title 
%
crocotools_param
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%

%
%=========

if makeini
   nc=netcdf(grdname,'r');
h = nc{'h'}(:);
close(nc)
% O2 initial conditions
nc=netcdf(ininame,'r');
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N =  length(nc('s_rho'));
vtransform=nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
O2_ini   = nc{'O2'}(:);
close(nc)   
type = 'initial conditions file' ; 
history = 'CROCO' ;
[KK,LL,MM]=size(O2_ini);
%
zw_ini=zlevs(h,0.,theta_s,theta_b,Tcline,N,'w',vtransform); 
N2O_ini=zeros(KK,LL,MM);N2O_ini=NaN;
for k=1:KK
    for j=1:LL
        for i=1:MM
            N2O_ini(k,j,i)=nevis_2003(squeeze(zw_ini(k,j,i)),squeeze(O2_ini(k,j,i)));
        end
    end
end
% Find NaN
find(isnan(N2O_ini)==1);%
%
% open the ini file  
nc = netcdf(ininame,'write');
% new variable
%%redef(nc);
nc('n2o_time') = 1;
nc{'n2o_time'} = ncdouble('time') ;
nc{'N2O'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'N2O'}.long_name = ncchar('Nitrous oxide');
nc{'N2O'}.long_name = 'Nitrous oxide';
nc{'N2O'}.units = ncchar('mMol N2O m-3'); 
nc{'N2O'}.units = 'mMol N2O m-3';
nc{'N2O'}.fields = ncchar('NO2, scalar, series');
nc{'N2O'}.fields = 'NO2, scalar, series';
%%endef(nc);
% write new variable
nc{'N2O'}(:,:,:) =  N2O_ini; 
% Synchronize on disk
close(nc);
end

%==========
if makeclim
  nc=netcdf(grdname,'r');
h = nc{'h'}(:);
close(nc)
% O2 climatological conditions
nc=netcdf(clmname,'r');
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N =  length(nc('s_rho'));
vtransform=nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
O2_clm  = nc{'O2'}(:);
O2_time = nc{'o2_time'}(:);
O2_cycle = nc{'o2_time'}.cycle_length(:);
zeta = nc{'zeta'}(:);
close(nc)
[TT,KK,LL,MM]=size(O2_clm);
for itps=1:length(O2_time)
    zw_clm(itps,:,:,:)=zlevs(h,squeeze(zeta(itps,:,:)),theta_s,theta_b,Tcline,N,'w',vtransform); 
end 
N2O_clm=zeros(TT,KK,LL,MM); N2O_clm(:)=NaN;
for t=1:TT
    for k=1:KK
        for j=1:LL
            for i=1:MM
                zw= squeeze(zw_clm(t,k,j,i));
                O2=squeeze(O2_clm(t,k,j,i));
                N2O_clm(t,k,j,i)=nevis_2003(zw,02);
            end
        end
    end
end
% Find NaN
find(isnan(N2O_clm)==1);
%
% add N20 in climatological file
type = 'climatological conditions file' ; 
history = 'CROCO' ;
%
% open the clm file  
% 
nc = netcdf(clmname,'write');
%
% new variable
%
%%redef(nc);
nc('n2o_time') = TT;
nc{'n2o_time'} = ncdouble('n2o_time') ;
nc{'n2o_time'}.long_name = ncchar('time climatological N2O');
nc{'n2o_time'}.long_name = 'time climatological N2O';
nc{'n2o_time'}.units = ncchar('day');
nc{'n2o_time'}.units = 'day';
nc{'n2o_time'}.cycle_length = O2_cycle;

nc{'N2O'} = ncdouble('n2o_time','s_rho','eta_rho','xi_rho') ;
nc{'N2O'}.long_name = ncchar('Nitrous oxide');
nc{'N2O'}.long_name = 'Nitrous oxide';
nc{'N2O'}.units = ncchar('mMol N2O m-3'); 
nc{'N2O'}.units = 'mMol N2O m-3';
nc{'N2O'}.fields = ncchar('NO2, scalar, series');
nc{'N2O'}.fields = 'NO2, scalar, series';
%%endef(nc);
%
% write new variable
%
nc{'n2o_time'}(:) =  O2_time(:); 
nc{'N2O'}(:,:,:,:) = N2O_clm(:); 
%
% Synchronize on disk
%
close(nc);
end 

%==========
if makebry
% O2 boundary conditions
  nc=netcdf(grdname,'r');
h = nc{'h'}(:);
close(nc)       

nc=netcdf(bryname,'r');
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N =  length(nc('s_rho'));
vtransform=nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
O2_bry_west = nc{'O2_west'}(:);
O2_bry_east = nc{'O2_east'}(:);
O2_bry_south = nc{'O2_south'}(:);
O2_bry_north = nc{'O2_north'}(:);
O2_time = nc{'o2_time'}(:);
O2_cycle = nc{'o2_time'}.cycle_length(:);
zeta_west  = nc{'zeta_west'}(:);
zeta_east  = nc{'zeta_east'}(:);
zeta_south = nc{'zeta_south'}(:);
zeta_north = nc{'zeta_north'}(:);
close(nc)

% BRY
[TT,KK,MM]=size(O2_bry_south); [TT,KK,LL]=size(O2_bry_west);
type='w'; 
zw_bry_west  = zeros(TT,KK+1);
zw_bry_east  = zeros(TT,KK+1);
zw_bry_south = zeros(TT,KK+1);
zw_bry_north = zeros(TT,KK+1);

N2O_bry_east  = zeros(TT,KK,LL); N2O_bry_east(:)=NaN  ;
N2O_bry_west  = zeros(TT,KK,LL); N2O_bry_west(:)=NaN  ;
N2O_bry_south = zeros(TT,KK,MM); N2O_bry_south(:)=NaN ;
N2O_bry_north = zeros(TT,KK,MM); N2O_bry_north(:)=NaN ;
for t=1:TT
    for j=1:LL
        h_west  = squeeze(h(j,1));
        h_east  = squeeze(h(j,end));
        zw_bry_west(t,:,j) = zlevs_1d(h_west , squeeze(zeta_west(t,j)) , theta_s, theta_b, hc, N, type, vtransform);
        zw_bry_east(t,:,j)= zlevs_1d(h_east , squeeze(zeta_east(t,j)) , theta_s, theta_b, hc, N, type, vtransform);
    end
end
for t=1:TT
    for i=1:MM
        h_south  = squeeze(h(1,i));
        h_north  = squeeze(h(end,i));
        zw_bry_south(t,:,i)= zlevs_1d(h_south , squeeze(zeta_south(t,i)) , theta_s, theta_b, hc, N, type, vtransform);
        zw_bry_north(t,:,i)= zlevs_1d(h_north , squeeze(zeta_north(t,i)) , theta_s, theta_b, hc, N, type, vtransform);
    end
end
for t=1:TT
    for k=1:KK
        for j=1:LL
            zw_east=zw_bry_east(t,k,j);
            zw_west=zw_bry_west(t,k,j);
            O2_east=O2_bry_east(t,k,j);
            O2_west=O2_bry_west(t,k,j);      
            N2O_bry_east(t,k,j)= nevis_2003(zw_east,O2_east);
            N2O_bry_west(t,k,j)= nevis_2003(zw_west,O2_west);
        end
    end
end
for t=1:TT
    for k=1:KK
        for i=1:MM
            zw_north=zw_bry_north(t,k,i);
            zw_south=zw_bry_south(t,k,i);
            O2_north=O2_bry_north(t,k,i);
            O2_south=O2_bry_south(t,k,i);     
            N2O_bry_north(t,k,i)=nevis_2003(zw_north,O2_north);
            N2O_bry_south(t,k,i)=nevis_2003(zw_south,O2_south);
        end
    end
end
T= O2_time ;% time in days
cycle=O2_cycle;

%
% add N20 in bryfile file
%
type = 'boundary conditions file' ; 
history = 'CROCO' ;
%
% open the bry file  
% 
nc = netcdf(bryname,'write');
% new variable
%
%%redef(nc);
nc('n2o_time') = length(T);
nc{'n2o_time'} = ncdouble('n2o_time') ;
nc{'n2o_time'}.long_name = ncchar('time climatological N2O');
nc{'n2o_time'}.long_name = 'time climatological N2O';
nc{'n2o_time'}.units = ncchar('day');
nc{'n2o_time'}.units = 'day';
nc{'n2o_time'}.cycle_length = O2_cycle;

nc{'N2O_east'} = ncdouble('n2o_time','s_rho','eta_rho') ;
nc{'N2O_east'}.long_name = ncchar('Nitrous oxide');
nc{'N2O_east'}.long_name = 'Nitrous oxide';
nc{'N20_east'}.units = ncchar('mMol N2O m-3'); 
nc{'N2O_east'}.units = 'mMol N2O m-3';
nc{'N2O_east'}.fields = ncchar('NO2, scalar, series');
nc{'N2O_east'}.fields = 'NO2, scalar, series';

nc{'N2O_west'} = ncdouble('n2o_time','s_rho','eta_rho') ;
nc{'N2O_west'}.long_name = ncchar('Nitrous oxide');
nc{'N2O_west'}.long_name = 'Nitrous oxide';
nc{'N2O_west'}.units = ncchar('mMol N2O m-3'); 
nc{'N2O_west'}.units = 'mMol N2O m-3';
nc{'N2O_west'}.fields = ncchar('NO2, scalar, series');
nc{'N2O_west'}.fields = 'NO2, scalar, series';

nc{'N2O_south'} = ncdouble('n2o_time','s_rho','xi_rho') ;
nc{'N2O_south'}.long_name = ncchar('Nitrous oxide');
nc{'N2O_south'}.long_name = 'Nitrous oxide';
nc{'N20_south'}.units = ncchar('mMol N2O m-3'); 
nc{'N2O_south'}.units = 'mMol N2O m-3';
nc{'N2O_south'}.fields = ncchar('NO2, scalar, series');
nc{'N2O_south'}.fields = 'NO2, scalar, series';

nc{'N2O_north'} = ncdouble('n2o_time','s_rho','xi_rho') ;
nc{'N2O_north'}.long_name = ncchar('Nitrous oxide');
nc{'N2O_north'}.long_name = 'Nitrous oxide';
nc{'N20_north'}.units = ncchar('mMol N2O m-3'); 
nc{'N2O_north'}.units = 'mMol N2O m-3';
nc{'N2O_north'}.fields = ncchar('NO2, scalar, series');
nc{'N2O_north'}.fields = 'NO2, scalar, series';

%
% write new variable
%
nc{'n2o_time'}(:) =  T; 
nc{'N2O_east'}(:,:,:,:) =  N2O_bry_east; 
nc{'N2O_west'}(:,:,:,:) =  N2O_bry_west; 
nc{'N2O_south'}(:,:,:,:) = N2O_bry_south; 
nc{'N2O_north'}(:,:,:,:) = N2O_bry_north; 
%
% Synchronize on disk
%
close(nc);
end






