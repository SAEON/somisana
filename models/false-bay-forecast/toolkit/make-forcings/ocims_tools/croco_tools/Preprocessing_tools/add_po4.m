function add_po4(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,po4]=add_po4(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add phosphate (mMol P m-3) in a CROCO climatology file
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
%    [longrd,latgrd,po4] : surface field to plot (as an illustration)
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
zpo4=nc{'Z'}(:);
kmax=max(find(zpo4<hmax))-1;
zpo4=zpo4(1:kmax);
close(nc)
%
% open the OA file  
% 
if (makeoa)
  disp('Add_po4: creating variables and attributes for the OA file')
  nc=netcdf(oafile,'write');
%%  redef(nc);
  nc('po4_time') = length(t);
  nc{'po4_time'} = ncdouble('po4_time') ;
  nc('Zpo4') = length(zpo4);
  nc{'Zpo4'} = ncdouble('Zpo4') ;
  nc{'PO4'} = ncdouble('po4_time','Zpo4','eta_rho','xi_rho') ;
%
  nc{'po4_time'}.long_name = ncchar('time for phosphate');
  nc{'po4_time'}.long_name = 'time for phosphate';
  nc{'po4_time'}.units = ncchar('day');
  nc{'po4_time'}.units = 'day';
  if cycle~=0
    nc{'po4_time'}.cycle_length = cycle;
  end
%
  nc{'Zpo4'}.long_name = ncchar('Depth for PO4');
  nc{'Zpo4'}.long_name = 'Depth for PO4';
  nc{'Zpo4'}.units = ncchar('m');
  nc{'Zpo4'}.units = 'm';
%
  nc{'PO4'}.long_name = ncchar('Phosphate');
  nc{'PO4'}.long_name = 'Phosphate';
  nc{'PO4'}.units = ncchar('mMol P m-3');
  nc{'PO4'}.units = 'mMol P m-3';
  nc{'PO4'}.fields = ncchar('PO4, scalar, series');
  nc{'PO4'}.fields = 'PO4, scalar, series';
%
%%  endef(nc);
%
% record deth and time and close
%
  nc{'po4_time'}(:)=t*30; % if time in month in the dataset !!!
  nc{'Zpo4'}(:)=zpo4;
  close(nc)
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_po4: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  nc=netcdf(climfile,'write');
%%  redef(nc);
  nc('po4_time') = length(t);;
  nc{'po4_time'} = ncdouble('po4_time') ;
  nc{'PO4'} = ncdouble('po4_time','s_rho','eta_rho','xi_rho') ;
%
  nc{'po4_time'}.long_name = ncchar('time for phosphate');
  nc{'po4_time'}.long_name = 'time for phosphate';
  nc{'po4_time'}.units = ncchar('day');
  nc{'po4_time'}.units = 'day';
  if cycle~=0
    nc{'po4_time'}.cycle_length = cycle;
  end
%
  nc{'PO4'}.long_name = ncchar('Phosphate');
  nc{'PO4'}.long_name = 'Phosphate';
  nc{'PO4'}.units = ncchar('mMol P m-3');
  nc{'PO4'}.units = 'mMol P m-3';
  nc{'PO4'}.fields = ncchar('PO4, scalar, series');
  nc{'PO4'}.fields = 'PO4, scalar, series';
%
%%  endef(nc);
%
% record the time and close
%
  nc{'po4_time'}(:)=t*30; % if time in month in the dataset !!!
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
