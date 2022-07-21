function download_CFSR(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
                       NCEP_dir,NCEP_version,Yorig,Get_My_Data,My_NCEP_dir)
%
%clear all
%close all
if nargin < 1
  Ymin=2006;
  Ymax=2006;
  Yorig=1900;
  Mmin=6;
  Mmax=6;
  lonmin=16;
  lonmax=19;
  latmin=-34;
  latmax=-32;
  NCEP_dir='DATA/CFSR/';
  NCEP_version=3;
  Get_My_Data=0;
  My_NCEP_dir='../CFSR/';
end
%
% Definitions of names and directories
%
if NCEP_version==3
%
% Definitions of names and directories for NCEP1
%
%ncep_url='http://nomads.ncdc.noaa.gov/thredds/dodsC/modeldata/cmd_flxf/1979/197901/19790101/flxf00.gdas.1979010100.grb2';
  ncep_url='http://nomads.ncdc.noaa.gov/thredds/dodsC/modeldata/cmd_flxf/';
  ncep_url='/home/gilesfearon/hex/oceanography/CFSR_GLOBAL/';
  vnames={'Land_cover_1land_2sea' ...    % surface land-sea mask [1=land; 0=sea]
      'Temperature_height_above_ground' ...      % 2 m temp. [k]
      'Downward_Long-Wave_Rad_Flux' ...   % surface downward long wave flux [w/m^2]
      'Upward_Long-Wave_Rad_Flux_surface'   ...   % surface upward long wave flux [w/m^2]
      'Temperature_surface' ...     % surface temp. [k]
      'Downward_Short-Wave_Rad_Flux_surface' ...   % surface downward solar radiation flux [w/m^2]
      'Upward_Short-Wave_Rad_Flux_surface' ...   % surface upward solar radiation flux [w/m^2]
      'Precipitation_rate' ...   % surface precipitation rate [kg/m^2/s]
      'U-component_of_wind' ...    % 10 m u wind [m/s]
      'V-component_of_wind' ...    % 10 m v wind [m/s]
      'Specific_humidity'};       % 2 m specific humidity [kg/kg]

  vnames2={'Land_cover_1land_2sea' ...    % surface land-sea mask [1=land; 0=sea]
      'Temperature_height_above_ground' ...      % 2 m temp. [k]
      'Downward_Long_2dWave_Rad_Flux' ...   % surface downward long wave flux [w/m^2]
      'Upward_Long_2dWave_Rad_Flux_surface' ...   % surface upward longwave flux [w/m^2]
      'Temperature_surface' ...     % surface temp. [k]
      'Downward_Short_2dWave_Rad_Flux_surface' ...   % surface downward solar radiation flux [w/m^2]
      'Upward_Short_2dWave_Rad_Flux_surface' ...   % surface upward solar radiation flux [w/m^2]
      'Precipitation_rate' ...   % surface precipitation rate [kg/m^2/s]
      'U_2dcomponent_of_wind' ...    % 10 m u wind [m/s]
      'V_2dcomponent_of_wind' ...    % 10 m v wind [m/s]
      'Specific_humidity'};       % 2 m specific humidity [kg/kg]
  %       lan  temp down up temp down up pre  uwind   vwind    sh
  level={'' '[0:0]' '' ''  ''   ''  ''  '' '[0:0]' '[0:0]' '[0:0]'};
else
  error('Wrong NCEP version')
end

%
%Common OpenDAP FTP
%

disp([' '])
disp(['Get CFSR data from ',num2str(Ymin),' to ',num2str(Ymax)])
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
catalog=get_filename_CFSR(Ymin,Mmin,1,0);


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
  disp(['------'])
  disp(['Get time units and time:  Get_My_Data is OFF '])
  disp(['------'])  
  x=loaddap('-A -e +v',[ncep_url,catalog]);
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
  time0=readdap([ncep_url,catalog],'time',[]);
  if findstr('day',Tunits)
    time_scale = 1;
  elseif findstr('hour',Tunits)
    time_scale = 1/24;
  else
    error('Time units is not days or hours. I assume NCEP datasets are all daily ??! ');
  end
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
        get_NCEP_grid([ncep_url,catalog],...
                      lonmin,lonmax,latmin,latmax,Get_My_Data);	     
    lat=flipud(lat);     % latitude inversion in CFSR
%
    disp('GET LAND MASK');
    tndx = 1;
    trange = '[0:0]';
    var=getdap(ncep_url,catalog,char(vnames(k)),...
		 trange,char(level(k)),jrange,...
		 i1min,i1max,i2min,i2max,i3min,i3max);
    var=flipud(var);	 % latitude inversion in CFSR
%
% Write it in a file
%
    write_NCEP([NCEP_dir,char(vnames(k)),'.nc'],...
	       char(vnames(k)),lon,lat,0,var,Yorig)
  else %k==1
%
% Loop on the years
%
    for Y=Ymin:Ymax
      disp(['=========================='])
      disp(['Processing year: ',num2str(Y)])
      disp(['=========================='])
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
% Get the subset
%
       extract_CFSR(NCEP_dir,ncep_url,char(catalog(k)),...
                    char(vnames(k)),char(vnames2(k)),Y,M,...
                    lon,lat,0,0,...
                    trange,char(level(k)),jrange,...
                    i1min,i1max,i2min,i2max,i3min,i3max,...
                    jmin,jmax,Yorig,0)
      end % end loop month
    end % end loop year
  end %  k==1
end % loop k
%
return
