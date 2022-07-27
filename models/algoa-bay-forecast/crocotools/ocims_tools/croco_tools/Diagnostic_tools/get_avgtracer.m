function [avgT,avgz0T,surfT]=get_avgtracer(nc,vname,n,rempts,...
                                           dv,V,dvz0,Vz0,N,ds2d,S);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get averaged quantities from a CROCO simulation.
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
T=squeeze(nc{vname}(n,:,:,:));
T=T(:,rempts(3)+1:end-rempts(4),rempts(1)+1:end-rempts(2));
avgT=sum(sum(sum(T.*dv)))/V;
avgz0T=sum(sum(sum(T.*dvz0)))/Vz0;
surfT=sum(sum(squeeze(T(N,:,:)).*ds2d))/S;
