function [x,y,data]=read_data_tpxo(datafile,dataname,itide,lon,lat,type,dl)
%
%  Read in a tide TPXO file
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
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
% Open the data file
%
ncdat=netcdf(datafile);
%
%
% Get attributes
%
add_offset=ncdat{dataname}.add_offset(:);
scale_factor=ncdat{dataname}.scale_factor(:);
ndims=length(dim(ncdat{dataname}));
%
% Get data lon,lat
%
X=ncdat{['lon_',type']}(:);
Y=ncdat{['lat_',type']}(:);
%
% get a subgrid
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
x=cat(1,X(i1)-360,X(i2),X(i3)+360);
y=Y(j);
%
%  Read data
%
if ~isempty(i2)
  if ndims==2
    data=squeeze(ncdat{dataname}(j,i2));
  elseif ndims==3
    data=squeeze(ncdat{dataname}(itide,j,i2));
  elseif ndims==4
    data=squeeze(ncdat{dataname}(itide,1,j,i2));
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
else
  data=[];
end
if ~isempty(i1)
  if ndims==2
    data=cat(2,squeeze(ncdat{dataname}(j,i1)),data);
  elseif ndims==3
    data=cat(2,squeeze(ncdat{dataname}(itide,j,i1)),data);
  elseif ndims==4
    data=cat(2,squeeze(ncdat{dataname}(itide,1,j,i1)),data);
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
end
if ~isempty(i3)
  if ndims==2
    data=cat(2,data,squeeze(ncdat{dataname}(j,i3)));
  elseif ndims==3
    data=cat(2,data,squeeze(ncdat{dataname}(itide,j,i3)));
  elseif ndims==4
    data=cat(2,data,squeeze(ncdat{dataname}(itide,1,j,i3)));
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
end
close(ncdat)
%
% Apply offset
%
if ~isempty(add_offset)
  data=add_offset+data*scale_factor;
end
%
[x,y]=meshgrid(x,y);
%
