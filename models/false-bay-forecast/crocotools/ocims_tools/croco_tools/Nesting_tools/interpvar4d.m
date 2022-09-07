function interpvar4d(np,nc,igrid_par,jgrid_par,...
                    igrid_child,jgrid_child,...
                    varname,mask,tindex,N)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Interpole a 4D variable on a nested grid
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
imin=min(min(igrid_par));
imax=max(max(igrid_par));
jmin=min(min(jgrid_par));
jmax=max(max(jgrid_par));
%
% 
%
if ~isempty(mask)
  [I,J]=meshgrid(imin:imax,jmin:jmax);
  if varname(1)=='u'
    mask=mask(:,1:end-1).*mask(:,2:end);
  elseif varname(1)=='v'
    mask=mask(1:end-1,:).*mask(2:end,:);
  end
  mask=mask(jmin:jmax,imin:imax);
end
for zindex=1:N
  var_par=squeeze(np{varname}(tindex,zindex,jmin:jmax,imin:imax));
  if ~isempty(mask)
    var_par(mask==0)=griddata(I(mask==1),J(mask==1),var_par(mask==1),...
                              I(mask==0),J(mask==0),'nearest');
  end
  nc{varname}(tindex,zindex,:,:)=interp2(igrid_par,jgrid_par,var_par,...
                                         igrid_child,jgrid_child,'cubic');
end
return
