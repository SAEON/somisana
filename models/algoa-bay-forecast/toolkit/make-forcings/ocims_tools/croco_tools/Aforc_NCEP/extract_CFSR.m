function extract_CFSR(CFSR_dir,url,fname,vname,vname2,Y,M,...
                      lon,lat,tndx,time,...
                      trange,level,jrange,...
                      i1min,i1max,i2min,i2max,i3min,i3max,...
                      jmin,jmax,Yorig,Get_My_Data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subset from CFSR using OPENDAP 
%
% Write it in a local file
% 
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
%  Copyright (c) 2011 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%clear all
%close all
if nargin < 1
  CFSR_dir='DATA/CFSR/';
  url='http://nomads.ncdc.noaa.gov/thredds/dodsC/modeldata/cmd_flxf/';
  vname='Precipitation_rate';
  vname='Temperature_height_above_ground';
  vname='Downward_Long-Wave_Rad_Flux';
  vname2='Downward_Long_2dWave_Rad_Flux';
  lon=[13.1460 13.4590 13.7720 14.0850 14.3980 14.7110 15.0240 15.3370 15.6500 15.9630 16.2760 16.5890 16.9020 17.2150 17.5280 17.8410 18.1540 18.4670 18.7800 19.0930 19.4060 19.7190 20.0320 20.3450 20.6580 20.9710 21.2840 21.5970 21.9100];
  lat=[-29.1934 -29.5056 -29.8179 -30.1301 -30.4423 -30.7545 -31.0668 -31.3790 -31.6912 -32.0035 -32.3157 -32.6279 -32.9401 -33.2524 -33.5646 -33.8768 -34.1891 -34.5013 -34.8135 -35.1257 -35.4380 -35.7502 -36.0624 -36.3747 -36.6869 -36.9991];
  trange='[0:0]';
  level='[0:0]';
  level='';
  jrange='[381:406]';
  i1min=[];
  i1max=[];
  i2min=42;
  i2max=70;
  i3min=[];
  i3max=[];
  Yorig=1900;
  Y=1979;
  M=1;
end
%
% Get the variable name
%
disp(['Get ',vname,' for year ',num2str(Y),...
      ' - month ',num2str(M)])
%
% Get the variable 2D subset (take care of greenwitch)
%
fname=get_filename_CFSR(Y,M,1,0);
x=readattribute([url,fname]);
eval(['missing_value=x.',vname2,'.missing_value;']);
%
% Get the number of days in the month
%      
nmax=daysinmonth(Y,M);
%nmax=1
Lm=length(lon);
Mm=length(lat);
N=4*nmax;
%
var=nan*zeros(N,Mm,Lm);
%
tndx=0;
for D=1:1:nmax
  for T=0:6:18
  
    if Y==2006 & M==6 & D==17 & T==6 

     disp(['---! Problem with ',datestr(datenum(Y,M,D,T,0,0))])

    else

      disp([' Downloading ',vname,' for ',datestr(datenum(Y,M,D,T,0,0))])

      tndx=tndx+1;

      fname=get_filename_CFSR(Y,M,D,T);
      
      var0=getdap(url,fname,vname,...
                  trange,level,jrange,...
	          i1min,i1max,i2min,i2max,i3min,i3max);	

      var0=shiftdim(var0,2);
      var0(var0==missing_value)=NaN;    
      var0=flipud(var0);	 % latitude inversion in CFSR
      var(tndx,:,:)=var0;
      time(tndx)=datenum(Y,M,D,T,0,0)-datenum(Yorig,1,1);

    end
  end
end
%
time=time(1:tndx);
var=var(1:tndx,:,:);
%
% Write it in a file
%
write_NCEP([CFSR_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'],...
	   vname,lon,lat,time,var,Yorig)
%
