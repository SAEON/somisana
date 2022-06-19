function [h_child,alph]=connect_topo(h_child,h_parent,h_coarse,...
                                      mask,mask_coarse,...
                                      pm_coarse,pn_coarse,pm_child,pn_child,...
                                      nband,refinecoeff,matchvolume)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Connect smoothly the child topography to the parent one
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
%
% 1 - get the alpha parameter (1=parent, 0=child)
%
alph=get_alpha(mask,nband,refinecoeff);
%
% 2 - correct parent topography in order to get the same volume
%     and the same section at the parent-child boundaries
%
if matchvolume==1
  h_parent=connect_volume(h_parent,h_coarse,mask_coarse,...
                          pm_coarse,pn_coarse,...
                          pm_child,pn_child,refinecoeff);
end
%
% 3 - mix the parent and the child topographies
%
h_child=alph.*h_parent+(1-alph).*h_child;
%
return
