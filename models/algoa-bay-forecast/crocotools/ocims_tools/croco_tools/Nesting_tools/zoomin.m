function handles=zoomin(h,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Zoom in
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
waitforbuttonpress
xy=get(gca,'currentpoint');
x=xy(1,1);
y=xy(1,2);
[lon1,lat1]=m_xy2ll(x,y);
rbbox  
xy=get(gca,'currentpoint');
x=xy(1,1);
y=xy(1,2);
[lon2,lat2]=m_xy2ll(x,y);
if lon1==lon2 | lat1==lat2
  return
end
%
handles.lonmin=min([lon1 lon2]);
handles.lonmax=max([lon1 lon2]);
handles.latmin=min([lat1 lat2]);
handles.latmax=max([lat1 lat2]);
plot_nestgrid(h,handles)
return
