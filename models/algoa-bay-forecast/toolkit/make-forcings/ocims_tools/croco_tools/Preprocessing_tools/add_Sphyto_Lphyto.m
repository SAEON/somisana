function add_Sphyto_Lphyto(climfile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function add_phyto(climfile);
%
%  Add phytoplancton (mMol N m-3)  in a CROCO climatology file.
%  take the chlorophyll (mg C) from the climatology file and
%  multiply by the ratio chlorophyll / phytoplancton derived
%  from previous simulations.
%
%  phyto = 0.5 * chla
%
%  input:
%    
%    climfile      : croco climatology file to process (netcdf)
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
%  Updated 14/10/14 Andres Sepulveda (DGEO) Octave compatibility
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
theta1=0.1;
theta2=0.4;
%
disp('Add_Sphyto_Lphyto: creating variable and attribute')
%
% open the clim file  
% 
nc=netcdf(climfile,'write');
time= nc{'chla_time'}(:);
cycle= nc{'chla_time'}.cycle_length(:);
tlen=length(time);
%
%%redef(nc);
%
nc('sphyto_time') = tlen;
nc{'sphyto_time'} = ncdouble('sphyto_time') ;
nc{'SPHYTO'} = ncdouble('sphyto_time','s_rho','eta_rho','xi_rho') ;
%
nc{'sphyto_time'}.long_name = ncchar('time for Small Phytoplankton');
nc{'sphyto_time'}.long_name = 'time for Small Phytoplankton';
nc{'sphyto_time'}.units = ncchar('day');
nc{'sphyto_time'}.units = 'day';
if cycle~=0
  nc{'sphyto_time'}.cycle_length = cycle;
end
%
nc('lphyto_time') = tlen;
nc{'lphyto_time'} = ncdouble('lphyto_time') ;
nc{'LPHYTO'} = ncdouble('lphyto_time','s_rho','eta_rho','xi_rho') ;
%
nc{'lphyto_time'}.long_name = ncchar('time for Large Phytoplankton');
nc{'lphyto_time'}.long_name = 'time for Large Phytoplankton';
nc{'lphyto_time'}.units = ncchar('day');
nc{'lphyto_time'}.units = 'day';
if cycle~=0
  nc{'lphyto_time'}.cycle_length = cycle;
end
%
nc{'SPHYTO'}.long_name = ncchar('Small Phytoplankton');
nc{'SPHYTO'}.long_name = 'Small Phytoplankton';
nc{'SPHYTO'}.units = ncchar('mMol N m-3');
nc{'SPHYTO'}.units = 'mMol N m-3';
nc{'SPHYTO'}.fields = ncchar('SPHYTO, scalar, series');
nc{'SPHYTO'}.fields = 'SPHYTO, scalar, series';
%
nc{'LPHYTO'}.long_name = ncchar('Large Phytoplankton');
nc{'LPHYTO'}.long_name = 'Large Phytoplankton';
nc{'LPHYTO'}.units = ncchar('mMol N m-3');
nc{'LPHYTO'}.units = 'mMol N m-3';
nc{'LPHYTO'}.fields = ncchar('LPHYTO, scalar, series');
nc{'LPHYTO'}.fields = 'LPHYTO, scalar, series';
%
%%endef(nc);
%
% record the time
%
nc{'sphyto_time'}(:)=time;
nc{'lphyto_time'}(:)=time;
%
% loop on time
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  nc{'SPHYTO'}(l,:,:,:)=theta1*squeeze(nc{'CHLA'}(l,:,:,:));
  nc{'LPHYTO'}(l,:,:,:)=theta2*squeeze(nc{'CHLA'}(l,:,:,:));  
end
close(nc);
return

