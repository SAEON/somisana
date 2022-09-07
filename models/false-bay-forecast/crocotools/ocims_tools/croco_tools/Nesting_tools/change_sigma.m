function data_new=change_sigma(lon,lat,mask,data_old,z_old,z_new)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reinterpolate the variables to fit on the new vertical s-coordinates
% (for a new topography)
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
m1=mask;
m1(m1==0)=NaN;
[N,M,L]=size(data_old);
%
% Get the horizontal levels (i.e. the zigma levels
% at the deepest depth)
%
zmin=min(min(min(z_old)));
zmax=max(max(max(z_old)));
[j,i]=find(squeeze(z_old(1,:,:))==zmin);
deepval=data_old(1,j,i);
depth=[500*(floor(zmin/500))-2000;z_old(:,j,i);10];
Nd=length(depth);
data_z=zeros(Nd,M,L);
%
% Extract a z variable
%
for k=1:Nd
  disp(['  computing depth = ',num2str(depth(k))])
  data2d=m1.*vinterp(data_old,z_old,depth(k));
%
% Horizontal extrapolation using 'nearest' ...
%
  isbad=isnan(data2d);
  isgood=~isbad;
  if sum(sum(isgood))==0
    data_z(k,:,:)=deepval;
  elseif sum(sum(isgood))==1
    data_z(k,:,:)=data2d(isgood);
  elseif sum(sum(isbad))==0
    data_z(k,:,:)=data2d;
  else
    data2d(isbad)=griddata(lon(isgood),lat(isgood),data2d(isgood),...
                           lon(isbad),lat(isbad),'nearest');
    % Gc remove the masking because in case of nesting
    % It introduce some zero value 
    % data_z(k,:,:)=mask.*data2d;
    data_z(k,:,:)=data2d;
  end
end
%
% Interpole on new sigma levels 
%
data_new=ztosigma(data_z,z_new,depth);
%
return
