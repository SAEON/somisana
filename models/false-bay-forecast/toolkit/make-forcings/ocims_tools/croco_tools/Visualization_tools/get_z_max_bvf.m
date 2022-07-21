function [lat,lon,mask,h]=get_z_rhosurf1(hisfile,gridfile,tindex,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the depth of 1.25 kg.m-3 below surface density
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
%  Updated 15 Nov 2006 by P. Penven - remove vlevel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g=9.81;
rho0=1000;
[lat,lon,mask]=read_latlonmask(gridfile,'r');
zr=get_depths(hisfile,gridfile,tindex,'r');
zw=get_depths(hisfile,gridfile,tindex,'w');
nc=netcdf(hisfile);
temp=squeeze(nc{'temp'}(tindex,:,:,:));
salt=squeeze(nc{'salt'}(tindex,:,:,:));
close(nc)
[rho,bvf]=rho_eos(temp,salt,zr,zw,g,rho0);
h=coef.*mask.*get_depth_maxvar(bvf,zw);
