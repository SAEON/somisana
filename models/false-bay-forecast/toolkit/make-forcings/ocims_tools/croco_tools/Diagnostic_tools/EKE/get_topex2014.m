function [x,y,data]=get_topex(lonmin,lonmax,latmin,latmax,fname)
%
% Get altimetry data [m] from a AVISO netcdf file
%
% Pierrick Penven 2004
%
dataname='adt';
%
%
%
ncdat=netcdf(fname);
T=ncdat{'time'}(:);
X=ncdat{'lon'}(:);
Y=ncdat{'lat'}(:);
%
disp(['AVISO - ',datestr(T+datenum(1950,1,1))])

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
data=[];
if ~isempty(i2)
  data=squeeze(ncdat{dataname}(1,j,i2));
end
if ~isempty(i1)
  data=cat(2,squeeze(ncdat{dataname}(1,j,i1)),data);
end
if ~isempty(i3)
  data=cat(2,data,squeeze(ncdat{dataname}(1,j,i3)));
end
close(ncdat)
%
% A few transformations (zeta in meters)
%
data(data<-1e9)=NaN;
data=data*0.0001;
%
return
