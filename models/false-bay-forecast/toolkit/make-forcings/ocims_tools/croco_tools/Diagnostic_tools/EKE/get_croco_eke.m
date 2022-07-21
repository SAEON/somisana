clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Directory and file names
%
name='beng';
directory='SCRATCH/';
model='croco';
filetype='avg';  % 'his' or 'avg'
Ymin=4;
Ymax=10;
Mmin=1;
Mmax=12;
skipstep=1;
nonseason=0;
Yorig=nan;
endf='.nc';
filter=0;
coastfile='coastline_l.mat';
%
% Read the grid
%
fname=[directory,model,'_',filetype,'_Y',num2str(Ymin),'M',num2str(Mmin),endf];
nc=netcdf(fname);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
f=nc{'f'}(:);
rmask=nc{'mask_rho'}(:);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
close(nc)
mask=rmask;
%
% Filter
%
if filter==1
  lon=nine_point_avg(lon,mask);
  lat=nine_point_avg(lat,mask);
  f=nine_point_avg(f,mask);
  pm=1./(3*nine_point_avg(1./pm,mask));
  pn=1./(3*nine_point_avg(1./pn,mask));
  rmask=isfinite(f);
end
%
[M,L]=size(pm);
gof=9.81./f;
[umask,vmask,pmask]=uvp_mask(rmask);
%
% Get avg zeta
% 
if nonseason==1
  avgzeta=zeros(4,M,L);
  nindex=zeros(4);
else
  avgzeta=zeros(M,L);
  nindex=0;
end  
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
    fname=[directory,model,'_',filetype,'_Y',num2str(Y),'M',num2str(M),endf];
    disp(['Opening : ',fname])
    nc=netcdf(fname);
    if isempty(nc)
      disp(['Could ont open : ',fname])
    else
      ntime=length(nc('time'));
      if ntime==0
        ntime=length(nc('zeta_time'))-1;
        nstart=2;
        disp('Clim file')
      end
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
        plot_index=plot_index+1;
        if mod(plot_index,skipstep)==0
	  [day,month,year,imonth,thedate]=get_date(fname,tindex,Yorig);
          if(skipstep==1) 
            zeta=squeeze(nc{'zeta'}(tindex,:,:));
          else
	    zeta=squeeze(mean(nc{'zeta'}(tindex-floor((skipstep-1)/2):tindex+floor((skipstep-1)/2),:,:),1));
          end
	  if filter==1
	    zeta=nine_point_avg(zeta,mask);
	  end
          if nonseason==1
	    season=1+floor((imonth-1)/3);
	    avgzeta(season,:,:)=squeeze(avgzeta(season,:,:))+zeta;
            nindex(season) = nindex(season) + 1;
          else
            nindex = nindex + 1;
	    avgzeta=avgzeta+zeta;
          end
        end
      end
      close(nc)
    end
  end
end
if nonseason==1
  for season=1:4
    avgzeta(season,:,:)=avgzeta(season,:,:)/nindex(season);
  end
else
  avgzeta=avgzeta/nindex;
end
%
% Get u2 and v2
% 
u2=0*pm;
v2=0*pm;
z2=0*pm;
nindex=0;    
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
    fname=[directory,model,'_',filetype,'_Y',num2str(Y),'M',num2str(M),endf];
    disp(['Opening : ',fname])
    nc=netcdf(fname);
    if isempty(nc)
      disp(['Could ont open : ',fname])
    else
      ntime=length(nc('time'));
      if ntime==0
        ntime=length(nc('zeta_time'))-1;
        nstart=2;
        disp('Clim file')
      end
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
        plot_index=plot_index+1;
        if mod(plot_index,skipstep)==0
          [day,month,year,imonth,thedate]=get_date(fname,tindex,Yorig);
          if(skipstep==1) 
            zeta=squeeze(nc{'zeta'}(tindex,:,:));
          else
	    zeta=squeeze(mean(nc{'zeta'}(tindex-floor((skipstep-1)/2):tindex+floor((skipstep-1)/2),:,:),1));
          end
	  if filter==1
	    zeta=nine_point_avg(zeta,mask);
	  end
          if nonseason==1
	    season=1+floor((imonth-1)/3);
            zeta=zeta-squeeze(avgzeta(season,:,:));
	  else
            zeta=zeta-avgzeta;
	  end

          u=-gof.*v2rho_2d(vmask.*(zeta(2:end,1:end)-zeta(1:end-1,1:end))...
              .*0.5.*(pn(2:end,1:end)+pn(1:end-1,1:end)));
          v=gof.*u2rho_2d(umask.*(zeta(1:end,2:end)-zeta(1:end,1:end-1))...
              .*0.5.*(pm(1:end,2:end)+pm(1:end,1:end-1)));


          nindex = nindex + 1;
          u2=u2+u.^2;
          v2=v2+v.^2;
          z2=z2+zeta.^2;
       end
      end
      close(nc)
    end
  end
end
u2=u2/nindex;
v2=v2/nindex;
z2=z2/nindex;
%
% Compute EKE
%
eke=0.5*(u2+v2);
%
% Compute RMS SSH
%
varssh=sqrt(z2);
%
% 
%
eke(rmask==0)=NaN;
varssh(rmask==0)=NaN;
avgzeta(rmask==0)=NaN;
%
% Save
%
if nonseason==1
  fname=[name,'_eke_croco_ns.mat']
else
  fname=[name,'_eke_croco.mat']
end
save(fname,'lat','lon','eke','varssh','avgzeta')
%
% Plot
%
plot_eke(fname)
