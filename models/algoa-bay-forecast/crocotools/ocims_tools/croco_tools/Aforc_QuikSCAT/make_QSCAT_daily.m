%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO forcing file
%
%  Extrapole and interpole surface data to get surface boundary
%  conditions for CROCO (forcing netcdf file)
%
%  Data input format (netcdf):
%     taux(T, Y, X)
%     T : time [Months]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library 
%                (Atlas of Surface Marine Data 1994)
%
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.DASILVA/
%
%  Pierrick Penven, IRD, 2002. 
%  Modified by Marchesiello, 2005, to use 
%             IFREMER/CERSAT MWF QuikSCAT daily winds.
%  Modified by Penven, jan 2007, to use OPENDAP.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
%  Wind stress
%
taux_name='taux';
tauy_name='tauy';

if QSCAT_blk==1
uwnd_name='uwnd';
vwnd_name='vwnd';
wspd_name='wnds';
end

%
%  Heat fluxes w3
%
shf_file=[coads_dir,'netheat.cdf'];
shf_name='netheat';
%
%  Fresh water fluxes (evaporation - precipitation)
%
swf_file=[coads_dir,'emp.cdf'];
swf_name='emp';
%
%  Sea surface temperature and heat flux sensitivity to the
%  sea surface temperature (dQdSST).
%  To compute dQdSST we need:
%    sat     : Surface atmospheric temperature
%    airdens : Surface atmospheric density
%    w3      : Wind speed at 10 meters
%    qsea    : Sea level specific humidity
%
sst_file=[coads_dir,'sst.cdf'];
sst_name='sst';
sat_file=[coads_dir,'sat.cdf'];
sat_name='sat';
airdens_file=[coads_dir,'airdens.cdf'];
airdens_name='airdens';
w3_file=[coads_dir,'w3.cdf'];
w3_name='w3';
qsea_file=[coads_dir,'qsea.cdf'];
qsea_name='qsea';
%
%  Sea surface salinity
%
sss_file=[coads_dir,'sss.cdf'];
sss_name='salinity';
%
%  Short wave radiation
%
srf_file=[coads_dir,'shortrad.cdf'];
srf_name='shortrad';
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp(CROCO_title)
%
if level==0
  nc_suffix='.nc';
else
  nc_suffix=['.nc.',num2str(level)];
  grdname=[grdname,'.',num2str(level)];
end
%
% Get the model grid
%
nc=netcdf(grdname);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
angle=nc{'angle'}(:);
close(nc)
cosa = cos(angle);
sina = sin(angle);
%
% Extract data over the internet
%
if Download_data==1
%
% Get the model limits
%
  lonmin=min(min(lon));
  lonmax=max(max(lon));
  latmin=min(min(lat));
  latmax=max(max(lat));
%
% Download QSCAT
% 
  disp('Download QSCAT data with OPENDAP')
  download_QSCAT(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
                 QSCAT_dir,Yorig,QSCAT_blk)
end
%
% Loop on the years and the months
%
for Y=Ymin:Ymax
  if Y==Ymin 
    mo_min=Mmin;
  else
    mo_min=1;
  end
  if Y==Ymax
    mo_max=Mmax;
  else
    mo_max=12;
  end
  for M=mo_min:mo_max
    disp(' ')
    disp(['Processing  year ',num2str(Y),...
          ' - month ',num2str(M)])
    disp(' ')
%
% Process the QuickSCAT time (here in days)
%
    nc=netcdf([QSCAT_dir,'tauxY',num2str(Y),'M',num2str(M),'.nc']);
    QSCAT_time=nc{'time'}(:);
    close(nc);
    dt=mean(gradient(QSCAT_time));
%
% Add 2 times step in the CROCO files: 1 at the beginning and 1 at the end 
% (otherwise.. CROCO crashes)
%
    tlen=length(QSCAT_time)+2;
    time=0*(1:tlen);
    time(2:end-1)=QSCAT_time;
%
%
%
    time(1)=datenum(Y,M,1)-datenum(Yorig,1,1)-1-dt/2;
    time(end)=datenum(Y,M,31)-datenum(Yorig,1,1)+1+dt/2;

%
% Create a CROCO forcing file for each month
%
    frcname=[QSCAT_frc_prefix,'Y',num2str(Y),...
             'M',num2str(M),nc_suffix];
    disp(['Create a new forcing file: ' frcname])
    create_forcing_QSCAT(frcname,grdname,CROCO_title,QSCAT_blk,...
                   time,coads_time,coads_time,...
                   coads_time,coads_time,coads_time,...
                   0,coads_cycle,coads_cycle,...
                   coads_cycle,coads_cycle,coads_cycle)
    nc_frc=netcdf(frcname,'write');

% Add the wind
%
%
% 1 Check if there are QSCAT files for the previous Month
%
    Mm=M-1;
    Ym=Y;
    if Mm==0
      Mm=12;
      Ym=Y-1;
    end
    taux_file=[QSCAT_dir,'tauxY',num2str(Ym),'M',num2str(Mm),'.nc'];
    if exist(taux_file)==0
      disp(['   No data for the previous month: using current month'])
      tindex=1;
      Mm=M;
      Ym=Y;
    else
      nc=netcdf(taux_file);
      tindex=length(nc('time'));
      nc_frc{'sms_time'}(1)=nc{'time'}(tindex);
      close(nc)
    end
%
% 2 Perform the interpolations for the previous month
%
    disp('First step')
    taux_file=[QSCAT_dir,'tauxY',num2str(Ym),'M',num2str(Mm),'.nc'];
    tauy_file=[QSCAT_dir,'tauyY',num2str(Ym),'M',num2str(Mm),'.nc'];
    u=ext_data(taux_file,taux_name,tindex,...
               lon,lat,[],Roa,2);
    v=ext_data(tauy_file,tauy_name,tindex,...
               lon,lat,[],Roa,2);
    nc_frc{'sustr'}(1,:,:)=rho2u_2d(u.*cosa + v.*sina);
    nc_frc{'svstr'}(1,:,:)=rho2v_2d(v.*cosa - u.*sina);
    
    if QSCAT_blk==1
      
      uwnd_file=[QSCAT_dir,'uwndY',num2str(Ym),'M',num2str(Mm),'.nc'];
      vwnd_file=[QSCAT_dir,'vwndY',num2str(Ym),'M',num2str(Mm),'.nc']; 
      wspd_file=[QSCAT_dir,'wndsY',num2str(Ym),'M',num2str(Mm),'.nc'];       
      uwnd=ext_data(uwnd_file,uwnd_name,tindex,lon,lat,[],Roa,2);
      vwnd=ext_data(vwnd_file,vwnd_name,tindex,lon,lat,[],Roa,2); 
      wspd=ext_data(wspd_file,wspd_name,tindex,lon,lat,[],Roa,2); 
      
      nc_frc{'uwnd'}(1,:,:)=uwnd;
      nc_frc{'vwnd'}(1,:,:)=vwnd;
      nc_frc{'wspd'}(1,:,:)=wspd;  
    end    
    
%
% Perform the interpolations for the current month
%
    taux_file=[QSCAT_dir,'tauxY',num2str(Y),'M',num2str(M),'.nc'];
    tauy_file=[QSCAT_dir,'tauyY',num2str(Y),'M',num2str(M),'.nc'];
    for tindex=2:tlen-1
      u=ext_data(taux_file,taux_name,tindex-1,...
                 lon,lat,[],Roa,2);
      v=ext_data(tauy_file,tauy_name,tindex-1,...
                 lon,lat,[],Roa,2);
      
      nc_frc{'sustr'}(tindex,:,:)=rho2u_2d(u.*cosa + v.*sina);
      nc_frc{'svstr'}(tindex,:,:)=rho2v_2d(v.*cosa - u.*sina);
      
      if QSCAT_blk 
      uwnd_file=[QSCAT_dir,'uwndY',num2str(Y),'M',num2str(M),'.nc'];
      vwnd_file=[QSCAT_dir,'vwndY',num2str(Y),'M',num2str(M),'.nc']; 
      wspd_file=[QSCAT_dir,'wndsY',num2str(Y),'M',num2str(M),'.nc'];   		
	
      uwnd=ext_data(uwnd_file,uwnd_name,tindex-1,...
               lon,lat,[],Roa,2);
      vwnd=ext_data(vwnd_file,vwnd_name,tindex-1,...
               lon,lat,[],Roa,2); 
      wspd=ext_data(wspd_file,wspd_name,tindex-1,...
               lon,lat,[],Roa,2);  	
      
      nc_frc{'uwnd'}(tindex,:,:)=uwnd;
      nc_frc{'vwnd'}(tindex,:,:)=vwnd;
      nc_frc{'wspd'}(tindex,:,:)=wspd;
      end
      
    end
%
% Read the QSCAT file for the next month
%
    Mp=M+1;
    Yp=Y;
    if Mp==13
      Mp=1;
      Yp=Y+1;
    end
    taux_file=[QSCAT_dir,'tauxY',num2str(Yp),'M',num2str(Mp),'.nc'];
    if exist(taux_file)==0
      disp(['   No data for the next month: using current month'])
      tindex=tlen-2;
      Mp=M;
      Yp=Y;
    else
      nc=netcdf(taux_file);
      tindex=1;
      nc_frc{'sms_time'}(tlen)=nc{'time'}(tindex);
      close(nc)
    end
%
% Perform the interpolations for the next month
%
    disp('Last step')
    taux_file=[QSCAT_dir,'tauxY',num2str(Yp),'M',num2str(Mp),'.nc'];
    tauy_file=[QSCAT_dir,'tauyY',num2str(Yp),'M',num2str(Mp),'.nc'];
    u=ext_data(taux_file,taux_name,tindex,...
               lon,lat,[],Roa,2);
    v=ext_data(tauy_file,tauy_name,tindex,...
               lon,lat,[],Roa,2);
    nc_frc{'sustr'}(tlen,:,:)=rho2u_2d(u.*cosa + v.*sina);
    nc_frc{'svstr'}(tlen,:,:)=rho2v_2d(v.*cosa - u.*sina);
%
      if QSCAT_blk      
      uwnd_file=[QSCAT_dir,'uwndY',num2str(Yp),'M',num2str(Mp),'.nc'];
      vwnd_file=[QSCAT_dir,'vwndY',num2str(Yp),'M',num2str(Mp),'.nc']; 
      wspd_file=[QSCAT_dir,'wndsY',num2str(Yp),'M',num2str(Mp),'.nc'];       
      uwnd=ext_data(uwnd_file,uwnd_name,tindex,...
               lon,lat,[],Roa,2);
      vwnd=ext_data(vwnd_file,vwnd_name,tindex,...
               lon,lat,[],Roa,2); 
      wspd=ext_data(wspd_file,wspd_name,tindex,...
               lon,lat,[],Roa,2);     
           
      nc_frc{'uwnd'}(tlen,:,:)=uwnd;
      nc_frc{'vwnd'}(tlen,:,:)=vwnd;
      nc_frc{'wspd'}(tlen,:,:)=wspd;
      end
      
     
    close(nc_frc)
%
  end
end
%#########################################################################
%               ADD THIS TO COMPUTE THE SPIN-UP PERIOD
%               --------------------------------------
% Spin-up: (reproduce the first year 'SPIN_Long' times)
% just copy the files for the first year and change the time
%------------------------------------------------------------------------

if SPIN_Long>0
  M=Mmin-1;
  Y=Ymin-SPIN_Long;
  for month=1:12*SPIN_Long
    M=M+1;
    if M==13
      M=1; 
      Y=Y+1;
    end
%
% Forcing files
%
% Copy the file
%
      frcname=[QSCAT_frc_prefix,'Y',num2str(Ymin),'M',num2str(M),nc_suffix];
      frcname2=[QSCAT_frc_prefix,'Y',num2str(Y),'M',num2str(M),nc_suffix];
      disp(['Create ',frcname2]) 
      eval(['!cp ',frcname,' ',frcname2]) 
%
% Change the time
%
      nc=netcdf(frcname2,'write');
      time=nc{'sms_time'}(:)-365.*(Ymin-Y);
      nc{'sms_time'}(:)=time;    
      close(nc)
    end
  end
%
%
%#########################################################################
%
% Make a few plots
%
if makeplot==1
  disp(' ')
  disp(' Make a few plots...')
  test_forcing(frcname,grdname,'spd',[1 4 7 10],3,coastfileplot)
% $$$   figure
% $$$   test_forcing(frcname,grdname,'shflux',[1 4 7 10],3,coastfileplot)
% $$$   figure
% $$$   test_forcing(frcname,grdname,'swflux',[1 4 7 10],3,coastfileplot)
% $$$   figure
% $$$   test_forcing(frcname,grdname,'SST',[1 4 7 10],3,coastfileplot)
% $$$   figure
% $$$   test_forcing(frcname,grdname,'SSS',[1 4 7 10],3,coastfileplot)
% $$$   figure
% $$$   test_forcing(frcname,grdname,'dQdSST',[1 4 7 10],3,coastfileplot)
% $$$   figure
% $$$   test_forcing(frcname,grdname,'swrad',[1 4 7 10],3,coastfileplot)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
