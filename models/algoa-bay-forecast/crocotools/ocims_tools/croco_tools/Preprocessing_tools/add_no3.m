function add_no3(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,no3]=add_no3(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  Add nitrate (mMol N m-3) in a CROCO climatology file
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
%    [longrd,latgrd,no3] : surface field to plot (as an illustration)
% 
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
t;
close(nc)
nc=netcdf(ann_datafile,'r');
zno3=nc{'Z'}(:);
kmax=max(find(zno3<hmax))-1;
zno3=zno3(1:kmax);
%disp('Size zno3=')
size(zno3);
close(nc)
%
% open the OA file  
% 
if (makeoa)
  disp('Add_no3: creating variables and attributes for the OA file')
  nc=netcdf(oafile,'write');
 % redef(nc);
  
  %Create Dimensions
  nc('no3_time') = length(t);
  %Create Variable
  nc{'no3_time'} = ncdouble('no3_time') ;
%
%%
%
  %Create Dimensions
  nc('Zno3') = length(zno3);  
  %Create Variable
  nc{'Zno3'} = ncdouble('Zno3') ;
%
%%
%    
  %Create Variable
  nc{'NO3'} = ncdouble('no3_time','Zno3','eta_rho','xi_rho') ;
%
%%
%    
  %Create Attribute
  
  nc{'no3_time'}.long_name = ncchar('time for nitrate');
  nc{'no3_time'}.long_name = 'time for nitrate';
  nc{'no3_time'}.units = ncchar('day');
  nc{'no3_time'}.units = 'day';
  if cycle~=0
    nc{'no3_time'}.cycle_length = cycle;
  end
%%%
  nc{'Zno3'}.long_name = ncchar('Depth for NO3');
  nc{'Zno3'}.long_name = 'Depth for NO3';
  nc{'Zno3'}.units = ncchar('m');
  nc{'Zno3'}.units = 'm';
%%%
  nc{'NO3'}.long_name = ncchar('Nitrate');
  nc{'NO3'}.long_name = 'Nitrate';
  nc{'NO3'}.units = ncchar('mMol N m-3');
  nc{'NO3'}.units = 'mMol N m-3';
  nc{'NO3'}.fields = ncchar('NO3, scalar, series');
  nc{'NO3'}.fields = 'NO3, scalar, series';
%%%
%%  endef(nc);
%
%% Write variables
%% record depth and time and close
%
  nc{'no3_time'}(:)=t*30; % if time in month in the dataset !!!
  nc{'Zno3'}(:)=zno3;
  close(nc)
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_no3: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  nc=netcdf(climfile,'write');
 % redef(nc);
  nc('no3_time') = length(t);;
  nc{'no3_time'} = ncdouble('no3_time') ;
  nc{'NO3'} = ncdouble('no3_time','s_rho','eta_rho','xi_rho') ;
%
  nc{'no3_time'}.long_name = ncchar('time for nitrate');
  nc{'no3_time'}.long_name = 'time for nitrate';
  nc{'no3_time'}.units = ncchar('day');
  nc{'no3_time'}.units = 'day';
  if cycle~=0
    nc{'no3_time'}.cycle_length = cycle;
  end
%
  nc{'NO3'}.long_name = ncchar('Nitrate');
  nc{'NO3'}.long_name = 'Nitrate';
  nc{'NO3'}.units = ncchar('mMol N m-3');
  nc{'NO3'}.units = 'mMol N m-3';
  nc{'NO3'}.fields = ncchar('NO3, scalar, series');
  nc{'NO3'}.fields = 'NO3, scalar, series';
%
%%  endef(nc);
%
% record the time and close
%
  nc{'no3_time'}(:)=t*30; % if time in month in the dataset !!!
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
