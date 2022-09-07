function [i1min,i1max,i2min,i2max,i3min,i3max,...
          i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
          jrange,jrange_v,krange,lon,lon_u,lat,lat_v,depth]=...
         get_mercator_subgrid(path,lonmin,lonmax,latmin,latmax)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get the indices for a ECCO subgrid 
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    6-Sep-2006 by Pierrick Penven
%  Updated    20-Aug-2008 by Matthieu Caillaud & P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dl=1;
lonmin=lonmin-dl;
lonmax=lonmax+dl;
latmin=latmin-dl;
latmax=latmax+dl;
%
% Get the global grid
%
lon=readdap(path,'longitude',[]);
lat=readdap(path,'latitude',[]);
depth=readdap(path,'depth',[]);
%lon_u=readdap(path,'lon_u',[]);
%lat_v=readdap(path,'lat_v',[]);
%
% Quick fix because lon_u and lat_v are 
%
disp('GET_MERCATOR_SUBGRID: Warning lon_u and lat_v are no more downloaded from the server') 
lon_u=lon-0.5;
lat_v=lat-0.5;
%
% Get a subgrid
%
%
% 1 Longitude: take care of greenwitch
%
i1=find(lon-360>=lonmin & lon-360<=lonmax);
i2=find(lon>=lonmin & lon<=lonmax);
i3=find(lon+360>=lonmin & lon+360<=lonmax);
%
if ~isempty(i3) &  ~isempty(i2)

lon2=lon(i2);
lon3=lon(i3)+360;

if lon2(end)==lon3(1)
     lon3=lon3(2:end);
end
lon=cat(1,lon(i1)-360,lon2,lon3);
else

lon=cat(1,lon(i1)-360,lon(i2),lon(i3)+360);
end


%
if ~isempty(i1)
  i1min=min(i1)-1;
  i1max=max(i1)-1;
else
  i1min=[];
  i1max=[];
end
if ~isempty(i2)
  i2min=min(i2)-1;
  i2max=max(i2)-1;
else
  i2min=[];
  i2max=[];
end
if ~isempty(i3)
  i3min=min(i3)-1;
  i3max=max(i3)-1;
else
  i3min=[];
  i3max=[];
end
if ~isempty(i3) &  ~isempty(i2)
     i3min=min(i3);
else
     i3min=min(i3)-1;
end

%
i1_u=find(lon_u-360>=lonmin & lon_u-360<=lonmax);
i2_u=find(lon_u>=lonmin & lon_u<=lonmax);
i3_u=find(lon_u+360>=lonmin & lon_u+360<=lonmax);

if ~isempty(i3_u) &  ~isempty(i2_u)

lon2_u=lon_u(i2_u);
lon3_u=lon_u(i3_u)+360;

if lon2_u(end)==lon3_u(1)
     lon3_u=lon3_u(2:end);
end
lon_u=cat(1,lon_u(i1_u)-360,lon2_u,lon3_u);

else

lon_u=cat(1,lon_u(i1_u)-360,lon_u(i2),lon_u(i3)+360);
end

%
if ~isempty(i1_u)
  i1min_u=min(i1_u)-1;
  i1max_u=max(i1_u)-1;
else
  i1min_u=[];
  i1max_u=[];
end
if ~isempty(i2_u)
  i2min_u=min(i2_u)-1;
  i2max_u=max(i2_u)-1;
else
  i2min_u=[];
  i2max_u=[];
end
if ~isempty(i3_u)
  i3min_u=min(i3_u)-1;
  i3max_u=max(i3_u)-1;
else
  i3min_u=[];
  i3max_u=[];
end
if ~isempty(i3_u) &  ~isempty(i2_u)
     i3min_u=min(i3_u);
else
     i3min_u=min(i3_u)-1;
end

%
% 2 Latitude
%
j=find(lat>=latmin & lat<=latmax);
lat=lat(j);	
jmin=min(j)-1;
jmax=max(j)-1;
jrange=['[',num2str(jmin),':',num2str(jmax),']'];
%
j_v=find(lat_v>=latmin & lat_v<=latmax);
lat_v=lat_v(j_v);
jmin_v=min(j_v)-1;
jmax_v=max(j_v)-1;
jrange_v=['[',num2str(jmin_v),':',num2str(jmax_v),']'];
%
% 3 Depth
%
k=length(depth);
krange=['[',num2str(0),':',num2str(k-1),']'];
%
return
