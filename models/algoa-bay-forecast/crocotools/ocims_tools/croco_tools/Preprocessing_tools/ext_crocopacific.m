function ext_crocopacific(oaname,datafile,dataname,vname,tname,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  pierrick 2003
%
%  Extrpolations in a CROCO climatology file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    
%    oaname      : croco oa file to process (netcdf)
%    datafile    : regular longitude - latitude - z seasonal data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
%
% set the value of ro (oa decorrelation scale [m]) 
% and default (value if no data)
%
ro=1e8;
default=NaN;
disp([' Ext tracers: ro = ',num2str(ro/1000),...
      ' km - default value = ',num2str(default)])
%
% Read in the datafile 
%
ncclim=netcdf(datafile);
x=ncclim{'LON281_377'}(:);
y=ncclim{'LAT2_110'}(:);
zclim=-ncclim{'DEPTH'}(1:30);
t=ncclim{'TIME'}(:);
tlen=length(t);
Nzclim=length(zclim);
%
% Open the grid file and get the CROCO positions  
% 
ng=netcdf(oaname,'r');
if type=='r'
  lon=ng{'lon_rho'}(:);
  lat=ng{'lat_rho'}(:);
elseif type=='u'
  lon=ng{'lon_u'}(:);
  lat=ng{'lat_u'}(:);
elseif type=='v'
  lon=ng{'lon_v'}(:);
  lat=ng{'lat_v'}(:);
else
  error('Bad Type')
end 
lon(lon<0)=lon(lon<0)+360;
close(ng);
[M,L]=size(lon);
%
% Extract a subgrid of the data set
%
dl=0.5;
minlon=min(min(lon))-dl;
maxlon=max(max(lon))+dl;
minlat=min(min(lat))-dl;
maxlat=max(max(lat))+dl;
imin=max(find(x<=minlon));
imax=min(find(x>=maxlon));
jmin=max(find(y<=minlat));
jmax=min(find(y>=maxlat));
y=y(jmin:jmax);
if isempty(imax)
  dataeast=1;
  imax=(length(x));
  x=x(imin:imax);
  dx=(x(end)-x(1))/(length(x)-1);
  addx=[x(end)+dx:dx:maxlon]';
  x=[x;addx];
  addata=meshgrid(addx,y);
else
  dataeast=0;
  x=x(imin:imax);
end
%
% Open the OA file  
% 
nc=netcdf(oaname,'write');
Z=-nc{'Z'}(:);
Nz=length(Z);
if zclim~=Z
 error('Zlevels mismatch between data and OA')
end
%
% interpole the seasonal dataset on the horizontal croco grid
%
disp([' Ext croco pacific: horizontal interpolation of the climatology data'])
%
% loop on time
%
missval=ncclim{dataname}.missing_value(:);
for l=1:tlen
%for l=1:1
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  for k=1:Nzclim
    disp(['vertical index: ',num2str(k),' of total: ',num2str(Nzclim)])
    data=squeeze(ncclim{dataname}(l,k,jmin:jmax,imin:imax));
    if dataeast==1
      data=[data,missval+0*addata];
    end
    data=get_missing_val(x,y,data,missval,ro,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
  nc{vname}(l,:,:,:)=datazgrid;
end
close(nc);
close(ncclim);
return
