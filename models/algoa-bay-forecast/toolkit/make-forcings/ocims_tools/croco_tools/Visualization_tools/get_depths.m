function [z]=get_depths(fname,gname,tindex,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the depths of the sigma levels
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(gname);
h=nc{'h'}(:);
close(nc);
%
% open history file
%
nc=netcdf(fname);
zeta=squeeze(nc{'zeta'}(tindex,:,:));
hmorph=squeeze(nc{'hmorph'}(tindex,:,:));
if ~isempty(hmorph), h=hmorph; end;
theta_s=nc.theta_s(:); 
if (isempty(theta_s))
%  disp('Rutgers version')
  theta_s=nc{'theta_s'}(:);
  theta_b=nc{'theta_b'}(:);
  Tcline=nc{'Tcline'}(:);
else 
%  disp('AGRIF/UCLA version');
  theta_b=nc.theta_b(:);
  Tcline=nc.Tcline(:);
  hc=nc.hc(:);
end
if (isempty(Tcline))
%  disp('UCLA version');
  hc=nc.hc(:);
else
  hmin=min(min(h));
  hc=min(hmin,Tcline);
end 
N=length(nc('s_rho'));
s_coord=1;
VertCoordType = nc.VertCoordType(:);
if isempty(VertCoordType),
  vtrans=nc{'Vtransform'}(:);
  if ~isempty(vtrans),
    s_coord=vtrans;
  end
elseif VertCoordType=='NEW', 
 s_coord=2;
end;
if s_coord==2,
 hc=Tcline;
end
close(nc)
%
%
%
if isempty(zeta)
  zeta=0.*h;
end

vtype=type;
if (type=='u')|(type=='v')
  vtype='r';
end
z=zlevs(h,zeta,theta_s,theta_b,hc,N,vtype,s_coord);
if type=='u'
  z=rho2u_3d(z);
end
if type=='v'
  z=rho2v_3d(z);
end
return
