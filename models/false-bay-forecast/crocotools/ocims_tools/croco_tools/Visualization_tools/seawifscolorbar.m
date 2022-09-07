function seawifscolorbar(colpos,vname,fsize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function seawifscolorbar(colpos,vname,fsize)
%
% put a seawifs colorbar at a fixed position
%
% input:
%
%  colpos   position of the colorbar [left, bottom, width, height]
%  vname    name of the variable (string)
%           (default: 'temp')
%  fsize    font size  
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
%  Copyright (c) 2002-2006 by Patrick Marchesiello and Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated 23-Oct-2006 by Pierrick Penven (seawifs colormap)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot('position',colpos)
y=[0:1];
x=[0:70];
[Y,X]=meshgrid(y,x);
pcolor(X,Y,X)
L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50];
l=(log10(L)+2)*70/(log10(70)+2);
set(gca,'YTick',y,'YTickLabel',[' '])
set(gca,'XTick',l,'XTickLabel',L)
shading flat
caxis([0.01 70])
set(gca,'FontSize',fsize)
return
