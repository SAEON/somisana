function [X,T,VAR]=get_xt(hisfile,gridfile,lonsec,latsec,vname,tindices,vlevel);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [X,Z,VAR]=get_section(hisfile,gridfile,lonsec,latsec,vname,tindex);  
%
%  Extract a vertical slice in any direction (or along a curve)
%  from a CROCO netcdf file.
%
% 
% On Input:
% 
%    hisfile       History NetCDF file name (character string). 
%    gridfile       Grid NetCDF file name (character string). 
%    lonsec      Longitudes of the points of the section. 
%                 (vector or [min max] or single value if N-S section).
%                (default: [12 18])
%    latsec      Latitudes of the points of the section. 
%                 (vector or [min max] or single value if E-W section)
%                (default: -34)
%
%    NB: if lonsec and latsec are vectors, they must have the same length.
%
%    vname       NetCDF variable name to process (character string).
%                (default: temp)
%    tindex      Netcdf time index (integer).
%                (default: 1) 
%
% On Output:
%
%    X           Slice X-distances (km) from the first point (2D matrix).
%    Z           Slice Z-positions (matrix). 
%    VAR         Slice of the variable (matrix).
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Defaults values
%
if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  gridfile=hisfile;
  disp('Default grid name: ',gridfile)
end
if nargin < 3
  lonsec=[12 18];
  disp('Default longitude: ',num2str(lonsec))
end
if nargin < 4
  latsec=-34;
  disp('Default latitude: ',num2str(latsec))
end
if nargin < 5
  vname='temp';
  disp('Default variable to plot: ',vname)
end
if nargin < 6
  tindices=(1:3);
  disp('Default time indices: ',num2str(tindices))
end
if nargin < 7
  vlevel=-10;
  disp('Default vertical level: ',num2str(vlevel))
end
%
% Find maximum grid angle size (dl)
%
[lat,lon,mask]=read_latlonmask(gridfile,'r');
[M,L]=size(lon);
dl=1.3*max([max(max(abs(lon(2:M,:)-lon(1:M-1,:)))) ...
        max(max(abs(lon(:,2:L)-lon(:,1:L-1)))) ...
        max(max(abs(lat(2:M,:)-lat(1:M-1,:)))) ...
        max(max(abs(lat(:,2:L)-lat(:,1:L-1))))]);
%
% Read point positions
%
[type,vlevel]=get_type(hisfile,vname,vlevel);
[lat,lon,mask]=read_latlonmask(gridfile,type);
[M,L]=size(lon);
%
% Find minimal subgrids limits
%
minlon=min(lonsec)-dl;
minlat=min(latsec)-dl;
maxlon=max(lonsec)+dl;
maxlat=max(latsec)+dl;
sub=lon>minlon & lon<maxlon & lat>minlat & lat<maxlat;
if (sum(sum(sub))==0)
  error('Section out of the domain')
end
ival=sum(sub,1);
jval=sum(sub,2);
imin=min(find(ival~=0));
imax=max(find(ival~=0));
jmin=min(find(jval~=0));
jmax=max(find(jval~=0));
%
% Get subgrids
%
lon=lon(jmin:jmax,imin:imax);
lat=lat(jmin:jmax,imin:imax);
sub=sub(jmin:jmax,imin:imax);
mask=mask(jmin:jmax,imin:imax);
%
% Put latitudes and longitudes of the section in the correct vector form
%
if (length(lonsec)==1)
  disp(['N-S section at longitude: ',num2str(lonsec)])
  if (length(latsec)==1)
    error('Need more points to do a section')
  elseif (length(latsec)==2)
    latsec=(latsec(1):dl:latsec(2));
  end
  lonsec=0.*latsec+lonsec;
elseif (length(latsec)==1)
  disp(['E-W section at latitude: ',num2str(latsec)])
  if (length(lonsec)==2)
    lonsec=(lonsec(1):dl:lonsec(2));
  end
  latsec=0.*lonsec+latsec;
elseif (length(lonsec)==2 & length(latsec)==2)
  Npts=ceil(max([abs(lonsec(2)-lonsec(1))/dl ...
                  abs(latsec(2)-latsec(1))/dl]));
  if lonsec(1)==lonsec(2)
    lonsec=lonsec(1)+zeros(1,Npts+1);
  else
    lonsec=(lonsec(1):(lonsec(2)-lonsec(1))/Npts:lonsec(2));
  end
  if latsec(1)==latsec(2)
    latsec=latsec(1)+zeros(1,Npts+1);
  else
    latsec=(latsec(1):(latsec(2)-latsec(1))/Npts:latsec(2));
  end
elseif (length(lonsec)~= length(latsec))
  error('Section latitudes and longitudes are not of the same length')
end
Npts=length(lonsec);
%
% Get the subgrid
%
sub=0*lon;
for i=1:Npts
  sub(lon>lonsec(i)-dl & lon<lonsec(i)+dl & ...
      lat>latsec(i)-dl & lat<latsec(i)+dl)=1;
end
%
% Get the variable for the first time step.
%
VAR=zeros(length(tindices),Npts); 
nc=netcdf(hisfile);
tindex=tindices(1);
var=get_hslice(hisfile,gridfile,vname,tindex,vlevel,type);
var=var(jmin:jmax,imin:imax);
mask=isfinite(var.*mask);
var=var(sub==1 & mask);
%
% Get the coefficients of the objective analysis
%
londata=lon(sub==1 & mask);
latdata=lat(sub==1 & mask);
coef=oacoef(londata,latdata,lonsec,latsec,100e3);
%
% Get the variable for the first time step.
%
mvar=mean(var);
var=mvar+coef*(var-mvar);
VAR(tindex,:)=var';
%
% Loop on time
%
for i=2:length(tindices)
  tindex=tindices(i);
  var=get_hslice(hisfile,gridfile,vname,tindex,vlevel,type);
  var=var(jmin:jmax,imin:imax);
  var=var(sub==1 & mask);
  mvar=mean(var);
  var=mvar+coef*(var-mvar);
  VAR(tindex,:)=var';
end
%
% Get the distances
%
x=spheric_dist(latsec(1),latsec,lonsec(1),lonsec)/1e3;
%
% Get the time
%
t=nc{'scrum_time'}(tindices);
if (isempty(t))
  t=nc{'ocean_time'}(tindices);
end
t=tindices;
%
%
%
[X,T]=meshgrid(x,t);
return





