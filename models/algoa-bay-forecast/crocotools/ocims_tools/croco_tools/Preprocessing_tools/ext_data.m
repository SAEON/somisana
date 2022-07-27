function data=ext_data(datafile,dataname,tindex,lon,lat,time,Roa,savefile)
%
%  Read a data file and extrapole 1 horizontal
%  slice on a CROCO grid
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    5-Oct-2006 by Pierrick Penven (test for negative salinity)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 8 
  savefile=2;
end

disp(['Getting ',dataname,' for time index ',num2str(tindex)])
%
default=NaN;
%
%
%
dl=1;
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
% Open the data file
%
ncdat=netcdf(datafile,'r');
%
% Get attributes
%
missval=ncdat{dataname}.missing_value(:);
if isempty(missval)
  missval=nan;
end
add_offset=ncdat{dataname}.add_offset(:);
scale_factor=ncdat{dataname}.scale_factor(:);
ndims=length(dim(ncdat{dataname}));
%
% Get lon,lat,t
%
X=ncdat{'X'}(:);
if isempty(X)
  X=ncdat{'lon'}(:);
end
if isempty(X)
  X=ncdat{'longitude'}(:);
end
if isempty(X)
  error(['Empty longitude in ',datafile])
end
Y=ncdat{'Y'}(:);
if isempty(Y)
  Y=ncdat{'lat'}(:);
end
if isempty(Y)
  Y=ncdat{'latitude'}(:);
end
if isempty(Y)
  error(['Empty latitude in ',datafile])
end

%T=30*ncdat{'T'}(tindex);
%if T~=time
%  disp(['Warning incorrect time :',dataname,...
%       ' - ',num2str(tindex),...
%       ' - ',num2str(T),...
%       ' - ',num2str(time)])
%end
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
  if ndims==3
    data=squeeze(ncdat{dataname}(tindex,j,i2));
  elseif ndims==4
    data=squeeze(ncdat{dataname}(tindex,1,j,i2));
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
else
  data=[];
end
if ~isempty(i1)
  if ndims==3
    data=cat(2,squeeze(ncdat{dataname}(tindex,j,i1)),data);
  elseif ndims==4
    data=cat(2,squeeze(ncdat{dataname}(tindex,1,j,i1)),data);
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
end
if ~isempty(i3)
  if ndims==3
    data=cat(2,data,squeeze(ncdat{dataname}(tindex,j,i3)));
  elseif ndims==4
    data=cat(2,data,squeeze(ncdat{dataname}(tindex,1,j,i3)));
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
end
close(ncdat)
%
% Perform the extrapolation
%
if savefile==2
  data=get_missing_val(x,y,data,missval,Roa,default,2);
else
  if tindex==1
    data=get_missing_val(x,y,data,missval,Roa,default,1);
  else
    data=get_missing_val(x,y,data,missval,Roa,default,0);
  end
end
%
% Interpolation on the CROCO grid
%
%data=interp2(x,y,data,lon,lat,'linear');
data=interp2(x,y,data,lon,lat,'cubic');
%
% Apply offset
%
if ~isempty(add_offset)
  data=add_offset+data*scale_factor;
end
%
% Test for salinity (no negative salinity !)
%
if strcmp(dataname,'salinity')
  disp('salinity test')
  data(data<2)=2;
end
%
return
