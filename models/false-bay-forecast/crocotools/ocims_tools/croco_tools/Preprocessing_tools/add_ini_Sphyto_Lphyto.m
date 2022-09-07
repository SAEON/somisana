function add_ini_Sphyto_Lphyto(inifile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function add_ini_phyto(inifile);
%
%  Add phytoplancton (mMol N m-3)  in a CROCO initial file.
%  take the chlorophyll (mg C) from the initial file and
%  multiply by the ratio chlorophyll / phytoplancton derived
%  from previous simulations.
%
%  phyto = theta * chla
%
%  input:
%    
%    inifile      : croco initial file to process (netcdf)
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
theta1=0.1;
theta2=0.4;
%
disp('Add_ini_Sphyto_Lphyto: creating variable and attribute')
%
% open the initial file  
% 
nc=netcdf(inifile,'write');
time= nc{'scrum_time'}(:);
tlen=length(time);
%
%redef(nc);
%
nc{'SPHYTO'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'SPHYTO'}.long_name = ncchar('Small Phytoplankton');
nc{'SPHYTO'}.long_name = 'Small Phytoplankton';
nc{'SPHYTO'}.units = ncchar('mMol N m-3');
nc{'SPHYTO'}.units = 'mMol N m-3';
nc{'SPHYTO'}.fields = ncchar('SPHYTO, scalar, series');
nc{'SPHYTO'}.fields = 'SPHYTO, scalar, series';
%
nc{'LPHYTO'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'LPHYTO'}.long_name = ncchar('Large Phytoplankton');
nc{'LPHYTO'}.long_name = 'Large Phytoplankton';
nc{'LPHYTO'}.units = ncchar('mMol N m-3');
nc{'LPHYTO'}.units = 'mMol N m-3';
nc{'LPHYTO'}.fields = ncchar('LPHYTO, scalar, series');
nc{'LPHYTO'}.fields = 'LPHYTO, scalar, series';
%
%endef(nc);
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

