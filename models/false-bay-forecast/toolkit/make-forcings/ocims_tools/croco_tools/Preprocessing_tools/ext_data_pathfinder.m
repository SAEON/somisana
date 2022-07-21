function data=ext_data(datafile,dataname,tindex,lon,lat,time)
%
% Read a data file and extrapole 1 horizontal
% slice on a CROCO grid
%
disp(['Getting ',dataname,' for time index ',num2str(tindex)])
%
%
%
ro=1e8;
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
Y=ncdat{'Y'}(:);
T=30*ncdat{'T'}(tindex)-15;
if T~=time
  disp(['Warning incorrect time :',dataname,...
       ' - ',num2str(tindex),...
       ' - ',num2str(T),...
       ' - ',num2str(time)])
end
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
lon
  lat
  x
y
stop

data=get_missing_val(x,y,data,missval,ro,default);
%
% Interpolation on the CROCO grid
%
pcolor(data)

data=interp2(x,y,data,lon,lat,'linear');
%
% Apply offset
%
if ~isempty(add_offset)
  data=add_offset+data*scale_factor;
end
%
return
