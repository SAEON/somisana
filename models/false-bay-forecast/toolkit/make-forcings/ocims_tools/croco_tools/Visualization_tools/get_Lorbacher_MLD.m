function [lat,lon,mask,h]=get_Lorbacher_MLD(hisfile,gridfile,tindex,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the depth of the mixed layer depth using the 
%  Lorbacher & Dommenget routine
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Warning, this is a non-vectorial routine: it can be very slow')
[lat,lon,mask]=read_latlonmask(gridfile,'r');
zr=get_depths(hisfile,gridfile,tindex,'r');
nc=netcdf(hisfile);
temp=squeeze(nc{'temp'}(tindex,:,:,:));
close(nc)
h=0.*mask;
[M,L]=size(h);
for j=1:M
  for i=1:L
    if isfinite(mask(j,i))
      z=flipud(squeeze(zr(:,j,i)));
      t=flipud(squeeze(temp(:,j,i)));
      [h(j,i),qe,imf]=get_mld(z,t);
    end
  end
end
h=coef.*mask.*h;
