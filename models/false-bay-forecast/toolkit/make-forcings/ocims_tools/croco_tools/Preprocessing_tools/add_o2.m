function add_o2(oafile,climfile,inifile,gridfile,month_datafile,...
                 ann_datafile,cycle,makeoa,makeclim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,o2]=add_o2(climfile,gridfile,...
%                                       month_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add oxygen (mMol 0 m-3) in a CROCO climatology file
%  take monthly data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    
%    climfile      : croco climatology file to process (netcdf)
%    gridfile      : croco grid file (netcdf)
%    month_datafile : regular longitude - latitude - z monthly data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,o2] : surface field to plot (as an illustration)
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
nc=netcdf(month_datafile,'r');
t=nc{'T'}(:);
close(nc)
nc=netcdf(ann_datafile,'r');
zo2=nc{'Z'}(:);
kmax=max(find(zo2<hmax))-1;
zo2=zo2(1:kmax);
close(nc)
%
% open the OA file  
% 
if (makeoa)
  disp('Add_o2: creating variables and attributes for the OA file')
  nc=netcdf(oafile,'write');
%%  redef(nc);
  nc('o2_time') = length(t);
  nc{'o2_time'} = ncdouble('o2_time') ;
  nc('Zo2') = length(zo2);
  nc{'Zo2'} = ncdouble('Zo2') ;
  nc{'O2'} = ncdouble('o2_time','Zo2','eta_rho','xi_rho') ;
%
  nc{'o2_time'}.long_name = ncchar('time for oxygen');
  nc{'o2_time'}.long_name = 'time for oxygen';
  nc{'o2_time'}.units = ncchar('day');
  nc{'o2_time'}.units = 'day';
  if cycle~=0
    nc{'o2_time'}.cycle_length = cycle;
  end
%
  nc{'Zo2'}.long_name = ncchar('Depth for O2');
  nc{'Zo2'}.long_name = 'Depth for O2';
  nc{'Zo2'}.units = ncchar('m');
  nc{'Zo2'}.units = 'm';
%
  nc{'O2'}.long_name = ncchar('Oxygen');
  nc{'O2'}.long_name = 'Oxygen';
  nc{'O2'}.units = ncchar('mMol O m-3');
  nc{'O2'}.units = 'mMol O m-3';
  nc{'O2'}.fields = ncchar('O2, scalar, series');
  nc{'O2'}.fields = 'O2, scalar, series';
%
%%  endef(nc);
%
% record depth and time and close
%
  nc{'o2_time'}(:)=t*30;  % ojo aqui quite *30 % if time in month in the dataset !!!
  nc{'Zo2'}(:)=squeeze(zo2);
  close(nc)
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_o2: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  nc=netcdf(climfile,'write');
 %% redef(nc);
  nc('o2_time') = length(t);
  nc{'o2_time'} = ncdouble('o2_time') ;
  nc{'O2'} = ncdouble('o2_time','s_rho','eta_rho','xi_rho') ;
%
  nc{'o2_time'}.long_name = ncchar('time for oxygen');
  nc{'o2_time'}.long_name = 'time for oxygen';
  nc{'o2_time'}.units = ncchar('day');
  nc{'o2_time'}.units = 'day';
  if cycle~=0
    nc{'o2_time'}.cycle_length = cycle;
  end
%
  nc{'O2'}.long_name = ncchar('Oxygen');
  nc{'O2'}.long_name = 'Oxygen';
  nc{'O2'}.units = ncchar('mMol O m-3');
  nc{'O2'}.units = 'mMol O m-3';
  nc{'O2'}.fields = ncchar('O2, scalar, series');
  nc{'O2'}.fields = 'O2, scalar, series';
%
%%  endef(nc);
%
% record the time and close
%
  nc{'o2_time'}(:,:)=t*30; % if time in month in the dataset !!!
  close(nc)
end

return
