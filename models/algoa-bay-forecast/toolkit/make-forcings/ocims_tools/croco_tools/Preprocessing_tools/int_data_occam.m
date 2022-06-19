function int_data_occam(oaname,datafile,vname,vlon,vlat,...
                        dataname,londata,latdata,tridim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  pierrick 2003
%
%  Ext tracers in a CROCO climatology file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    
%    oaname      : croco oa file to process (netcdf)
%    datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp(['Horizontal  interpolations of ',vname])
%
% Read in the datafile 
%
ncdata=netcdf(datafile,'r');
x=ncdata{londata}(:);
y=ncdata{latdata}(:);
Z=-ncdata{'Z'}(:);
t=ncdata{'T'}(:);
tlen=length(t);
Ndata=length(Z);
%
% Open the grid file  
% 
ng=netcdf(oaname,'r');
lon=ng{vlon}(:);
lon(lon<0)=lon(lon<0)+360;
lat=ng{vlat}(:);
close(ng);
[M,L]=size(lon);
dl=0.5;
minlon=min(min(lon))-dl;
maxlon=max(max(lon))+dl;
minlat=min(min(lat))-dl;
maxlat=max(max(lat))+dl;
imin=max(find(x<=minlon));
imax=min(find(x>=maxlon));
jmin=max(find(y<=minlat));
jmax=min(find(y>=maxlat));
x=x(imin:imax);
y=y(jmin:jmax);
%
% Open the OA file  
% 
nc=netcdf(oaname,'write');
if tridim
  Zmodel=-nc{'Z'}(:);
  Nmodel=length(Z);
  if Nmodel~=Ndata
    error('Number of vertical levels mismatch')
  end
  if Zmodel~=Z
    error('Vertical levels mismatch')
  end
end
%
% loop on time
%
for l=1:tlen
  disp(['  Time index ',num2str(l),' of ',num2str(tlen)]) 
  if tridim
    for k=1:Ndata
      data=squeeze(ncdata{dataname}(l,k,jmin:jmax,imin:imax));
      datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
    end
    nc{vname}(l,:,:,:)=datazgrid;
  else
    data=squeeze(ncdata{dataname}(l,jmin:jmax,imin:imax));
    nc{vname}(l,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
end
close(nc);
close(ncdata);
return
