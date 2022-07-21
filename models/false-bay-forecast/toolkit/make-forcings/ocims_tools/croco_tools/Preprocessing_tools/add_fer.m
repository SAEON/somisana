function add_fer(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,fer]=add_fer(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add iron (mMol Fe m-3) in a CROCO climatology file
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
%    [longrd,latgrd,fer] : surface field to plot (as an illustration)
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
zfer=nc{'Z'}(:);
kmax=max(find(zfer<hmax))-1;
zfer=zfer(1:kmax);
close(nc)
%
% open the OA file  
% 
if (makeoa)
  disp('Add_fer: creating variables and attributes for the OA file')
  nc=netcdf(oafile,'write');
%%  redef(nc);
  nc('fer_time') = length(t);
  nc{'fer_time'} = ncdouble('fer_time') ;
  nc('Zfer') = length(zfer);
  nc{'Zfer'} = ncdouble('Zfer') ;
  nc{'FER'} = ncdouble('fer_time','Zfer','eta_rho','xi_rho') ;
%
  nc{'fer_time'}.long_name = ncchar('time for iron');
  nc{'fer_time'}.long_name = 'time for iron';
  nc{'fer_time'}.units = ncchar('day');
  nc{'fer_time'}.units = 'day';
  if cycle~=0
    nc{'fer_time'}.cycle_length = cycle;
  end
%
  nc{'Zfer'}.long_name = ncchar('Depth for FER');
  nc{'Zfer'}.long_name = 'Depth for FER';
  nc{'Zfer'}.units = ncchar('m');
  nc{'Zfer'}.units = 'm';
%
  nc{'FER'}.long_name = ncchar('Iron');
  nc{'FER'}.long_name = 'Iron';
  nc{'FER'}.units = ncchar('uMol Fe m-3');
  nc{'FER'}.units = 'uMol Fe m-3';
  nc{'FER'}.fields = ncchar('FER, scalar, series');
  nc{'FER'}.fields = 'FER, scalar, series';
%
%%  endef(nc);
%
% record deth and time and close
%
  nc{'fer_time'}(:)=t*30; % if time in month in the dataset !!!
  nc{'Zfer'}(:)=zfer;
  close(nc)
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_fer: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  nc=netcdf(climfile,'write');
%%  redef(nc);
  nc('fer_time') = length(t);;
  nc{'fer_time'} = ncdouble('fer_time') ;
  nc{'FER'} = ncdouble('fer_time','s_rho','eta_rho','xi_rho') ;
%
  nc{'fer_time'}.long_name = ncchar('time for iron');
  nc{'fer_time'}.long_name = 'time for iron';
  nc{'fer_time'}.units = ncchar('day');
  nc{'fer_time'}.units = 'day';
  if cycle~=0
    nc{'fer_time'}.cycle_length = cycle;
  end
%
  nc{'FER'}.long_name = ncchar('Iron');
  nc{'FER'}.long_name = 'Iron';
  nc{'FER'}.units = ncchar('uMol Fe m-3');
  nc{'FER'}.units = 'uMol Fe m-3';
  nc{'FER'}.fields = ncchar('FER, scalar, series');
  nc{'FER'}.fields = 'FER, scalar, series';
%
%%  endef(nc);
%
% record the time and close
%
  nc{'fer_time'}(:)=t*30; % if time in month in the dataset !!!
  close(nc)
end
%
% Same thing for the Initial file
%
%disp('Add_fer: creating variables and attributes for the Initial file')
%
% open the clim file  
% 
%nc=netcdf(inifile,'write');
%redef(nc);
%nc{'FER'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
%
%nc{'FER'}.long_name = ncchar('Nitrate');
%nc{'FER'}.long_name = 'Nitrate';
%nc{'FER'}.units = ncchar('mMol N m-3');
%nc{'FER'}.units = 'mMol N m-3';
%
%endef(nc);
%close(nc)

return
