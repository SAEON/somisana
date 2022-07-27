function add_dic(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,dic]=add_dic(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add DIC (mMol C m-3) in a CROCO climatology file
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
%    [longrd,latgrd,dic] : surface field to plot (as an illustration)
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
zdic=nc{'Z'}(:);
kmax=max(find(zdic<hmax))-1;
zdic=zdic(1:kmax);
close(nc)
%
% open the OA file  
% 
if (makeoa)
  disp('Add_dic: creating variables and attributes for the OA file')
  nc=netcdf(oafile,'write');
%%  redef(nc);
  nc('dic_time') = length(t);
  nc{'dic_time'} = ncdouble('dic_time') ;
  nc('Zdic') = length(zdic);
  nc{'Zdic'} = ncdouble('Zdic') ;
  nc{'DIC'} = ncdouble('dic_time','Zdic','eta_rho','xi_rho') ;
%
  nc{'dic_time'}.long_name = ncchar('time for DIC');
  nc{'dic_time'}.long_name = 'time for DIC';
  nc{'dic_time'}.units = ncchar('day');
  nc{'dic_time'}.units = 'day';
  if cycle~=0
    nc{'dic_time'}.cycle_length = cycle;
  end
%
  nc{'Zdic'}.long_name = ncchar('Depth for DIC');
  nc{'Zdic'}.long_name = 'Depth for DIC';
  nc{'Zdic'}.units = ncchar('m');
  nc{'Zdic'}.units = 'm';
%
  nc{'DIC'}.long_name = ncchar('DIC');
  nc{'DIC'}.long_name = 'DIC';
  nc{'DIC'}.units = ncchar('mMol C m-3');
  nc{'DIC'}.units = 'mMol C m-3';
  nc{'DIC'}.fields = ncchar('DIC, scalar, series');
  nc{'DIC'}.fields = 'DIC, scalar, series';
%
%%  endef(nc);
%
% record deth and time and close
%
  nc{'dic_time'}(:)=t*30; % if time in month in the dataset !!!
  nc{'Zdic'}(:)=zdic;
  close(nc)
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_dic: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  nc=netcdf(climfile,'write');
%%  redef(nc);
  nc('dic_time') = length(t);;
  nc{'dic_time'} = ncdouble('dic_time') ;
  nc{'DIC'} = ncdouble('dic_time','s_rho','eta_rho','xi_rho') ;
%
  nc{'dic_time'}.long_name = ncchar('time for DIC');
  nc{'dic_time'}.long_name = 'time for DIC';
  nc{'dic_time'}.units = ncchar('day');
  nc{'dic_time'}.units = 'day';
  if cycle~=0
    nc{'dic_time'}.cycle_length = cycle;
  end
%
  nc{'DIC'}.long_name = ncchar('DIC');
  nc{'DIC'}.long_name = 'DIC';
  nc{'DIC'}.units = ncchar('mMol C m-3');
  nc{'DIC'}.units = 'mMol C m-3';
  nc{'DIC'}.fields = ncchar('DIC, scalar, series');
  nc{'DIC'}.fields = 'DIC, scalar, series';
%
%%  endef(nc);
%
% record the time and close
%
  nc{'dic_time'}(:)=t*30; % if time in month in the dataset !!!
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
