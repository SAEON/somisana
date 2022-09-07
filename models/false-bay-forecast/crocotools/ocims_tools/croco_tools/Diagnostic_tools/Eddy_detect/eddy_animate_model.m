%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Animate Eddies from the eddy file
%
%
%  Pierrick Penven, IRD, 2011.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
clear all
close all
%
Re=6367442.76;
%
% Graphics options
%
coastfile='coastline_l.mat';
moviename='eddies_croco';
%
Xfig=25; % Width of the Figure in cm
Yfig=20; % Height of the Figure in cm
msize=10;
%
% Range of SSH [cm]
%
zmin=-200;
dz=5;
zmax=200;
%
% Choose movie format
%
anim_gif=0;
anim_mpeg=1;
anim_fli=0;
%
% CROCO output directory and names
%
croco_dir='SCRATCH/';
model='croco';
filetype='avg';  % 'his' or 'avg'
suffix='.nc';
%
% Duration
%
Ymin=10;
Ymax=10;
Mmin=1;
Mmax=10;
%
% Dates are defined as days since Yorig/1/1 00:00 (NaN for climatology)
%
Yorig=NaN;
%
% Domain limits 
%
lonmin =   8;   % Minimum longitude [degree east]
lonmax =  22;   % Maximum longitude [degree east]
latmin = -38;   % Minimum latitudeF  [degree north]
latmax = -26;   % Maximum latitude  [degree north]
%
% Eddies netcdf file name
%
eddyfile='eddies_croco_10_10_select.nc';
%
% Eddies minimum life duration [days] 
% (to filter eddies out which have a too short duration)
%
eddy_life=7; % days
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
%
% Check the number of eddy files
%
nc=netcdf(eddyfile);
ID_all=nc{'ID'}(:);
time_all=nc{'time'}(:);
lon_all=nc{'lon'}(:);
lat_all=nc{'lat'}(:);
Vort_all=nc{'Vorticity'}(:);
Radius_all=nc{'Radius'}(:);
U_all=nc{'U'}(:);
V_all=nc{'V'}(:);
close(nc)
if isfinite(Yorig)
  time_all=time_all+datenum(Yorig,1,1);
end
%
% Select the eddies dates of birth and death for eddies who lived long enough
%
ngood=0;
for i=1:max(ID_all)

  indx=find(ID_all==i);
  teddy=time_all(indx);
  
  if teddy(end)-teddy(1)>=eddy_life

    ngood=ngood+1;
    ID_good(ngood)=i;  
    
    teddy_start(ngood)=teddy(1);
    teddy_end(ngood)=teddy(end);   

  end
end
ngood
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
lonmin=min(lon(:));
lonmax=max(lon(:));
latmin=min(lat(:));
latmax=max(lat(:));
%
mask=nc{'mask_rho'}(jmin:jmax,imin:imax);
pm=nc{'pm'}(jmin:jmax,imin:imax);
pn=nc{'pn'}(jmin:jmax,imin:imax);
f=nc{'f'}(jmin:jmax,imin:imax);
h=nc{'h'}(jmin:jmax,imin:imax);
close(nc)
%
% Loop on time (and files)
%
fid = fli_begin;
fr = 0;
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
%
%  Read time
%
        time=nc{'scrum_time'}(tindex);
        time=time/(24*3600);
        if isfinite(Yorig)
          time=time+datenum(Yorig,1,1);
        end
      	disp(['Time step : ',num2str(tindex),' - time : ',num2str(time)])
%
%  Read zeta
%	
	zeta=squeeze(nc{'zeta'}(tindex,jmin:jmax,imin:imax));
        zeta=zeta*100;
%
% Figure
%
        h1=figure('Units','centimeters',...
                  'Position',[1 1 Xfig Yfig],...
                  'PaperPosition',[1 1 Xfig Yfig],...
                  'PaperUnits','centimeters');
%
        m_proj('mercator',...
             'lon',[lonmin lonmax],...
             'lat',[latmin latmax]);
        h2=m_contour(lon,lat,zeta,[zmin:dz:zmax],'k');
%        shading flat
%        colorbar
        hold on
%
%  Select the proper eddies to plot
%
        ID_now=ID_good(teddy_start<=time & teddy_end>=time);
%
        for i=1:length(ID_now)
%
% Read 1 eddy
%
          eddy_indx=find(ID_all==ID_now(i));
          time_eddy=time_all(eddy_indx);
          lon_eddy=lon_all(eddy_indx);
          lat_eddy=lat_all(eddy_indx);
          Vort_eddy=Vort_all(eddy_indx);
          Radius_eddy=Radius_all(eddy_indx);
          U_eddy=U_all(eddy_indx);
          V_eddy=V_all(eddy_indx);
%    
          if sign(mean(Vort_eddy))==sign(mean(lat_eddy))
%
% This should be a cyclone : blue
%
            eddycol='b'; 
          else
%
% This should be an anticyclone : red
%
            eddycol='r'; 
          end
%
% Plot a line with the track of the eddy
%
          h3=m_plot(lon_eddy,lat_eddy,eddycol);
%          set(h3,'LineWidth',2)
%
% Plot the current status of the eddy
%
          n=find(time_eddy==time);
          Radi=(180/pi)*Radius_eddy(n)/(Re*cos(lat_eddy(n)*pi/180)) ;
          h4=m_ellipse(Radi,Radi,0,lon_eddy(n),lat_eddy(n),eddycol); 
          m_plot(lon_eddy(n),lat_eddy(n),'o',...
	'MarkerEdgeColor',eddycol,'MarkerFaceColor',eddycol,'MarkerSize',5);
          set(h4,'lineWidth',2);
          h5=m_text(lon_eddy(n),lat_eddy(n),num2str(ID_now(i)));

          cff=10;
          h6=m_quiver(lon_eddy(n),lat_eddy(n),cff*U_eddy(n),cff*V_eddy(n),0);
          set(h6,'Color','m','LineWidth',1.5);

        end

        m_contour(lon,lat,h,[500 500],'y');
        m_usercoast(coastfile,'patch',[.9 .9 .9]);
        m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out');
	if isfinite(Yorig)
          title(['zeta [cm] ',datestr(time)])
        else
          title(['zeta [cm] Y ',num2str(Y),' - M ',num2str(M),...
	       ' - tndx ',num2str(tindex)])
	end
        hold off
        fr = fr + 1;
        getframe_fli(fr,fid);
        close(h1)
      end
      close(nc)
    end
  end
end
%
% Get the movies...
%
if anim_mpeg==1
  eval(['!ppmtompeg ../Visualization_tools/inp_ppm2mpeg'])
  eval(['!mv movie.mpg ',moviename,'.mpg']);
end
if anim_gif==1
  eval(['! convert -delay 10 -loop 0 *.ppm ',moviename,'.gif'])
end
if anim_fli==1
  fli_end(fid,[moviename,'.fli']);
else
  clean_ppm('.ppm.list');
end
return
