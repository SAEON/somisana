function h=m_quiver_cst(long,lat,u,v,varargin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% h=m_quiver_cst(long,lat,u,v,varargin);
%
% Very simple quiver where arrows scale does not change with latitude.
% This is based on m_quiver from m_map from  Rich Pawlowicz
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
%  Copyright (c) 2010 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global MAP_PROJECTION MAP_VAR_LIST
if isempty(MAP_PROJECTION)
  disp('No Map Projection initialized - call M_PROJ first!')
  return
end
[X,Y]=m_ll2xy(long,lat,'clip','point');
h=quiver(X,Y,u,v,varargin{:});
set(h,'tag','m_quiver')
if nargout==0
 clear h
end
