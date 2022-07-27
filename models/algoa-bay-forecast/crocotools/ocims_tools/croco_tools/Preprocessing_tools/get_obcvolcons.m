function [u,v]=get_obcvolcons(u,v,pm,pn,rmask,obc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Enforce integral flux conservation around the domain
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
umask=rmask(1:end,2:end).*rmask(1:end,1:end-1);
vmask=rmask(2:end,1:end).*rmask(1:end-1,1:end);
%
dy_u=2*umask./(pn(1:end,2:end)+pn(1:end,1:end-1));
dx_v=2*vmask./(pm(2:end,1:end)+pm(1:end-1,1:end));
udy=u.*dy_u;
vdx=v.*dx_v;
%
Flux=obc(1)*sum(vdx(1,2:end-1))-obc(2)*sum(udy(2:end-1,end))-...
     obc(3)*sum(vdx(end,2:end-1))+obc(4)*sum(udy(2:end-1,1));
Cross=obc(1)*sum(dx_v(1,2:end-1))+obc(2)*sum(dy_u(2:end-1,end))+...
      obc(3)*sum(dx_v(end,2:end-1))+obc(4)*sum(dy_u(2:end-1,1));
vcorr=Flux/Cross;
disp(['Flux correction : ',num2str(vcorr)])
%
v(1,:)=obc(1)*(v(1,:)-vcorr);
u(:,end)=obc(2)*(u(:,end)+vcorr);
v(end,:)=obc(3)*(v(end,:)+vcorr);
u(:,1)=obc(4)*(u(:,1)-vcorr);
%
u=u.*umask;
v=v.*vmask; 
%
return
