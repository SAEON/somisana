function [X,Z,VAR]=get_section(fname,gname,lonsec,latsec,vname,tindex);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [X,Z,VAR]=get_section(fname,gname,lonsec,latsec,vname,tindex);  
%
%  Extract a vertical slice in any direction (or along a curve)
%  from a CROCO netcdf file.
%
% 
% On Input:
% 
%    fname       History NetCDF file name (character string). 
%    gname       Grid NetCDF file name (character string). 
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
%  by the Free Software Foundation; either version 2  
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
%  Updated 2006 by Juliet Hermes (UCT): increase of dl to prevent
%  errors when doing zonal or meridian sections.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interp_type='linear';
%
% Defaults values
%
if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  gname=fname;
  disp(['Default grid name: ',gname])
end
if nargin < 3
  lonsec=[12 18];
  disp(['Default longitude: ',num2str(lonsec)])
end
if nargin < 4
  latsec=-34;
  disp(['Default latitude: ',num2str(latsec)])
end
if nargin < 5
  vname='temp';
  disp(['Default variable to plot: ',vname])
end
if nargin < 6
  tindex=1;
  disp(['Default time index: ',num2str(tindex)])
end
%
% Find maximum grid angle size (dl)
%
[lat,lon,mask]=read_latlonmask(gname,'r');
[M,L]=size(lon);
dl=1.5* max([max(max(abs(lon(2:M,:)-lon(1:M-1,:)))) ...
        max(max(abs(lon(:,2:L)-lon(:,1:L-1)))) ...
        max(max(abs(lat(2:M,:)-lat(1:M-1,:)))) ...
        max(max(abs(lat(:,2:L)-lat(:,1:L-1))))]);
%
% Read point positions
%
[type,vlevel]=get_type(fname,vname,10);
if (vlevel==0)
   error([vname,' is a 2D-H variable'])
   return
end  
[lat,lon,mask]=read_latlonmask(gname,type);
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
%  get the coefficients of the objective analysis
%
londata=lon(sub==1);
latdata=lat(sub==1);
coef=oacoef(londata,latdata,lonsec,latsec,100e3);
%
% Get the mask
%
mask=mask(sub==1);
m1=griddata(londata,latdata,mask,lonsec,latsec,'nearest');
%mask(isnan(mask))=0;
%mask=mean(mask)+coef*(mask-mean(mask));
%mask(mask>0.5)=1;
%mask(mask<=0.5)=NaN;
londata=londata(mask==1);
latdata=latdata(mask==1);
%
%  Get the vertical levels
%
nc=netcdf(gname);
h=nc{'h'}(:);
hmin=min(min(h));
h=h(jmin:jmax,imin:imax);
close(nc)
h=h(sub==1);
h=h(mask==1);
%h=mean(h)+coef*(h-mean(h));
h=griddata(londata,latdata,h,lonsec,latsec,interp_type);
%
nc=netcdf(fname);
%
% First reset h for morphodynamics cases
%
hmorph=squeeze(nc{'hmorph'}(tindex,:,:));
if ~isempty(hmorph),
 h=hmorph; 
 hmin=min(min(h));
 h=h(jmin:jmax,imin:imax);
 h=h(sub==1);
 h=h(mask==1);
 h=griddata(londata,latdata,h,lonsec,latsec,interp_type);
end;
zeta=squeeze(nc{'zeta'}(tindex,jmin:jmax,imin:imax));
if isempty(zeta)
  zeta=0.*h;
else
  zeta=zeta(sub==1);
  zeta=zeta(mask==1);
  %zeta=mean(zeta)+coef*(zeta-mean(zeta));
  zeta=griddata(londata,latdata,zeta,lonsec,latsec,interp_type);
end
theta_s=nc.theta_s(:);
if (isempty(theta_s))
%  disp('Rutgers version')
  theta_s=nc{'theta_s'}(:);
  theta_b=nc{'theta_b'}(:);
  Tcline=nc{'Tcline'}(:);
else 
%  disp('UCLA version');
  theta_b=nc.theta_b(:);
  Tcline=nc.Tcline(:);
end
if (isempty(Tcline))
%  disp('UCLA version 2');
  hc=nc.hc(:);
else
  hmin=min(min(h));
  hc=min(hmin,Tcline);
end 
N=length(nc('s_rho'));
s_coord=1;
VertCoordType = nc.VertCoordType(:);
if isempty(VertCoordType),
  vtrans=nc{'Vtransform'}(:);
  if ~isempty(vtrans),
    s_coord=vtrans;
  end
elseif VertCoordType=='NEW', 
 s_coord=2;
end;
if s_coord==2,
 hc=Tcline;
end
Z=squeeze(zlevs(h,zeta,theta_s,theta_b,hc,N,type,s_coord)); 
[N,Nsec]=size(Z);
%
% Loop on the vertical levels
%
%mask=mask';
VAR=0.*Z;
for k=1:N
  var=squeeze(nc{vname}(tindex,k,jmin:jmax,imin:imax));
  var=var(sub==1);
  var=var(mask==1);
%  mvar=mean(var);
%  var=mvar+coef*(var-mvar);
  var=griddata(londata,latdata,var,lonsec,latsec,interp_type);
  VAR(k,:)=m1.*var;
end
close(nc)
%
% Get the distances
%
dist=spheric_dist(latsec(1),latsec,lonsec(1),lonsec)/1e3;
X=squeeze(tridim(dist,N));
return





