function add_talk(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,talk]=add_talk(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add talk (mMol P m-3) in a CROCO climatology file
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
%    [longrd,latgrd,talk] : surface field to plot (as an illustration)
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
ztalk=nc{'Z'}(:);
kmax=max(find(ztalk<hmax))-1;
ztalk=ztalk(1:kmax);
close(nc)
%
% open the OA file  
% 
if (makeoa)
  disp('Add_talk: creating variables and attributes for the OA file')
  nc=netcdf(oafile,'write');
%%  redef(nc);
  nc('talk_time') = length(t);
  nc{'talk_time'} = ncdouble('talk_time') ;
  nc('Ztalk') = length(ztalk);
  nc{'Ztalk'} = ncdouble('Ztalk') ;
  nc{'TALK'} = ncdouble('talk_time','Ztalk','eta_rho','xi_rho') ;
%
  nc{'talk_time'}.long_name = ncchar('time for TALK');
  nc{'talk_time'}.long_name = 'time for TALK';
  nc{'talk_time'}.units = ncchar('day');
  nc{'talk_time'}.units = 'day';
  if cycle~=0
    nc{'talk_time'}.cycle_length = cycle;
  end
%
  nc{'Ztalk'}.long_name = ncchar('Depth for TALK');
  nc{'Ztalk'}.long_name = 'Depth for TALK';
  nc{'Ztalk'}.units = ncchar('m');
  nc{'Ztalk'}.units = 'm';
%
  nc{'TALK'}.long_name = ncchar('TALK');
  nc{'TALK'}.long_name = 'TALK';
  nc{'TALK'}.units = ncchar('mMol C m-3');
  nc{'TALK'}.units = 'mMol C m-3';
  nc{'TALK'}.fields = ncchar('TALK, scalar, series');
  nc{'TALK'}.fields = 'TALK, scalar, series';
%
%%  endef(nc);
%
% record deth and time and close
%
  nc{'talk_time'}(:)=t*30; % if time in month in the dataset !!!
  nc{'Ztalk'}(:)=ztalk;
  close(nc)
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_talk: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  nc=netcdf(climfile,'write');
%%  redef(nc);
  nc('talk_time') = length(t);;
  nc{'talk_time'} = ncdouble('talk_time') ;
  nc{'TALK'} = ncdouble('talk_time','s_rho','eta_rho','xi_rho') ;
%
  nc{'talk_time'}.long_name = ncchar('time for TALK');
  nc{'talk_time'}.long_name = 'time for TALK';
  nc{'talk_time'}.units = ncchar('day');
  nc{'talk_time'}.units = 'day';
  if cycle~=0
    nc{'talk_time'}.cycle_length = cycle;
  end
%
  nc{'TALK'}.long_name = ncchar('TALK');
  nc{'TALK'}.long_name = 'TALK';
  nc{'TALK'}.units = ncchar('mMol C m-3');
  nc{'TALK'}.units = 'mMol C m-3';
  nc{'TALK'}.fields = ncchar('TALK, scalar, series');
  nc{'TALK'}.fields = 'TALK, scalar, series';
%
%%  endef(nc);
%
% record the time and close
%
  nc{'talk_time'}(:)=t*30; % if time in month in the dataset !!!
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
