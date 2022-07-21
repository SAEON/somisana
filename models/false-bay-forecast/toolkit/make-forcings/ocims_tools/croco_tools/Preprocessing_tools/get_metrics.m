function  [pm,pn,dndx,dmde]=get_metrics(grdname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Compute the pm and pn factors of a grid netcdf file 
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
nc=netcdf(grdname,'r');
latu=nc{'lat_u'}(:);
lonu=nc{'lon_u'}(:);
latv=nc{'lat_v'}(:);
lonv=nc{'lon_v'}(:);
close(nc);
[Mp,L]=size(latu);
[M,Lp]=size(latv);
Lm=L-1;
Mm=M-1;
%
% pm and pn
%
dx=zeros(Mp,Lp);
dy=zeros(Mp,Lp);
dx(:,2:L)=spheric_dist(latu(:,1:Lm),latu(:,2:L),...
                       lonu(:,1:Lm),lonu(:,2:L));
dx(:,1)=dx(:,2);
dx(:,Lp)=dx(:,L);

dy(2:M,:)=spheric_dist(latv(1:Mm,:),latv(2:M,:),...
                       lonv(1:Mm,:),lonv(2:M,:));
dy(1,:)=dy(2,:);
dy(Mp,:)=dy(M,:);

pm=1./dx;
pn=1./dy;    
%
%  dndx and dmde
%
dndx(2:M,2:L)=0.5*(1./pn(2:M,3:Lp) - 1./pn(2:M,1:Lm));
dmde(2:M,2:L)=0.5*(1./pm(3:Mp,2:L) - 1./pm(1:Mm,2:L));
dndx(1,:)=0;
dndx(Mp,:)=0;
dndx(:,1)=0;
dndx(:,Lp)=0;
dmde(1,:)=0;
dmde(Mp,:)=0;
dmde(:,1)=0;
dmde(:,Lp)=0;


