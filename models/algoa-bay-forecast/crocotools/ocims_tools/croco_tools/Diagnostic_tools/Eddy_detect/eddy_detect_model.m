%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Detect surface geostrophic eddies in a model simulation
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
% CROCO output directory and names
%
croco_dir='SCRATCH/';
model='croco';
filetype='avg';  % 'his' or 'avg'
suffix='.nc';
%
% Domain limits 
%
lonmin =   8;   % Minimum longitude [degree east]
lonmax =  22;   % Maximum longitude [degree east]
latmin = -38;   % Minimum latitudeF  [degree north]
latmax = -26;   % Maximum latitude  [degree north]
%
% Duration
%
Ymin=10;
Ymax=10;
Mmin=1;
Mmax=12;
%
% Dates are defined as days since Yorig/1/1 00:00 (NaN for climatology)
%
Yorig=NaN;
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
% Eddies file name
%
netcdf_eddyfile=['eddies_croco_',num2str(Ymin),'_',num2str(Ymax),'.nc'];
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Create the eddy directory
%
nw=create_eddynetcdf(netcdf_eddyfile);
%
% Get the grid
%
grd_file=[croco_dir,model,'_',filetype,'_Y',num2str(Ymin),...
                                        'M',num2str(Mmin),suffix];
nc=netcdf(grd_file);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
%
imin=min(find(lon(1,:)>=lonmin));
imax=max(find(lon(1,:)<=lonmax));
jmin=min(find(lat(:,1)>=latmin));
jmax=max(find(lat(:,1)<=latmax));
%
lon=lon(jmin:jmax,imin:imax);
lat=lat(jmin:jmax,imin:imax);
%

mask=nc{'mask_rho'}(jmin:jmax,imin:imax);
pm=nc{'pm'}(jmin:jmax,imin:imax);
pn=nc{'pn'}(jmin:jmax,imin:imax);
f=nc{'f'}(jmin:jmax,imin:imax);
close(nc)
%
% Main loop on the years and months
%
indx=1;
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
    hisfile=[croco_dir,model,'_',filetype,'_Y',num2str(Y),...
                                          'M',num2str(M),suffix];
    disp(['Opening : ',hisfile])
    nc=netcdf(hisfile);
    if isempty(nc)
      disp(['Could ont open : ',hisfile])
    else
      ntime=length(nc('time'));
      if (filetype=='his' & ~(Y==Ymin & M==Mmin))
        nstart=2;
      else
        nstart=1;
      end
      plot_index=nstart-1;
%
% loop on the time indexes in the file 
%
      for tindex=nstart:ntime
      	disp(['Time step : ',num2str(tindex)])
%
%  Read time
%
        time=nc{'scrum_time'}(tindex);
        time=time/(24*3600);
%
%  Read zeta
%	
	zeta=squeeze(nc{'zeta'}(tindex,jmin:jmax,imin:imax));
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
          indx=write_eddynetcdf(nw,indx,0,time,elon(i),elat(i),...
                                AREA(i),EKE(i),XI(i),RADIUS(i),...
                                MAXZ(i),MINZ(i),MEANZ(i),AMP(i),...
                                Ueddy(i),Leddy(i),0,0);
        end
      end
      close(nc)
    end
  end
end
close(nw)
%
return
