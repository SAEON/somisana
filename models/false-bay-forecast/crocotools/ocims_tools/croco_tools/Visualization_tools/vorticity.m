function [xi]=vort(ubar,vbar,pm,pn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the relative vorticity... 
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
[Mp,Lp]=size(pm);
L=Lp-1;
M=Mp-1;
Lm=L-1;
Mm=M-1;
xi=zeros(M,L);
mn_p=zeros(M,L);
uom=zeros(M,Lp);
von=zeros(Mp,L);
uom=2*ubar./(pm(:,1:L)+pm(:,2:Lp));
von=2*vbar./(pn(1:M,:)+pn(2:Mp,:));
mn=pm.*pn;
mn_p=(mn(1:M,1:L)+mn(1:M,2:Lp)+...
      mn(2:Mp,2:Lp)+mn(2:Mp,1:L))/4;
xi=mn_p.*(von(:,2:Lp)-von(:,1:L)-uom(2:Mp,:)+uom(1:M,:));
return

