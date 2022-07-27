function [lon1,lat1,lon2,lat2]=get_mouse(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the position of the mouse in longitude and latitude.
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

set(handles.figure1,'HandleVisibility','on','CurrentAxes',handles.axes1);
m_proj('mercator',...
       'lon',[handles.lonmin handles.lonmax],...
       'lat',[handles.latmin handles.latmax]);
[x1,y1] = ginput(1);
[lon1,lat1]=m_xy2ll(x1,y1);
hold on
plot(x1,y1,'yo')
hold off
[x2,y2] = ginput(1);
[lon2,lat2]=m_xy2ll(x2,y2);
hold on
plot(x2,y2,'yo')
plot([x1 x2],[y1 y2],'r--')
hold off

return
