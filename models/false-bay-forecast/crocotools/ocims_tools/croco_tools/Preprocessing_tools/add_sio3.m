function add_sio3(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,sio3]=add_sio3(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add silicate (mMol Si m-3) in a CROCO climatology file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    
%    climfile      : croco climatology file to process (netcdf)
%    gridfile      : croco grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,SiO3] : surface field to plot (as an illustration)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Read in the grid
%
nc=netcdf(gridfile,'r');
hmax=max(max(nc{'h'}(:)));
close(nc);
%
% read in the datafiles 
%
nc=netcdf(seas_datafile,'r');
t=nc{'T'}(:);
close(nc)
nc=netcdf(ann_datafile,'r');
zsi=nc{'Z'}(:);
kmax=max(find(zsi<hmax))-1;
zsi=zsi(1:kmax);
close(nc)
%
% open the OA file  
% 
if (makeoa)
  disp('Add_sio3: creating variables and attributes for the OA file')
  nc=netcdf(oafile,'write');
%%  redef(nc);
  nc('si_time') = length(t);
  nc{'si_time'} = ncdouble('si_time') ;
  nc('Zsi') = length(zsi);
  nc{'Zsi'} = ncdouble('Zsi') ;
  nc{'Si'} = ncdouble('si_time','Zsi','eta_rho','xi_rho') ;
%
  nc{'si_time'}.long_name = ncchar('time for silicate');
  nc{'si_time'}.long_name = 'time for silicate';
  nc{'si_time'}.units = ncchar('day');
  nc{'si_time'}.units = 'day';
  if cycle~=0
    nc{'si_time'}.cycle_length = cycle;
  end
%
  nc{'Zsi'}.long_name = ncchar('Depth for Si');
  nc{'Zsi'}.long_name = 'Depth for Si';
  nc{'Zsi'}.units = ncchar('m');
  nc{'Zsi'}.units = 'm';
%
  nc{'Si'}.long_name = ncchar('Silicate');
  nc{'Si'}.long_name = 'Silicate';
  nc{'Si'}.units = ncchar('mMol Si m-3');
  nc{'Si'}.units = 'mMol Si m-3';
  nc{'Si'}.fields = ncchar('Si, scalar, series');
  nc{'Si'}.fields = 'Si, scalar, series';
%
%%  endef(nc);
%
% record deth and time and close
%
  nc{'si_time'}(:)=t*30; % if time in month in the dataset !!!
  nc{'Zsi'}(:)=zsi;
  close(nc)
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_sio3: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  nc=netcdf(climfile,'write');
%%  redef(nc);
  nc('si_time') = length(t);;
  nc{'si_time'} = ncdouble('si_time') ;
  nc{'Si'} = ncdouble('si_time','s_rho','eta_rho','xi_rho') ;
%
  nc{'si_time'}.long_name = ncchar('time for silicate');
  nc{'si_time'}.long_name = 'time for silicate';
  nc{'si_time'}.units = ncchar('day');
  nc{'si_time'}.units = 'day';
  if cycle~=0
    nc{'si_time'}.cycle_length = cycle;
  end
%
  nc{'Si'}.long_name = ncchar('Silicate');
  nc{'Si'}.long_name = 'Silicate';
  nc{'Si'}.units = ncchar('mMol Si m-3');
  nc{'Si'}.units = 'mMol Si m-3';
  nc{'Si'}.fields = ncchar('Si, scalar, series');
  nc{'Si'}.fields = 'Si, scalar, series';
%
%%  endef(nc);
%
% record the time and close
%
  nc{'si_time'}(:)=t*30; % if time in month in the dataset !!!
  close(nc)
end
%
% Same thing for the Initial file
%
%disp('Add_no3: creating variables and attributes for the Initial file')
%
% open the clim file  
% 
%nc=netcdf(inifile,'write');
%redef(nc);
%nc{'NO3'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
%
%nc{'NO3'}.long_name = ncchar('Nitrate');
%nc{'NO3'}.long_name = 'Nitrate';
%nc{'NO3'}.units = ncchar('mMol N m-3');
%nc{'NO3'}.units = 'mMol N m-3';
%
%endef(nc);
%close(nc)

return
