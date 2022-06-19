function add_Szoo_Lzoo(climfile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function add_zoo(climfile);
%
%  Add zooplancton (mMol N m-3) in a CROCO climatology file.
%  take the chlorophyll (mg C) from the climatology file and
%  multiply by the ratio chlorophyll / phytoplancton derived
%  from previous simulations (Gruber et al., 2005)
%
%  zoo = 0.2 * chla
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
%  Updated    2005 by Patrick Marchesiello (IRD)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
theta1=0.2;
theta2=0.3;
%
disp('Add_Szoo_Lzoo: creating variable and attribute')
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
nc('szoo_time') = tlen;
nc{'szoo_time'} = ncdouble('szoo_time') ;
nc{'SZOO'} = ncdouble('szoo_time','s_rho','eta_rho','xi_rho') ;
%
nc{'szoo_time'}.long_name = ncchar('time for Small Zooplankton');
nc{'szoo_time'}.long_name = 'time for Small Zooplankton';
nc{'szoo_time'}.units = ncchar('day');
nc{'szoo_time'}.units = 'day';
if cycle~=0
  nc{'szoo_time'}.cycle_length = cycle;
end
%
nc('lzoo_time') = tlen;
nc{'lzoo_time'} = ncdouble('lzoo_time') ;
nc{'LZOO'} = ncdouble('lzoo_time','s_rho','eta_rho','xi_rho') ;
%
nc{'lzoo_time'}.long_name = ncchar('time for Large Zooplankton');
nc{'lzoo_time'}.long_name = 'time for Large Zooplankton';
nc{'lzoo_time'}.units = ncchar('day');
nc{'lzoo_time'}.units = 'day';
if cycle~=0
  nc{'lzoo_time'}.cycle_length = cycle;
end
%
nc{'SZOO'}.long_name = ncchar('Small Zooplankton');
nc{'SZOO'}.long_name = 'Small Zooplankton';
nc{'SZOO'}.units = ncchar('mMol N m-3');
nc{'SZOO'}.units = 'mMol N m-3';
nc{'SZOO'}.fields = ncchar('SZOO, scalar, series');
nc{'SZOO'}.fields = 'SZOO, scalar, series';
%
nc{'LZOO'}.long_name = ncchar('Large Zooplankton');
nc{'LZOO'}.long_name = 'Large Zooplankton';
nc{'LZOO'}.units = ncchar('mMol N m-3');
nc{'LZOO'}.units = 'mMol N m-3';
nc{'LZOO'}.fields = ncchar('LZOO, scalar, series');
nc{'LZOO'}.fields = 'LZOO, scalar, series';
%
%%endef(nc);
%
% record the time
%
nc{'szoo_time'}(:)=time;
nc{'lzoo_time'}(:)=time;
%
% loop on time
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  nc{'SZOO'}(l,:,:,:)=theta1*squeeze(nc{'CHLA'}(l,:,:,:));
  nc{'LZOO'}(l,:,:,:)=theta2*squeeze(nc{'CHLA'}(l,:,:,:));
end
close(nc);
return

