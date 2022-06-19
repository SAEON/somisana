function vert_correc_onefield(ncfile,tindex,field)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Vertically reinterpolate embedded 3D variables
% when the topography (and so the sigma grid) has
% been changed
%
%
%     vert_correc(ncfile,tindex,field)
%
%     ncfile : input clim file
%
%     tindex: time inde processed
%
%     field: variable ('r') processed. String
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ')
%disp(' Vertical corrections... ')
nc=netcdf(ncfile,'write');
N=length(nc('s_rho'));
theta_s = nc{'theta_s'}(:);
if isempty(theta_s)
  theta_s=nc.theta_s(:);
  theta_b=nc.theta_b(:);
  hc=nc.hc(:);
else
  theta_b=nc{'theta_b'}(:);
  hc=nc{'hc'}(:);
  vtransform=nc{'Vtransform'}(:);
  if  ~exist('vtransform') |  isempty(vtransform)
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
  end
end
zeta=squeeze(nc{'zeta'}(tindex,:,:));
if isempty(zeta)
  zeta=squeeze(nc{'SSH'}(tindex,:,:));
end
grd_file = nc.grd_file(:);
ng=netcdf(grd_file);
hold=squeeze(ng{'hraw'}(1,:,:));
if isempty(zeta)
  zeta=0*hold;
end
hnew=ng{'h'}(:);
latr=ng{'lat_rho'}(:);
latu=ng{'lat_u'}(:);
latv=ng{'lat_v'}(:);
lonr=ng{'lon_rho'}(:);
lonu=ng{'lon_u'}(:);
lonv=ng{'lon_v'}(:);
maskr=ng{'mask_rho'}(:);
masku=ng{'mask_u'}(:);
maskv=ng{'mask_v'}(:);
result=close(ng);
%
% get the depths
%
zrold=zlevs(hold,zeta,theta_s,theta_b,hc,N,'r',vtransform);
zrnew=zlevs(hnew,zeta,theta_s,theta_b,hc,N,'r',vtransform);
zuold=0.5*(zrold(:,:,1:end-1)+zrold(:,:,2:end));
zunew=0.5*(zrnew(:,:,1:end-1)+zrnew(:,:,2:end));
zvold=0.5*(zrold(:,1:end-1,:)+zrold(:,2:end,:));
zvnew=0.5*(zrnew(:,1:end-1,:)+zrnew(:,2:end,:));
%
% perform the modifications
%
disp(['Vert_correc for 3D (''rho'') variables: ',field])
disp('==========================')
nc{field}(tindex,:,:,:)=change_sigma(lonr,latr,maskr,...
				     squeeze(nc{field}(tindex,:,:,:)),...
				     zrold,zrnew);
%
close(nc)

return

