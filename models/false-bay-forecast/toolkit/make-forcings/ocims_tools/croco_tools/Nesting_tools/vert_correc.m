function vert_correc(ncfile,tindex,biol,pisces,namebiol,namepisces)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Vertically reinterpolate embedded 3D variables
% when the topography (and so the sigma grid) has
% been changed
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
disp(' Vertical corrections... ')
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
end
vtransform=nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
%
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
disp('get the depths')
zrold=zlevs(hold,zeta,theta_s,theta_b,hc,N,'r',vtransform);
zrnew=zlevs(hnew,zeta,theta_s,theta_b,hc,N,'r',vtransform);
zuold=0.5*(zrold(:,:,1:end-1)+zrold(:,:,2:end));
zunew=0.5*(zrnew(:,:,1:end-1)+zrnew(:,:,2:end));
zvold=0.5*(zrold(:,1:end-1,:)+zrold(:,2:end,:));
zvnew=0.5*(zrnew(:,1:end-1,:)+zrnew(:,2:end,:));
%
% perform the modifications
%
disp('u...')
nc{'u'}(tindex,:,:,:)=change_sigma(lonu,latu,masku,...
				   squeeze(nc{'u'}(tindex,:,:,:)),...
				   zuold,zunew);
disp('v...')
nc{'v'}(tindex,:,:,:)=change_sigma(lonv,latv,maskv,...
				   squeeze(nc{'v'}(tindex,:,:,:)),...
				   zvold,zvnew);
disp('temp...')
nc{'temp'}(tindex,:,:,:)=change_sigma(lonr,latr,maskr,...
				      squeeze(nc{'temp'}(tindex,:,:,:)),...
				      zrold,zrnew);
disp('salt...')
nc{'salt'}(tindex,:,:,:)=change_sigma(lonr,latr,maskr,...
				      squeeze(nc{'salt'}(tindex,:,:,:)),...
				      zrold,zrnew);
%
if (biol==1)
  disp('vert_correc for biology variables')
  for k=1:length(namebiol)
    disp([char(namebiol(k)),'...'])
    nc{char(namebiol(k))}(tindex,:,:,:)=change_sigma(lonr,latr,maskr,...
						     squeeze(nc{char(namebiol(k))}(tindex,:,:,:)),...
						     zrold,zrnew);
  end
end
%
if (pisces==1)
  disp('vert_correc for pisces variables')
  for k=1:length(namepisces)
      disp([char(namepisces(k)),'...'])
      nc{char(namepisces(k))}(tindex,:,:,:)=change_sigma(lonr,latr,maskr,...
          squeeze(nc{char(namepisces(k))}(tindex,:,:,:)),...
          zrold,zrnew);
  end
end
%
close(nc)
return

