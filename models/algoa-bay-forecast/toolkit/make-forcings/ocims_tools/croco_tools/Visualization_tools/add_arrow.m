function add_arrow(lonmin,lonmax,latmin,latmax,cunit,cscale,width,height)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% add an arrow in a vector plot (under m_map)
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
global MAP_PROJECTION MAP_VAR_LIST
if isempty(MAP_PROJECTION)
  disp('No Map Projection initialized - call M_PROJ first!')
  return
end
%
% Get the dimension of the domain in figure coordinates
%
[x(1),y(1)]=m_ll2xy(lonmin,latmin); %bottom left corner
[x(2),y(2)]=m_ll2xy(lonmax,latmin); %bottom right corner
[x(3),y(3)]=m_ll2xy(lonmin,latmax); %top left corner
[x(4),y(4)]=m_ll2xy(lonmax,latmax); %top right corner
xmin=min(x);
xmax=max(x);
ymin=min(y);
ymax=max(y);
%
%  Define the position of the arrow 
% (upper left corner of the new subplot)
%
fac=0.01;
long=lonmin+fac*(lonmax-lonmin);
lat=latmax-fac*(latmax-latmin);
%
%  Define the scale of the arrow 
%
U=cunit*cscale/20;
V=0;
%
%  Define positions of the arrow in figure coordinates 
%
[X,Y]=m_ll2xy(long,lat,'clip','point');
%
%  Define the size of the new subplot
%
ratio1=(xmax-xmin)/(ymax-ymin);
ratio2=width/height;
if ratio2>=ratio1
 width=ratio1/ratio2;
else
 height=ratio2/ratio1;
end 
%
subplot('position',[0.6 0.06-height width height])
quiver(X,Y,U,0,0,'k')
text(X+U/2,Y,[num2str(cunit),' m.s^{-1}'],...
     'HorizontalAlignment','center',...
     'VerticalAlignment','bottom')
axis image                 
axis([xmin xmax ymin ymax])
set(gca,'visible','off')
