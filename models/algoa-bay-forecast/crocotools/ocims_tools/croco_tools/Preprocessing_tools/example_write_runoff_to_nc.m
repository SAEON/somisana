clear all
close all

% In this programm the monthly data for river runoff are written into a
% netcdf file

% data from the Mekong River Commission (2005): mean monthly value btw 1960
% and 2004, m3/s
debit_at_kratie=[3620  2730 2290 2220 3640 11200 22200 35500 36700 22000 10900 5710]
debit_mekong=100/91*debit_at_kratie

% data from Annales de Géographie, Pardé, 1938: average over 1912-1935.
% mean : 3917m3/s
debit_redriv=[1229 1125 1052 1089 1735 4802 8557 11243 6573 5065 2875 1657]

% data from wikipedia for Xi at wuzhou
debit_wuzhou= [1761 1743 2216 4527 9384 14211 14835 14410 8853 5346 3687 2605]
%debit_wuzhou=/mean(debit_wuzhou)

temp_src0=[11 9 9 12 20 20 24 25 21 18 13 12];
temp_src=[temp_src0;temp_src0+2;temp_src0+2.8];

salt_src0=[8 3 5 1 5 3 2 1 4 2 1 2];
salt_src=[salt_src0;salt_src0+2;salt_src0+2.8];

no3_src00=[30.09  29.25  28.85  24.19  22.88  21.26  16.91  12.4  10.76  13.76  22.44  28.06]
no3_src01=[34.67  34.97  34.42  36.61  35.64  36.65  35.3  34.61  30.09  27.74  30.76  33.32]
no3_src02=no3_src01+3;
no3_src=[no3_src00;no3_src01;no3_src02];

qbar_name= ['R1';'R2';'R3'];
A=[debit_mekong;debit_redriv;debit_wuzhou]

figure
subplot(211)
plot(A')
legend(qbar_name)
grid on; box on
title(['\bf Run-off'])

subplot(212)
hold on
plot(no3_src')
legend(qbar_name)
grid on; box on
title(['\bf NO3 conc'])

nw=netcdf('croco_runoff_monthly.nc','clobber');
% Dimension 
nw('qbar_time') = 12;
nw('n_qbar') = 3;
nw('runoffname_StrLen') = 2;

% Variable and Attribute
nw{'qbar_time'} = ncdouble('qbar_time');
nw{'qbar_time'}.long_name = ncchar('runoff time');
nw{'qbar_time'}.units = ncchar('days');
nw{'qbar_time'}.cycle_length = 360;

nw{'temp_src_time'} = ncdouble('qbar_time');
nw{'temp_src_time'}.long_name = ncchar('runoff time');
nw{'temp_src_time'}.units = ncchar('days');
nw{'temp_src_time'}.cycle_length = 360;

nw{'salt_src_time'} = ncdouble('qbar_time');
nw{'salt_src_time'}.long_name = ncchar('runoff time');
nw{'salt_src_time'}.units = ncchar('days');
nw{'salt_src_time'}.cycle_length = 360;

nw{'no3_src_time'} = ncdouble('qbar_time');
nw{'no3_src_time'}.long_name = ncchar('runoff time');
nw{'no3_src_time'}.units = ncchar('days');
nw{'no3_src_time'}.cycle_length = 360;

nw{'Qbar'} = ncdouble('n_qbar','qbar_time');
nw{'Qbar'}.long_name = ncchar('runoff discharge');
nw{'Qbar'}.units = ncchar('m3.-1');

nw{'temp_src'} = ncdouble('n_qbar','qbar_time');
nw{'temp_src'}.long_name = ncchar('runoff temp conc.');
nw{'temp_src'}.units = ncchar('deg.celsius');

nw{'salt_src'} = ncdouble('n_qbar','qbar_time');
nw{'salt_src'}.long_name = ncchar('runoff salt conc.');
nw{'salt_src'}.units = ncchar('psu');

nw{'NO3_src'} = ncdouble('n_qbar','qbar_time');
nw{'NO3_src'}.long_name = ncchar('runoff no3 conc.');
nw{'NO3_src'}.units = ncchar('mmol.s-1');

nw{'runoff_name'} = ncchar('n_qbar','runoffname_StrLen');
nw{'runoff_name'}.long_name = ncchar('runoff time');
%%result = endef(nw);

% Fill th value
%
nw{'qbar_time'} (:) = [15:30:365];
nw{'temp_src_time'} (:) = [15:30:365];
nw{'salt_src_time'} (:) = [15:30:365];
nw{'no3_src_time'} (:) = [15:30:365];
nw{'Qbar'}(:) = A.*10';
nw{'temp_src'}(:) = temp_src;
nw{'salt_src'}(:) = salt_src;
nw{'NO3_src'}(:) = no3_src;
nw{'runoff_name'}(:) = qbar_name;
close (nw)
  
%Localisation des points source :

R_i= [32 36 28];
R_j= [20 14 33];
grdfile='CROCO_FILES/croco_grd.nc';
[lat, lon, mask]=read_latlonmask(grdfile,'r');

figure
pcolor(mask)
hold on
plot(R_i,R_j,'or')




