clear all
close all

gloabalriverfile='coastal-stns-Vol-monthly.updated-oct2007.nc';
fillval=-999;

ncriv=netcdf(gloabalriverfile);
time=ncriv{'time'}(:);
station=ncriv{'station'}(:);
chars=ncriv{'chars'}(:);
lonriv=ncriv{'lon'}(:);
latriv=ncriv{'lat'}(:);
lonriv_mou=ncriv{'lon_mou'}(:);
latriv_mou=ncriv{'lat_mou'}(:);
area_stn=ncriv{'area_stn'}(:);
area_mou=ncriv{'area_mou'}(:);
vol_stn=ncriv{'vol_stn'}(:);
ratio_m2s=ncriv{'ratio_m2s'}(:);
xnyr=ncriv{'xnyr'}(:);
yrb=ncriv{'yrb'}(:);
yre=ncriv{'yre'}(:);
elev=ncriv{'elev'}(:);
ct_name=ncriv{'ct_name'}(:);
cn_name=ncriv{'cn_name'}(:);
riv_name=ncriv{'riv_name'}(:);
ocn_name=ncriv{'ocn_name'}(:);
stn_name=ncriv{'stn_name'}(:);
FLOW=ncriv{'FLOW'}(:);
time_1800=ncriv{'time_1800'}(:);
station_1800=ncriv{'station_1800'}(:);
index_id_1800=ncriv{'index_id_1800'}(:);
FLOW_1800=ncriv{'FLOW_1800'}(:);
close(ncriv)

% On ne s'occupe que des data depuis 1900 Compute a climatology
my_time=time;
time_char=num2str(time)
month=str2num(time_char(:,5:6));
 for k=1:12
     if k<10
     disp(['my_time==0',num2str(k)])
     eval(['ind_month(k,:)=find(month==0',num2str(k),');'])
     else
       disp(['my_time==',num2str(k)])  
     eval(['ind_month(k,:)=find(month==',num2str(k),');'])
     end
 end
% ind_month(12:107) contient les indices des differents mois.

% Compute the clim, first remove the NaN
FLOW(FLOW==fillval)=NaN;
for riv=1:925
    disp(['Compute river# ',num2str(riv)])
    disp(['############################'])
    for k=1:12
       % disp(['Compute month ',num2str(k)])
        FLOW_clm(riv,k) =  nanmean(FLOW(ind_month(k,:),riv),1);
    end
end
FLOW_clm=FLOW_clm';


%Create climatological CROCOTOOLS netcdf file
runoff_global_clim='runoff_global_clim.nc';
nw=netcdf(runoff_global_clim,'clobber');
result = redef(nw);
%
%  Create dimensions
%
nw('time') = 1284;
nw('station') = 925 ;
nw('chars') = 30 ;
nw('twelve') = 12 ;
%
%  Create variables and attributes
%
nw{'time'}= ncint('time');
nw{'time'}.long_name='time as YYYYMM';
nw{'time'}.FillValue=-999;
nw{'time'}.units='unitless';

nw{'lon_mou'}= ncdouble('station');
nw{'lon_mou'}.long_name='river mouth longitude';
nw{'lon_mou'}.units='degrees_east';

nw{'lat_mou'}= ncdouble('station');
nw{'lat_mou'}.long_name='river mouth latitude';
nw{'lat_lou'}.units='degrees_north';

nw{'lon'}=ncdouble('station');
nw{'lon'}.long_name='station longitude';
nw{'lon'}.units='degrees_east';

nw{'lat'}=ncdouble('station');
nw{'lat'}.long_name='station latitude';
nw{'lat'}.units='degrees_north';

nw{'riv_name'}=ncchar('station', 'chars');
nw{'riv_name'}.long_name='river name';
nw{'riv_name'}.units='degrees_east';

nw{'ocn_name'}=ncchar('station', 'chars');
nw{'ocn_name'}.long_name='ocean name of river discharge';
nw{'ocn_name'}.units=' ';

nw{'ct_name'}=ncchar('station', 'chars');
nw{'ct_name'}.long_name='country of station';
nw{'ct_name'}.units=' ';

nw{'cn_name'}=ncchar('station', 'chars');
nw{'cn_name'}.long_name='continent of station';
nw{'cn_name'}.units=' ';

nw{'stn_name'}=ncchar('station', 'chars');
nw{'stn_name'}.long_name='station name';
nw{'stn_name'}.units=' ';

nw{'FLOW'}=ncdouble('time','station');
nw{'FLOW'}.long_name='monthly mean volume at station';
nw{'FLOW'}.FillValue=-999;
nw{'FLOW'}.units='m3/s';

nw{'FLOW_clm'}=ncdouble('twelve','station');
nw{'FLOW_clm'}.long_name='monthly clim  volume at station';
nw{'FLOW_clm'}.FillValue=-999;
nw{'FLOW_clm'}.units='m3/s';
%
% Create global attributes
%
nw.title = 'Monthly clim from monthly streamflow from downstream stations for World\''s 925 ocean-reaching rivers. Dai and Trenberth, 2002';
nw.source_file = 'coastal-stns-Vol-monthly.nc; http://www.cgd.ucar.edu/cas/catalog/surface/dai-runoff/index.html';
result = endef(nw);
close(nw)
%
% Write time variables
%
nw=netcdf(runoff_global_clim,'w');
nw{'FLOW_clm'}(:)=FLOW_clm(:);
nw{'FLOW'}(:)=FLOW(:);
nw{'stn_name'}(:)=stn_name(:);
nw{'cn_name'}(:)=cn_name(:);
nw{'ct_name'}(:)=ct_name(:);
nw{'ocn_name'}(:)=ocn_name(:);
nw{'riv_name'}(:)=riv_name(:);
nw{'lat'}(:)=latriv(:);
nw{'lon'}(:)=lonriv(:);
nw{'lat_mou'}(:)=latriv_mou(:);
nw{'lon_mou'}(:)=lonriv_mou(:);
nw{'time'}(:)=time(:);
close(nw)