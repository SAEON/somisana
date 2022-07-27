function getpot(clmname,grdname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get potential temperature of seawater from insitu
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
isoctave=exist('octave_config_info');
%
% open the grid file  
% 
nc=netcdf(grdname,'r');
h=nc{'h'}(:);
close(nc);
%
% open the clim file  
% 
nc=netcdf(clmname,'write');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
hc  =  nc{'hc'}(:);
N =  length(nc('s_rho'));
if (isoctave == 0)
  tlen =  length(nc('tclm_time'));
 else
   tlen = 0;
end

vtransform=nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
if tlen==0
  tlen=1;
end
%
% Get the sigma depths
%
P=-1e-4*1025*9.81*zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform);
%
% loop on time
%
for l=1:tlen
  disp(['   getpot: Time index: ',num2str(l),' of total: ',num2str(tlen)])
  T=squeeze(nc{'temp'}(l,:,:,:));
  S=squeeze(nc{'salt'}(l,:,:,:));
  nc{'temp'}(l,:,:,:)=theta(S,T,P);
end
close(nc);
return
