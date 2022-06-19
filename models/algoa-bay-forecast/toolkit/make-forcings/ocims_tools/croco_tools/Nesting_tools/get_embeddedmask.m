  function mask=get_embeddedmask(mask_parent,h,refinecoeff,newtopo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the mask for the child grid
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
%  Copyright (c) 2004-2006 by Pierrick Penven and Laurent Debreu
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if newtopo==1
  mask=h>0;
  [M,L]=size(mask);
%
  mask(1,:)=mask_parent(1,:);
  mask(end,:)=mask_parent(end,:);
  mask(:,1)=mask_parent(:,1);
  mask(:,end)=mask_parent(:,end);
% 
  [imat,jmat]=meshgrid((1:L),(1:M));
  dist=0*mask+inf;
  for j=1:M
    if mask(j,1)==1 
      dist=min(cat(3,dist,sqrt((imat-1).^2+(jmat-j).^2)),[],3);
    end
    if mask(j,L)==1 
      dist=min(cat(3,dist,sqrt((imat-L).^2+(jmat-j).^2)),[],3);
    end
  end
  for i=1:L
    if mask(1,i)==1 
      dist=min(cat(3,dist,sqrt((imat-i).^2+(jmat-1).^2)),[],3);
    end
    if mask(M,i)==1 
      dist=min(cat(3,dist,sqrt((imat-i).^2+(jmat-M).^2)),[],3);
    end
  end
%
% Put the parent mask close to the boundaries
%
  nmsk=1+2*refinecoeff;
  mask(dist<=nmsk)=mask_parent(dist<=nmsk);
else
  mask=mask_parent;
end
%
% Process the mask to check for points bays, et...
%
mask=process_mask(mask);
%
% in some cases the child mask can't be the same to the parent
% at the boundary:
%
if sum(mask(1,:)~=mask_parent(1,:))~=0
  disp(' ')
  disp('  Warning: the parent mask is not matching')
  disp('  the child mask at the SOUTH boundary')
  disp('  Conservation will not been possible')
  disp(' ')
  error('Try again with a different position for the south boundary')
end
if sum(mask(end,:)~=mask_parent(end,:))~=0
  disp(' ')
  disp('  Warning: the parent mask is not matching')
  disp('  the child mask at the NORTH boundary')
  disp('  Conservation will not been possible')
  disp(' ')
  error('Try again with a different position for the north boundary')
end
if sum(mask(:,end)~=mask_parent(:,end))~=0
  disp(' ')
  disp('  Warning: the parent mask is not matching')
  disp('  the child mask at the EAST boundary')
  disp('  Conservation will not been possible')
  disp(' ')
  error('Try again with a different position for the east boundary')
end
if sum(mask(:,1)~=mask_parent(:,1))~=0
  disp(' ')
  disp('  Warning: the parent mask is not matching')
  disp('  the child mask at the WEST boundary')
  disp('  Conservation will not been possible')
  disp(' ')
  error('Try again with a different position for the west boundary')
end
return
