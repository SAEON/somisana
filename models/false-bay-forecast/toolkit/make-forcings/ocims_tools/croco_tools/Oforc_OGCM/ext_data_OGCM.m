function data=ext_data_OGCM(nc,X,Y,vname,tndx,lon,lat,k,Roa,interp_method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extrapole one horizontal ECCO (or Data) slice on a CROCO grid
%
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Contributions of P. Marchesiello (IRD) and J. Lefevre (IRD)
%
%  Updated    6-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% extrapolation parameters
%
default=0;
if strcmp(vname,'SAVE') | strcmp(vname,'salt')
  default=34.6;
end
%
% Get the CROCO grid extension + a little margin (~ 2 data grid points)
%
dx=max(abs(gradient(X)));
dy=max(abs(gradient(Y)));
dl=2*max([dx dy]);
%
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
% Extract a data subgrid
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
if ~isempty(i2)
  x=X(i2);
else
  x=[];
end
if ~isempty(i1)
  x=cat(2,X(i1)-360,x);
end
if ~isempty(i3)
  x=cat(2,x,X(i3)+360);
end
y=Y(j);
%
%  Get dimensions
%
ndims=length(dim(nc{vname}));
%
% Get data (Horizontal 2D matrix)
%
if ~isempty(i2)
  if ndims==2
    data=squeeze(nc{vname}(j,i2));
  elseif ndims==3
    data=squeeze(nc{vname}(tndx,j,i2));
  elseif ndims==4
    data=squeeze(nc{vname}(tndx,k,j,i2));
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
else
  data=[];
end
if ~isempty(i1)
  if ndims==2
    data=cat(2,squeeze(nc{vname}(j,i1)),data);
  elseif ndims==3
    data=cat(2,squeeze(nc{vname}(tndx,j,i1)),data);
  elseif ndims==4
    data=cat(2,squeeze(nc{vname}(tndx,k,j,i1)),data);
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
end
if ~isempty(i3)
  if ndims==2
    data=cat(2,data,squeeze(nc{vname}(j,i3)));
  elseif ndims==3
    data=cat(2,data,squeeze(nc{vname}(tndx,j,i3)));
  elseif ndims==4
    data=cat(2,data,squeeze(nc{vname}(tndx,k,j,i3)));
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
end
%
% Perform the extrapolation
%
[data,interp_flag]=get_missing_val(x,y,data,NaN,Roa,default);
%
% Interpolation on the CROCO grid
%
if interp_flag==0
  data=interp2(x,y,data,lon,lat,'nearest');
else
  data=interp2(x,y,data,lon,lat,interp_method);
end
%
return
