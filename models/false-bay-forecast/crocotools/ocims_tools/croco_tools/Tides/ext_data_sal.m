function [amp,pha]=ext_data_sal(grdname,salname,ampname,phaname,itide)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Extract and interpolate self-attraction and loading tidal data
%
%  Further Information:  
%  http://www.crocoagrif.org/croco_tools/
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
%  June 2015 Patrick Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% set the default value if no data
%
default=NaN;
%
% Open and Read CROCO grid file  
% 
ng=netcdf(grdname,'r');
lon=ng{'lon_rho'}(:);
lat=ng{'lat_rho'}(:);
close(ng);
[M,L]=size(lon);
%
dl=2;
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
% Read in SAL datafile 
%
nc=netcdf(salname,'r');
X=nc{'lon'}(:);
Y=nc{'lat'}(:);
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
% Recombine Amplitude and Phase SAL data 
%
dataname=ampname; % <-- Amplitude
if ~isempty(i2)
  data=squeeze(nc{dataname}(itide,j,i2));
else
  data=[];
end
if ~isempty(i1)
  data=cat(2,squeeze(nc{dataname}(itide,j,i1)),data);
end
if ~isempty(i3)
  data=cat(2,data,squeeze(nc{dataname}(itide,j,i3)));
end
amp=data;
%
dataname=phaname; % <-- Phase
if ~isempty(i2)
  data=squeeze(nc{dataname}(itide,j,i2));
else
  data=[];
end
if ~isempty(i1)
  data=cat(2,squeeze(nc{dataname}(itide,j,i1)),data);
end
if ~isempty(i3)
  data=cat(2,data,squeeze(nc{dataname}(itide,j,i3)));
end
pha=data;
close(nc);
%
% Interpolate complex SAL data on CROCO grid
%
cdata=amp.*exp(1i*pha*pi/180);
i_cdata(:,:)=interp2(x,y,cdata,lon,lat,'linear');
%
% Get back Amplitude and Phase of interpolated fields
%
amp=abs(i_cdata);
pha=180/pi*angle(i_cdata);

return
