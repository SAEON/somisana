function maskout=process_mask(maskin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  maskout=process_mask(maskin)
%
%  Process the mask at rho-points in order to remove isolated
%  masked points, cape with only 1 mask...
%  Ensure continuous mask close to the boundaries
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
maskout=maskin;
%
[M,L]=size(maskout);
Mm=M-1;
Lm=L-1;
Mmm=Mm-1;
Lmm=Lm-1;
%
neibmask=0.*maskout;
neibmask(2:Mm,2:Lm)=maskout(1:Mmm,2:Lm)+maskout(3:M,2:Lm)+...
                    maskout(2:Mm,1:Lmm)+maskout(2:Mm,3:L);
%
while sum(sum((neibmask(2:Mm,2:Lm)>=3 & maskout(2:Mm,2:Lm)==0)|...
              (neibmask(2:Mm,2:Lm)<=1 & maskout(2:Mm,2:Lm)==1)))>0
%
  maskout(neibmask>=3 & maskout==0)=1;
  maskout(neibmask<=1 & maskout==1)=0;
%
  maskout(1,2:Lm)=maskout(2,2:Lm);
  maskout(M,2:Lm)=maskout(Mm,2:Lm);
  maskout(2:Mm,1)=maskout(2:Mm,2);
  maskout(2:Mm,L)=maskout(2:Mm,Lm);
%
  maskout(1,1)=min([maskout(1,2) maskout(2,1)]);
  maskout(M,1)=min([maskout(M,2) maskout(Mm,1)]);
  maskout(1,L)=min([maskout(1,Lm) maskout(2,L)]);
  maskout(M,L)=min([maskout(M,Lm) maskout(Mm,L)]);
%
  neibmask(2:Mm,2:Lm)=maskout(1:Mmm,2:Lm)+maskout(3:M,2:Lm)+...
                      maskout(2:Mm,1:Lmm)+maskout(2:Mm,3:L);
%		    
end
%
% Be sure that there is no problem close to the boundaries
%
maskout(:,1)=maskout(:,2);
maskout(:,L)=maskout(:,Lm);
maskout(1,:)=maskout(2,:);
maskout(M,:)=maskout(Mm,:);
%
