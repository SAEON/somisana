%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  process_coast_CFSR.m
%
% Preprocessing script to remove the land values in CFSR data and 
% extrapolate coastal values inland.
%
% It also removes the redondant values around the Greenwitch Meridian
%
% This is done before using online interpolation
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
%  Copyright (c) 2012 by Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
% Directory of the input CFSR unprocessd data
%
CFSR_dir=[FORC_DATA_DIR,'CFSR_',CROCO_config,'/'];
%
% Directory of the output CFSR processd data
%
CFSR_COAST_dir=[FORC_DATA_DIR,'CFSR_COAST_',CROCO_config,'/'];
%
% Width of the extrapolation band inland (200km is ok for a 1/4deg simulation).
%
distmax=200e3;
%
% Decorrelation scale for the objective analysis [m]
%
ro=2000e3;
%
% CFSR atmospheric variables names
%
vnames={'Land_cover_1land_2sea' ...    % surface land-sea mask [1=land; 0=sea] 
        'Temperature_height_above_ground' ...      % 2 m temp. [k]
        'Downward_Long-Wave_Rad_Flux' ...   % surface downward long wave flux [w/m^2] 
        'Upward_Long-Wave_Rad_Flux_surface' ...   % surface upward long wave flux [w/m^2] 
        'Temperature_surface' ...     % surface temp. [k]   
	'Downward_Short-Wave_Rad_Flux_surface' ...   % surface downward solar radiation flux [w/m^2]
	'Upward_Short-Wave_Rad_Flux_surface' ...   % surface upward solar radiation flux [w/m^2] 
	'Precipitation_rate' ...   % surface precipitation rate [kg/m^2/s] 
	'U-component_of_wind' ...    % 10 m u wind [m/s]
	'V-component_of_wind' ...    % 10 m v wind [m/s]
	'Specific_humidity'};       % 2 m specific humidity [kg/kg]
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end of user input  parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
eval(['!mkdir ',CFSR_COAST_dir])
%
% 1 - Process the land sea mask
%
k=1;
disp(['  Processing mask'])
in_file =  [CFSR_dir,char(vnames(k)),'.nc'];
out_file = [CFSR_COAST_dir,char(vnames(k)),'.nc'];
%
nc=netcdf(in_file);
lon=nc{'lon'}(:);
lat=nc{'lat'}(:);
mask=squeeze(nc{'Land_cover_1land_2sea'}(1,:,:));
close(nc)
%
% 1.1 - Remove the redondant values around greenwitch meridian
% (around lon=0 there is an overlap that could create problems)
%
ibad=find(lon>-0.01 & lon<0.3);
if isempty(ibad)
  ibmin=1;
  ibmax=2;
else
  ibmin=min(ibad)-1;
  ibmax=max(ibad)+1;
end
%
mask=cat(2,mask(:,1:ibmin),mask(:,ibmax:end));
lon=cat(1,lon(1:ibmin),lon(ibmax:end));
[Mm,Lm]=size(mask);
%
% 1.2 - Write the land sea mask down
%
write_NCEP([CFSR_COAST_dir,char(vnames(k)),'.nc'],...
	    char(vnames(k)),lon,lat,0,mask,Yorig)
%
% 2 - Prepare for the extrapolations
%
% 2.1 - Remove the lakes in Africa and South America (not finished)
%
[X,Y]=meshgrid(lon,lat);
mask(X>10 & X<18 & Y>11 & Y<15)=1;
mask(X>16 & X<36 & Y>-15 & Y<10)=1;
mask(X>16 & X<33 & Y>-21 & Y<-12)=1;
mask(X>13 & X<21 & Y>-4   & Y<  15)=1;
mask(X>-72 & X<-69 & Y>9   & Y<  10.5)=1;
mask(X>-55 & X<-52 & Y>-4  & Y<  -2)=1;
mask(X>-69.5 & X<-68 & Y>-17 & Y<-15)=1;
mask(X>-48 & X<-47.5 & Y>-1.5 & Y<-0.7)=1;
%
% 2.2 - Get the number of points to create a "coastal band"
%
[dx,dy]=get_dx(X,Y);  
dxmin=min([min(dx(:)) min(dy(:))]);
npts=ceil(distmax/dxmin);
disp(['Number of points to perform the extrapolation: ',num2str(npts)])
%
% 2.3 - Create the matrices of good points and missing for the extrapolations
%
m2=mask;
for i=1:npts
  m2=hanning(m2);
end
%
mgood=double(m2<1 & m2>0 & mask==0);
mgood=double(m2<1 & m2>0 & mask==0);
mbad=double(m2<1 & m2>0 & mask==1);
mbad=double(m2<1 & m2>0 & mask==1);
disp(['Number of points used for the extrapolation: ',num2str(sum(mgood(:)))])
disp(['Number of points extrapolated: ',num2str(sum(mbad(:)))])
%
% 2.4 - Create the matrix for the extrapolation
%
if 1==1
  disp('Create the OA matrix')
  tic
  coef = oacoef(X(mgood==1),Y(mgood==1),X(mbad==1),Y(mbad==1),ro);
  toc
  save coef.mat coef
else
  disp('Load the OA matrix')
  load coef.mat
end
%
% 3 - Loop on the years
%
for Ye=Ymin:Ymax
  disp(['=========================='])
  disp(['Processing year: ',num2str(Ye)])
  disp(['=========================='])
%
% 3.1 - Loop on the months
%
  if Ye==Ymin
    mo_min=Mmin;
  else
    mo_min=1;
  end
  if Ye==Ymax
    mo_max=Mmax;
  else
    mo_max=12;
  end
  
  for Mo=mo_min:mo_max
    disp(['  Processing month: ',num2str(Mo)])
    disp(['=========================='])
%
% 3.2 - Loop on variable names
%
    for k=2:length(vnames)
      vname=char(vnames(k));
      disp(['=========================='])
      disp(['    VNAME IS ',vname]);
      disp(['=========================='])

      in_file = [CFSR_dir,vname,'_Y',num2str(Ye),'M',num2str(Mo),'.nc'];

      nc=netcdf(in_file);
      time=nc{'time'}(:);
      
      N=length(time);
      var=nan*zeros(N,Mm,Lm);

      for tndx=1:N

        disp(['Processing ',num2str(tndx),' of ',num2str(N)])

        var0=squeeze(nc{vname}(tndx,:,:));
        var0=cat(2,var0(:,1:ibmin),var0(:,ibmax:end));
	mvar0=mean(var0(mask==0));
	var0(mask==1)=mvar0;
	var0(mbad==1)=mvar0+coef*(var0(mgood==1)-mvar0);
	
	var(tndx,:,:)=var0;

      end
      
      close(nc)    
%
% 3.3 - Write in a file
%
      write_NCEP([CFSR_COAST_dir,vname,'_Y',num2str(Ye),...
	          'M',num2str(Mo),'.nc'],...
	          vname,lon,lat,time,var,Yorig)
%
    end % loop k
  end % end loop month
end % end loop year
%
return
























