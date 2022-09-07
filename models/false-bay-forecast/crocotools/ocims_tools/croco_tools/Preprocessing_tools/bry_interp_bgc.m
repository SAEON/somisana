function bry_interp_bgc(zbryname,lon,lat,seas_datafile,ann_datafile,...
                    dataname,vname,obcndx,Roa);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  function bry_interp(zbryname,lon,lat,seas_datafile,ann_datafile,...
%                      dataname,vname,obcndx,Roa);
% 
%  Interpole data for the lateral boundaries (bry_file) along 
%  horizontal z levels.
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
[M,L]=size(lon);
%
% set the default value if no data
%
default=NaN;
%
% Read in the datafile
%
ncseas=netcdf(seas_datafile,'r');
X=ncseas{'X'}(:);
Y=ncseas{'Y'}(:);
Zseas=-ncseas{'Z'}(:);
T=ncseas{'T'}(:);
tlen=length(T);
Nzseas=length(Zseas);
%
% get the boundary position
%
if obcndx==1
%
% Southern boundary
% 
  icroco=(1:L);
  jcroco=1;
elseif obcndx==2
%
% Eastern boundary
% 
  icroco=L;
  jcroco=(1:M);
elseif obcndx==3
%
% Northern boundary
% 
  icroco=(1:L);
  jcroco=M;
elseif obcndx==4
%
% Western boundary
% 
  icroco=1;
  jcroco=(1:M);
end
%
lon=lon(jcroco,icroco);
lat=lat(jcroco,icroco);
%
% get a data subgrid (dependant of the OBC used)
%
dl=1.6;
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
x=cat(1,X(i1)-360,X(i2),X(i3)+360);
y=Y(j);
%
% Open the Z-boundary file
%
nc=netcdf(zbryname,'write');
Z=-nc{'Z'}(:);
Nz=length(Z);
%
% Check the time
%
% tbry=nc{'no3_time'}(:);
% T=T*30; % if time in month in the dataset !!!
% if (tbry~=T)
%   error(['time mismatch  tbry = ',num2str(tbry),...
%          '  t = ',num2str(T)])
% end
%
% Read the annual dataset
%
if Nz > Nzseas
  ncann=netcdf(ann_datafile,'r');
  zann=-ncann{'Z'}(1:Nz);
  if (Z~=zann)
    error('Vertical levels mismatch')
  end
%
% Interpole the annual dataset on the horizontal CROCO grid
%
  disp(' Ext tracers: horizontal interpolation of the annual data')
  if Zseas~=zann(1:length(Zseas)) 
    error('vertical levels dont match')
  end
  dims=size(lon);
  datazgrid=zeros(Nz,length(lon));
  missval=ncann{dataname}.missing_value(:);
  for k=Nzseas+1:Nz
    if ~isempty(i2)
      data=squeeze(ncann{dataname}(k,j,i2));
    else
      data=[];
    end
    if ~isempty(i1)
      data=cat(2,squeeze(ncann{dataname}(k,j,i1)),data);
    end
    if ~isempty(i3)
      data=cat(2,data,squeeze(ncann{dataname}(k,j,i3)));
    end
    data=get_missing_val(x,y,data,missval,Roa,default);
    if dims(1)==1
      datazgrid(k,:)=interp2(x,y,data,lon,lat,'cubic');
    else
      datazgrid(k,:)=(interp2(x,y,data,lon,lat,'cubic'))';    
    end
  end
  close(ncann);
end
%
% interpole the seasonal dataset on the horizontal croco grid
%
disp([' Ext tracers: horizontal interpolation of the seasonal data'])
%
% loop on time
%
missval=ncseas{dataname}.missing_value(:);
dims=size(lon);
for l=1:tlen
%for l=1:1
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  if Nz <= Nzseas
    datazgrid=zeros(Nz,length(lon));
  end
  for k=1:min([Nz Nzseas])
    if ~isempty(i2)
      data=squeeze(ncseas{dataname}(l,k,j,i2));
    else
      data=[];
    end
    if ~isempty(i1)
      data=cat(2,squeeze(ncseas{dataname}(l,k,j,i1)),data);
    end
    if ~isempty(i3)
      data=cat(2,data,squeeze(ncseas{dataname}(l,k,j,i3)));
    end
    data=get_missing_val(x,y,data,missval,Roa,default);
    if dims(1)==1
      datazgrid(k,:)=interp2(x,y,data,lon,lat,'cubic');
    else
      datazgrid(k,:)=(interp2(x,y,data,lon,lat,'cubic'))';    
    end
  end
%
% Test for salinity (no negative salinity !)
%
  if strcmp(vname,'salt_south') | strcmp(vname,'salt_north') | ...
     strcmp(vname,'salt_east') | strcmp(vname,'salt_west')
    disp('salinity test')
    datazgrid(datazgrid<2)=2;
  end
%
  nc{vname}(l,:,:,:)=datazgrid;
end
close(nc);
close(ncseas);
return

