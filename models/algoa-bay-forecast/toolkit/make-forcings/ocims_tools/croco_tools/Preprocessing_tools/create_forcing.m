function  create_forcing(frcname,grdname,title,smst,...
                         shft,swft,srft,sstt,ssst,smsc,...
                         shfc,swfc,srfc,sstc,sssc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf forcing file
%       frcname: name of the forcing file
%       grdname: name of the grid file
%       title: title in the netcdf file  
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(grdname,'r');
L=length(nc('xi_psi'));
M=length(nc('eta_psi'));
close(nc);
Lp=L+1;
Mp=M+1;

nw = netcdf(frcname, 'clobber');
%result = redef(nw);

%
%  Create dimensions
%

nw('xi_u') = L;
nw('eta_u') = Mp;
nw('xi_v') = Lp;
nw('eta_v') = M;
nw('xi_rho') = Lp;
nw('eta_rho') = Mp;
nw('xi_psi') = L;
nw('eta_psi') = M;
nw('sms_time') = length(smst);
nw('shf_time') = length(shft);
nw('swf_time') = length(swft);
nw('sst_time') = length(sstt);
nw('srf_time') = length(srft);
nw('sss_time') = length(ssst);
nw('wwv_time') = length(smst);
%
%  Create variables and attributes
%
nw{'sms_time'} = ncdouble('sms_time');
nw{'sms_time'}.long_name = ncchar('surface momentum stress time');
nw{'sms_time'}.long_name = 'surface momentum stress time';
nw{'sms_time'}.units = ncchar('days');
nw{'sms_time'}.units = 'days';
nw{'sms_time'}.cycle_length = smsc;

nw{'shf_time'} = ncdouble('shf_time');
nw{'shf_time'}.long_name = ncchar('surface heat flux time');
nw{'shf_time'}.long_name = 'surface heat flux time';
nw{'shf_time'}.units = ncchar('days');
nw{'shf_time'}.units = 'days';
nw{'shf_time'}.cycle_length =shfc ;

nw{'swf_time'} = ncdouble('swf_time');
nw{'swf_time'}.long_name = ncchar('surface freshwater flux time');
nw{'swf_time'}.long_name = 'surface freshwater flux time';
nw{'swf_time'}.units = ncchar('days');
nw{'swf_time'}.units = 'days';
nw{'swf_time'}.cycle_length = swfc;

nw{'sst_time'} = ncdouble('sst_time');
nw{'sst_time'}.long_name = ncchar('sea surface temperature time');
nw{'sst_time'}.long_name = 'sea surface temperature time';
nw{'sst_time'}.units = ncchar('days');
nw{'sst_time'}.units = 'days';
nw{'sst_time'}.cycle_length = sstc;

nw{'sss_time'} = ncdouble('sss_time');
nw{'sss_time'}.long_name = ncchar('sea surface salinity time');
nw{'sss_time'}.long_name = 'sea surface salinity time';
nw{'sss_time'}.units = ncchar('days');
nw{'sss_time'}.units = 'days';
nw{'sss_time'}.cycle_length = sssc;

nw{'srf_time'} = ncdouble('srf_time');
nw{'srf_time'}.long_name = ncchar('solar shortwave radiation time');
nw{'srf_time'}.long_name = 'solar shortwave radiation time';
nw{'srf_time'}.units = ncchar('days');
nw{'srf_time'}.units = 'days';
nw{'srf_time'}.cycle_length = srfc;

nw{'wwv_time'} = ncdouble('wwv_time');
nw{'wwv_time'}.long_name = ncchar('surface wave fields time');
nw{'wwv_time'}.long_name = 'surface wave fields time';
nw{'wwv_time'}.units = ncchar('days');
nw{'wwv_time'}.units = 'days';
nw{'wwv_time'}.cycle_length = smsc;


nw{'sustr'} = ncdouble('sms_time', 'eta_u', 'xi_u');
nw{'sustr'}.long_name = ncchar('surface u-momentum stress');
nw{'sustr'}.long_name = 'surface u-momentum stress';
nw{'sustr'}.units = ncchar('Newton meter-2');
nw{'sustr'}.units = 'Newton meter-2';

nw{'svstr'} = ncdouble('sms_time', 'eta_v', 'xi_v');
nw{'svstr'}.long_name = ncchar('surface v-momentum stress');
nw{'svstr'}.long_name = 'surface v-momentum stress';
nw{'svstr'}.units = ncchar('Newton meter-2');
nw{'svstr'}.units = 'Newton meter-2';

nw{'shflux'} = ncdouble('shf_time', 'eta_rho', 'xi_rho');
nw{'shflux'}.long_name = ncchar('surface net heat flux');
nw{'shflux'}.long_name = 'surface net heat flux';
nw{'shflux'}.units = ncchar('Watts meter-2');
nw{'shflux'}.units = 'Watts meter-2';

nw{'swflux'} = ncdouble('swf_time', 'eta_rho', 'xi_rho');
nw{'swflux'}.long_name = ncchar('surface freshwater flux (E-P)');
nw{'swflux'}.long_name = 'surface freshwater flux (E-P)';
nw{'swflux'}.units = ncchar('centimeter day-1');
nw{'swflux'}.units = 'centimeter day-1';
nw{'swflux'}.positive = ncchar('net evaporation');
nw{'swflux'}.positive = 'net evaporation';
nw{'swflux'}.negative = ncchar('net precipitation');
nw{'swflux'}.negative = 'net precipitation';

nw{'SST'} = ncdouble('sst_time', 'eta_rho', 'xi_rho');
nw{'SST'}.long_name = ncchar('sea surface temperature');
nw{'SST'}.long_name = 'sea surface temperature';
nw{'SST'}.units = ncchar('Celsius');
nw{'SST'}.units = 'Celsius';

nw{'SSS'} = ncdouble('sss_time', 'eta_rho', 'xi_rho');
nw{'SSS'}.long_name = ncchar('sea surface salinity');
nw{'SSS'}.long_name = 'sea surface salinity';
nw{'SSS'}.units = ncchar('PSU');
nw{'SSS'}.units = 'PSU';

nw{'dQdSST'} = ncdouble('sst_time', 'eta_rho', 'xi_rho');
nw{'dQdSST'}.long_name = ncchar('surface net heat flux sensitivity to SST');
nw{'dQdSST'}.long_name = 'surface net heat flux sensitivity to SST';
nw{'dQdSST'}.units = ncchar('Watts meter-2 Celsius-1');
nw{'dQdSST'}.units = 'Watts meter-2 Celsius-1';

nw{'swrad'} = ncdouble('srf_time', 'eta_rho', 'xi_rho');
nw{'swrad'}.long_name = ncchar('solar shortwave radiation');
nw{'swrad'}.long_name = 'solar shortwave radiation';
nw{'swrad'}.units = ncchar('Watts meter-2');
nw{'swrad'}.units = 'Watts meter-2';
nw{'swrad'}.positive = ncchar('downward flux, heating');
nw{'swrad'}.positive = 'downward flux, heating';
nw{'swrad'}.negative = ncchar('upward flux, cooling');
nw{'swrad'}.negative = 'upward flux, cooling';

nw{'Awave'} = ncdouble('wwv_time', 'eta_rho', 'xi_rho');
nw{'Awave'}.long_name = ncchar('wind induced wave amplitude');
nw{'Awave'}.long_name = 'wind induced wave amplitude';
nw{'Awave'}.units = ncchar('m');
nw{'Awave'}.units = 'm';

nw{'Dwave'} = ncdouble('wwv_time', 'eta_rho', 'xi_rho');
nw{'Dwave'}.long_name = ncchar('wind induced wave direction');
nw{'Dwave'}.long_name = 'wind induced wave direction';
nw{'Dwave'}.units = ncchar('degree');
nw{'Dwave'}.units = 'degree';

nw{'Pwave'} = ncdouble('wwv_time', 'eta_rho', 'xi_rho');
nw{'Pwave'}.long_name = ncchar('wind induced wave period');
nw{'Pwave'}.long_name = 'wind induced wave period';
nw{'Pwave'}.units = ncchar('second');
nw{'Pwave'}.units = 'second';

%result = endef(nw);

%
% Create global attributes
%

nw.title = ncchar(title);
nw.title = title;
nw.date = ncchar(date);
nw.date = date;
nw.grd_file = ncchar(grdname);
nw.grd_file = grdname;
nw.type = ncchar('CROCO forcing file');
nw.type = 'CROCO forcing file';

%
% Write time variables
%

nw{'sms_time'}(:) = smst;
nw{'shf_time'}(:) = shft;
nw{'swf_time'}(:) = swft;
nw{'sst_time'}(:) = sstt;
nw{'srf_time'}(:) = srft;
nw{'sss_time'}(:) = ssst;
nw{'wwv_time'}(:) = smst;

close(nw);
