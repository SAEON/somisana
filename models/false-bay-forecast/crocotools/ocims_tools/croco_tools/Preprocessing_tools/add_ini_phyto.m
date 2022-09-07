function add_ini_phyto(inifile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function add_ini_phyto(inifile);
%
%  Add phytoplancton (mMol N m-3)  in a CROCO initial file.
%  take the chlorophyll (mg C) from the initial file and
%  multiply by the ratio chlorophyll / phytoplancton derived
%  from previous simulations.
%
%  phyto = 0.5 * chla
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
theta=0.5;
%
disp('Add_ini_phyto: creating variable and attribute')
%
% open the initial file  
% 
nc=netcdf(inifile,'write');
time= nc{'scrum_time'}(:);
tlen=length(time);
%%redef(nc);
nc{'PHYTO'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'PHYTO'}.long_name = ncchar('Phytoplankton');
nc{'PHYTO'}.long_name = 'Phytoplankton';
nc{'PHYTO'}.units = ncchar('mMol N m-3');
nc{'PHYTO'}.units = 'mMol N m-3';
nc{'PHYTO'}.fields = ncchar('PHYTO, scalar, series');
nc{'PHYTO'}.fields = 'PHYTO, scalar, series';
%%endef(nc);
%
% loop on time
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  nc{'PHYTO'}(l,:,:,:)=theta*squeeze(nc{'CHLA'}(l,:,:,:));
end
close(nc);
return
