%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A single matlab script to run forcing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Add folder and subfolder to working directory
folder = pwd;
addpath(genpath(folder));
addpath(genpath('/tmp/somisana/current/'));

%Display current folder
disp(folder);

%Move into forcing directory (start.m, crocotools_param.m, grd.nc unique to forecast)
cd croco/forcing/

% Register the toolboxes and configure the environment
start;

% Load the daily parameters of the model date/hdays/fdays etc
config;

% delta_days_gfs needs to be double not string from .env
delta_days_gfs=double(delta_days_gfs);

% check if we can restart from yesterday's run, otherwise if the restart file
% doesn't exist then make an ini file interpolated from the mercator data
rst_filename = RESTART_FILE_PATH

if isfile(rst_filename)
     disp("Restart file exists")
     makeini=0;
else
     disp("Restart file doesn't exists")
     makeini=1;
end

% Run function to create atomspheric forcing (GFS)
make_GFS_ocims(date_now_year,date_now_month,date_now_day,delta_days_gfs,hdays,fdays);

% Run function to create ocean forcing (mercator)
make_OGCM_ocims(date_now_year,date_now_month,date_now_day,hdays,makeini);


