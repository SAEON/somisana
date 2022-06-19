function add_doc(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,doc]=add_doc(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add DOC (mMol C m-3) in a CROCO climatology file
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
%    [longrd,latgrd,doc] : surface field to plot (as an illustration)
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
zdoc=nc{'Z'}(:);
kmax=max(find(zdoc<hmax))-1;
zdoc=zdoc(1:kmax);
close(nc)
%
% open the OA file  
% 
if (makeoa)
  disp('Add_doc: creating variables and attributes for the OA file')
  nc=netcdf(oafile,'write');
%%  redef(nc);
  nc('doc_time') = length(t);
  nc{'doc_time'} = ncdouble('doc_time') ;
  nc('Zdoc') = length(zdoc);
  nc{'Zdoc'} = ncdouble('Zdoc') ;
  nc{'DOC'} = ncdouble('doc_time','Zdoc','eta_rho','xi_rho') ;
%
  nc{'doc_time'}.long_name = ncchar('time for doc');
  nc{'doc_time'}.long_name = 'time for doc';
  nc{'doc_time'}.units = ncchar('day');
  nc{'doc_time'}.units = 'day';
  if cycle~=0
    nc{'doc_time'}.cycle_length = cycle;
  end
%
  nc{'Zdoc'}.long_name = ncchar('Depth for DOC');
  nc{'Zdoc'}.long_name = 'Depth for DOC';
  nc{'Zdoc'}.units = ncchar('m');
  nc{'Zdoc'}.units = 'm';
%
  nc{'DOC'}.long_name = ncchar('DOC');
  nc{'DOC'}.long_name = 'DOC';
  nc{'DOC'}.units = ncchar('mMol C m-3');
  nc{'DOC'}.units = 'mMol C m-3';
  nc{'DOC'}.fields = ncchar('DOC, scalar, series');
  nc{'DOC'}.fields = 'DOC, scalar, series';
%
%%  endef(nc);
%
% record deth and time and close
%
  nc{'doc_time'}(:)=t*30; % if time in month in the dataset !!!
  nc{'Zdoc'}(:)=zdoc;
  close(nc)
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_doc: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  nc=netcdf(climfile,'write');
%%  redef(nc);
  nc('doc_time') = length(t);;
  nc{'doc_time'} = ncdouble('doc_time') ;
  nc{'DOC'} = ncdouble('doc_time','s_rho','eta_rho','xi_rho') ;
%
  nc{'doc_time'}.long_name = ncchar('time for doc');
  nc{'doc_time'}.long_name = 'time for doc';
  nc{'doc_time'}.units = ncchar('day');
  nc{'doc_time'}.units = 'day';
  if cycle~=0
    nc{'doc_time'}.cycle_length = cycle;
  end
%
  nc{'DOC'}.long_name = ncchar('DOC');
  nc{'DOC'}.long_name = 'DOC';
  nc{'DOC'}.units = ncchar('mMol C m-3');
  nc{'DOC'}.units = 'mMol C m-3';
  nc{'DOC'}.fields = ncchar('DOC, scalar, series');
  nc{'DOC'}.fields = 'DOC, scalar, series';
%
%%  endef(nc);
%
% record the time and close
%
  nc{'doc_time'}(:)=t*30; % if time in month in the dataset !!!
  close(nc)
end
%
% Same thing for the Initial file
%
%disp('Add_doc: creating variables and attributes for the Initial file')
%
% open the clim file  
% 
%nc=netcdf(inifile,'write');
%redef(nc);
%nc{'DOC'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
%
%nc{'DOC'}.long_name = ncchar('Nitrate');
%nc{'DOC'}.long_name = 'Nitrate';
%nc{'DOC'}.units = ncchar('mMol N m-3');
%nc{'DOC'}.units = 'mMol N m-3';
%
%endef(nc);
%close(nc)

return
