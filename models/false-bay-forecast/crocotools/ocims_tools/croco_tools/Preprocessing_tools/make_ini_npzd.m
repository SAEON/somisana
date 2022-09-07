%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO initial file from Global Atlas (WOA or CARS)
%
%  Extrapole and interpole fields from a
%  Climatology to get initial conditions for
%  CROCO (initial netcdf files) .
%
%  Data input format (netcdf):
%     variable(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA98/
%
%  Pierrick Penven, IRD, 2005.
%  Olivier Aumont, IRD, 2006.
%  Patricio Marchesiello, IRD 2007
%  Christophe Eugene Raoul Menkes, IRD 2013
%  Elodie Gutknecht, 2013
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title
%
crocotools_param
%
%  Data climatologies file names:
%
no3_seas_data=[climato_dir,'no3_seas.cdf'];
no3_ann_data=[climato_dir,'no3_ann.cdf'];
o2_seas_data=[climato_dir,'o2_seas.cdf'];
o2_ann_data=[climato_dir,'o2_ann.cdf'];
chla_seas_data=[chla_dir,'chla_seas.cdf'];

NO3min=0.01;
O2min=0.01;
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%

%
% Initial file
%
add_ini_npzd(ininame,'write');
%
% Horizontal and vertical interp/extrapolations
%
disp(' ')
disp(' Interpolations / extrapolations')
% NO3
disp(' ')
disp('Nitrate ...')
ext_tracers_ini(ininame,grdname,no3_seas_data,no3_ann_data,...
                'nitrate','NO3','r',tini);
% O2
disp(' ')
disp(' Oxygen ...')
ext_tracers_ini(ininame,grdname,o2_seas_data,o2_ann_data,...
    'oxygen','O2','r',tini);
%  CHla
disp(' ')
disp(' CHla...')
add_ini_chla(ininame,grdname,chla_seas_data,woa_cycle,Roa);
%
%  Phyto
disp(' ')
disp(' Phyto...')
add_ini_phyto(ininame);
%
%  Zoo
disp(' ')
disp(' Zoo...')
add_ini_zoo(ininame);

%
% Remove low values for oligotrophic areas
%
nc=netcdf(ininame,'write');
NO3=nc{'NO3'}(:,:,:);
NO3(NO3<NO3min)=NO3min;
nc{'NO3'}(:,:,:)=NO3;
close(nc)

nc=netcdf(ininame,'write');
O2=nc{'O2'}(:,:,:);
O2(O2<O2min)=O2min;
nc{'O2'}(:,:,:)=O2;
close(nc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make a few plots
%
if (makeplot)
    disp(' ')
    disp(' Make a few plots...')
    test_clim(ininame,grdname,'O2',1,coastfileplot)
    figure
    test_clim(ininame,grdname,'NO3',1,coastfileplot)
    figure
    test_clim(ininame,grdname,'CHLA',1,coastfileplot)
    figure
    test_clim(ininame,grdname,'PHYTO',1,coastfileplot)
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



