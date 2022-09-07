function download_NCEP(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
                       NCEP_dir,NCEP_version,Yorig,Get_My_Data,My_NCEP_dir)
%
if nargin < 1
  Ymin=2007;
  Ymax=2008;
  Yorig=1900;
  Mmin=12;
  Mmax=1;
  lonmin=10;
  lonmax=30;
  latmin=-40;
  latmax=-20;
  NCEP_dir='DATA/NCEP_Peru/';
  NCEP_version=2;
  Get_My_Data=0;
  My_NCEP_dir='../NCEP_REA1/';
end
%
% Definitions of names and directories
%
if Get_My_Data ~= 1
  disp(['================='])
  disp(['OPENDAP Procedure'])
  disp(['================='])
%
  disp(['latmax=',num2str(latmax)])
  if NCEP_version==1
%
% Definitions of names and directories for NCEP1
%
    ncep_url='http://nomad1.ncep.noaa.gov:9090/dods/reanalyses/reanalysis-1/';
    catalog={'6hr/grb2d/grb2d' ...
             '6hr/grb2d/grb2d' ...
             '6hr/grb2d/grb2d' ...
             '6hr/grb2d/grb2d' ...
	         '6hr/grb2d/grb2d' ...
	         '6hr/grb2d/grb2d' ...
	         '6hr/grb2d/grb2d' ...
	         '6hr/grb2d/grb2d' ...
	         '6hr/grb2d/grb2d' ...
	         '6hr/grb2d/grb2d' ...
	         '6hr/grb2d/grb2d'};  
    vnames={'landsfc' ...      % surface land-sea mask [1=land; 0=sea] 
            'tmp2m' ...        % 2 m temp. [k]
            'dlwrfsfc' ...     % surface downward long wave flux [w/m^2] 
            'ulwrfsfc' ...     % surface upward long wave flux [w/m^2] 
            'tmpsfc' ...       % surface temp. [k]   		  
	        'dswrfsfc' ...     % surface downward solar radiation flux [w/m^2]
	        'uswrfsfc' ...     % surface upward solar radiation flux [w/m^2]  
	        'pratesfc' ...     % surface precipitation rate [kg/m^2/s] 
	        'ugrd10m' ...      % 10 m u wind [m/s]
	        'vgrd10m' ...      % 10 m v wind [m/s]
	        'spfh2m'};         % 2 m specific humidity [kg/kg]
    level ={'' '' '' '' '' '' '' '' '' '' ''};
%
  elseif NCEP_version==2
%
% Definitions of names and directories for NCEP2
%
    %ncep_url='http://nomad3.ncep.noaa.gov:9090/dods/reanalyses/reanalysis-2/';
    ncep_url='http://nomad1.ncep.noaa.gov:9090/dods/reanalyses/reanalysis-2/';
    catalog={'6hr/flx/flx' ...
             '6hr/flx/flx' ...
             '6hr/flx/flx' ...
             '6hr/flx/flx' ...
	         '6hr/flx/flx' ...
	         '6hr/flx/flx' ...
	         '6hr/flx/flx' ...
	         '6hr/flx/flx' ...
	         '6hr/flx/flx' ...
	         '6hr/flx/flx' ...
	         '6hr/flx/flx'};  
    vnames={'landsfc' ...    % surface land-sea mask [1=land; 0=sea] 
            'tmp2m' ...      % 2 m temp. [k]
            'dlwrfsfc' ...   % surface downward long wave flux [w/m^2] 
            'ulwrfsfc' ...   % surface upward long wave flux [w/m^2] 
            'tmpsfc' ...     % surface temp. [k]   
	        'dswrfsfc' ...   % surface downward solar radiation flux [w/m^2]
	        'uswrfsfc' ...   % surface upward solar radiation flux [w/m^2] 
	        'pratesfc' ...   % surface precipitation rate [kg/m^2/s] 
	        'ugrd10m' ...    % 10 m u wind [m/s]
	        'vgrd10m' ...    % 10 m v wind [m/s]
	        'spfh2m'};       % 2 m specific humidity [kg/kg]
    level ={'' '' '' '' '' '' '' '' '' '' ''};
  else
    error('Wrong NCEP version')
  end
%
elseif Get_My_Data == 1
%
% Definitions of names and directories in the case of ftp
%
  disp(['================='])
  disp(['Direct FTP Procedure'])
  disp(['================='])
 
  if NCEP_version==1
    disp('Use local ncep data NCEP1')
    ncep_url=My_NCEP_dir;
    catalog={'land.sfc.gauss' ...
	     'air.2m.gauss' ...
	     'dlwrf.sfc.gauss' ...
	     'ulwrf.sfc.gauss' ...
	     'skt.sfc.gauss' ... 
	     'dswrf.sfc.gauss' ...
	     'uswrf.sfc.gauss' ...
	     'prate.sfc.gauss' ...
	     'uwnd.10m.gauss' ...
	     'vwnd.10m.gauss' ...
	     'shum.2m.gauss' ...
	     ''};
    vnames={'land'...       % surface land-sea mask [1=land; 0=sea] 
            'air' ...       % 2 m temp. [k]
            'dlwrf' ...     % surface downward long wave flux [w/m^2] 
            'ulwrf' ...     % surface upward long wave flux [w/m^2] 
            'skt' ...       % surface temp. [k]   		  
	        'dswrf' ...     % surface downward solar radiation flux [w/m^2] 
            'uswrf' ...     % surface upward solar radiation flux [w/m^2] 
	        'prate' ...     % surface precipitation rate [kg/m^2/s] 
	        'uwnd' ...      % 10 m u wind [m/s]
	        'vwnd' ...      % 10 m v wind [m/s]
	        'shum'};        % 2 m specific humidity [kg/kg]
    level ={'' '' '' '' '' '' '' '' '' '' ''};
  else
    disp('Use local ncep data NCEP2')
    ncep_url=My_NCEP_dir;
    catalog={'land.sfc.gauss' ...
             'air.2m.gauss' ...
             'dlwrf.sfc.gauss' ...
             'ulwrf.sfc.gauss' ...
             'skt.sfc.gauss' ... 
	         'dswrf.sfc.gauss' ...
	         'uswrf.sfc.gauss' ...
	         'prate.sfc.gauss' ...
	         'uwnd.10m.gauss' ...
	         'vwnd.10m.gauss' ...
	         'shum.2m.gauss' ...
	         ''};
    vnames={'land'...       % surface land-sea mask [1=land; 0=sea] 
            'air' ...       % 2 m temp. [k]
            'dlwrf' ...     % surface upward long wave flux [w/m^2] 
            'ulwrf' ...     % surface downward long wave flux [w/m^2] 
            'skt' ...       % surface temp. [k]   		  
	        'dswrf' ...     % surface downward solar radiation flux [w/m^2] 
	        'uswrf' ...     % surface upward solar radiation flux [w/m^2] 
	        'prate' ...     % surface precipitation rate [kg/m^2/s] 
	        'uwnd' ...      % 10 m u wind [m/s]
	        'vwnd' ...      % 10 m v wind [m/s]
	        'shum'};        % 2 m specific humidity [kg/kg]
    level ={'' '' '' '' '' '' '' '' '' '' ''};  
  end 
end  %endif Get_My_Data

%
%Common OpenDAP FTP
%

disp([' '])
disp(['Get NCEP data from ',num2str(Ymin),' to ',num2str(Ymax)])
disp(['From ',ncep_url]);
disp([' '])
disp(['Minimum Longitude: ',num2str(lonmin)])
disp(['Maximum Longitude: ',num2str(lonmax)])
disp(['Minimum Latitude: ',num2str(latmin)])
disp(['Maximum Latitude: ',num2str(latmax)])
disp([' '])
%
% Create the directory
%
disp(['Making output data directory ',NCEP_dir])
eval(['!mkdir ',NCEP_dir])
% End Common OpenDap FTP 
%-----------------------

%
% Global loop on variable names
%
for k=1:length(vnames)
  disp(['=========================='])
  disp(['VNAME IS ',char(vnames(k))]);
  disp(['=========================='])
%
% Time unit (and time in case of opendap) section
%
  if Get_My_Data~=1
    disp(['------'])
    disp(['Get time units and time:  Get_My_Data is OFF '])
    disp(['------'])  
    x=loaddap('-A -e +v',[ncep_url,char(catalog(k))]);
    if verLessThan('matlab','7.14')
      if (dods_err==1)
        error(dods_err_msg)
      end
    end
% check time unit (APDRC dataset are daily)
    if isempty(x.time.units)
      error('No time unit found');
    end
    eval(['Tunits=x.time.units;']);  
    time0=readdap([ncep_url,char(catalog(k))],'time',[]);
    if findstr('day',Tunits)
      time_scale = 1;
    elseif findstr('hour',Tunits)
      time_scale = 1/24;
    else
      error('Time units is not days or hours. I assume NCEP datasets are all daily ??! ');
    end
% 
  else %Get_My_Data~=1
%
    if k==1  %Read time only one time
      disp(['------'])
      disp(['Get time units only :  Get_My_Data is OFF '])
      disp(['Read file: ',[char(ncep_url),'prate.sfc.gauss.1995.nc or whatever', ...
		   ' NCEP file']])
      disp(['------'])    
      nc=netcdf([char(ncep_url),'prate.sfc.gauss.1995.nc']);
      xmi= nc{'time'}.units(:);
      close(nc)
      if isempty(xmi)
        error('No time unit found');
      end
      Tunits=xmi;
      if findstr('day',Tunits)
        time_scale = 1;
      elseif findstr('hour',Tunits)
        time_scale = 1/24;
      else
        error('Time units is not days or hours. I assume NCEP datasets are all daily ??! ');
      end
    end  %k==1
  end    %Get_My_Data~=1
%
% Subgrid section :Find a subset of the NCEP grid
%
  if k==1
    disp(['=========================='])
    disp(['GET  SUBGRID time only k=1']);
    disp(['USE VARIABLE: ',char(vnames(k))  ])
    disp(['=========================='])

%
    [i1min,i1max,i2min,i2max,i3min,i3max,jrange,jmin,jmax,lon,lat]=...
        get_NCEP_grid([ncep_url,char(catalog(k))],...
                      lonmin,lonmax,latmin,latmax,Get_My_Data);

  end
  if k==1
    if Get_My_Data~=1
      disp('GET LAND MASK');
      tndx = 1;
      trange = '[1:1]';
      extract_NCEP(NCEP_dir,ncep_url,char(catalog(k)),char(vnames(k)),Ymin,Mmin,...
                   lon,lat,tndx,0,...
                   trange,char(level(k)),jrange,...
                   i1min,i1max,i2min,i2max,i3min,i3max,...
                   jmin,jmax,Yorig,Get_My_Data) 
    elseif Get_My_Data==1
      disp(['=========================='])
      disp(['Get the Land Mask tindex = 1']);
      disp(['In case of Get_My_Data ON']);
      disp(['Get the Land Mask by using extract_NCEP_Mask_Mydata']);
      disp(['Execute extract_NCEP_Mask_Mydata'])
      disp([' ']) 
      extract_NCEP_Mask_Mydata(NCEP_dir,ncep_url,char(catalog(k)),...
		               Ymin,Mmin,...
                               lon,lat,level,...
                               i1min,i1max,i2min,i2max,i3min,i3max,...
                               jmin,jmax)

    end  %Get_My_Data
  else %k==1
%
% Loop on the years
%
    for Y=Ymin:Ymax
      disp(['=========================='])
      disp(['Processing year: ',num2str(Y)])
      disp(['=========================='])
      if Get_My_Data==1    
%Get the time indice to get into  monthly file
%-------------------
        nc=netcdf([ncep_url,char(catalog(k)),'.',num2str(Y),'.nc']);
        time0=nc{'time'}(:);
        close(nc)
%===================================
%in case of Get_My_Data~=1, time is already loaded 
%in the time unit section previoulsly 
%=====================================
      end
%
%Convertion of time and Yorig section
%
%==========================================================
%Convert time relative to Yorig
%Here they are relative to start
% NCEP reanalysis 1 and 2 from NOMADS : time origine is "days since 1-1-1 00:00:00"
% NCEP reanalysis 1 from FTP: time origine is "days since 1-1-1 00:00:00"
% NCEP reanalysis 2 from FTP: time origine is "days since 1800-1-1 00:00:00"
%===========================================================
%
      if Get_My_Data ~= 1 % OpenDAP
        if NCEP_version == 1            
          disp(['NCEP_version is ',num2str(NCEP_version)])
          startime = [1,1,1,0,0,0]; %[year, month, day, hour, minute, second]
        elseif NCEP_version ==  2
          disp(['NCEP_version is ',num2str(NCEP_version)])
          startime = [1,1,1,0,0,0]; 
        end
      else               % FTP
        if NCEP_version ==  1
          disp(['NCEP_version is ',num2str(NCEP_version)])
          startime = [1,1,1,0,0,0];
        elseif NCEP_version ==  2
          disp(['NCEP_version is ',num2str(NCEP_version)])
          startime = [1800,1,1,0,0,0]; 
        end
      end
%
      time = time0.*time_scale;
      TIME_OFFSET=(mjd(Yorig,1,1,0)-mjd(startime(1),startime(2),startime(3), ...
				  startime(4))); 
      if Get_My_Data~= 1 % OpenDAP
        time = time - TIME_OFFSET -2; 
%                             This is time in days from Yorig
%                             In case of OpenDap DATA
%                             we have to remove at the end to be OK with the date
      else               % FTP
        time = time - TIME_OFFSET  ;
%                             This is time in days from Yorig
%                             In case of FTP DATA
%                             we do not need to remove at the end
      end
%
      [year,month,days,hour,min,sec]=datevec(time+datenum(Yorig,1,1));
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Loop on the months
%
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
        disp(['  Processing month: ',num2str(M)])
        recipe_file = [NCEP_dir,char(vnames(k)),'_Y',num2str(Y),'M',num2str(M),'.nc'];
        if exist(recipe_file)
          disp(['    Warning : file ',recipe_file,' already exists. Press ''enter'' to continue']);
        end
%
% Get the time indices for this month and year
%
        tndx=intersect(find(month==M),find(year==Y));
        trange=['[',num2str(tndx(1)-1),':',num2str(tndx(end)-1),']'];
        disp(['TRANGE=',num2str(trange)]);
%
% Get the subset
%
        extract_NCEP(NCEP_dir,ncep_url,char(catalog(k)),...
	             char(vnames(k)),Y,M,...
                     lon,lat,tndx,time(tndx),...
                     trange,char(level(k)),jrange,...
                     i1min,i1max,i2min,i2max,i3min,i3max,...
                     jmin,jmax,Yorig,Get_My_Data)
      end % end loop month
    end % end loop year
  end %  k==1
end % loop k
%
return
