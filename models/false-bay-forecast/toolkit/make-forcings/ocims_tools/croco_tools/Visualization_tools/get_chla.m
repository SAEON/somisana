function [lat,lon,mask,chla]=get_rho(hisfile,gridfile,tindex,vlevel,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the chlorophylle from 2 different phytoplankton groups
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

[lat,lon,mask]=read_latlonmask(gridfile,'r');
sphyto=get_hslice(hisfile,gridfile,'SPHYTO',...
                tindex,vlevel,'r');
lphyto=get_hslice(hisfile,gridfile,'LPHYTO',...
                   tindex,vlevel,'r');
%
theta_m  =0.020;
CN_Phyt  = 6.625;
chla=theta_m*(sphyto+lphyto)*CN_Phyt*12.;
chla(chla<=0)=NaN;
chla=coef.*mask.*chla;

