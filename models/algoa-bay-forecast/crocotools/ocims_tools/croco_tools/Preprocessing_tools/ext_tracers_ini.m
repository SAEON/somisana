function ext_tracers_ini(ininame,grdname,seas_datafile,ann_datafile,...
                         dataname,vname,type,tini);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% P. Marchesiello - 2005. Adapted from P. Penven's ext_tracers.m 
%
%  Ext tracers in a CROCO initial file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    ininame       : CROCO initial file name
%    grdname       : CROCO grid file name    
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    dataname      : variable name in data file
%    vname         : variable name in CROCO file
%    type          : position on C-grid ('r', 'u', 'v', 'p')
%    tini          : initialisation time [days]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
%
% set the value of ro (oa decorrelation scale [m]) 
% and default (value if no data)
%
ro=0;
default=NaN;
disp([' Ext tracers: ro = ',num2str(ro/1000),...
      ' km - default value = ',num2str(default)])

% Open initial file
%
nc=netcdf(ininame,'write');
theta_s = nc{'theta_s'}(:);
theta_b =  nc{'theta_b'}(:);
hc  =  nc{'hc'}(:);
N =  length(nc('s_rho'));
vtransform = nc{'Vtransform'}(:);
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
%
% Open and Read grid file  
% 
ng=netcdf(grdname,'r');
lon=ng{'lon_rho'}(:);
lat=ng{'lat_rho'}(:);
h=ng{'h'}(:);
close(ng);
[M,L]=size(lon);
%
% Read seasonal datafile 
%
ncseas=netcdf(seas_datafile,'r');
X=ncseas{'X'}(:);
Y=ncseas{'Y'}(:);
Zseas=-ncseas{'Z'}(:);
T=ncseas{'T'}(:).*30;
tlen=length(T);
Nzseas=length(Zseas);
%
% Read annual datafile
%
ncann=netcdf(ann_datafile,'r');
Zann=-ncann{'Z'}(:);
Nz=length(Zann);
%
% Determine time index to process
%
ll=find(T<=tini);
if (size(ll,1) ~= 0)
 l=ll(size(ll,1));
else
 l=1;
end
disp(['   ext_tracers_ini: time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% get a subgrid
%
dl=1;
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
%------------------------------------------------------------
% Horizontal interpolation
%------------------------------------------------------------
%
%
% Interpole annual dataset on horizontal CROCO grid
%
if Nz > Nzseas
  if Zseas~=Zann(1:length(Zseas)) 
    error('vertical levels dont match')
  end
  datazgrid=zeros(Nz,M,L);
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
    data=get_missing_val(x,y,data,missval,ro,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
end
close(ncann);
%
% interpole seasonal dataset on horizontal croco grid
%
disp(['   ext_tracers_ini: horizontal interpolation of seasonal data'])
missval=ncseas{dataname}.missing_value(:);
if Nz <= Nzseas
  datazgrid=zeros(Nz,M,L);
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
  data=get_missing_val(x,y,data,missval,ro,default);
  datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
end
close(ncseas);
%
%----------------------------------------------------
%  Vertical interpolation
%-----------------------------------------------------
%
disp('   ext_tracers_ini: vertical interpolation')
%
% Get the sigma depths
%
zcroco=zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform);
if type=='u'
  zcroco=rho2u_3d(zcroco);
end
if type=='v'
  zcroco=rho2v_3d(zcroco);
end
zmin=min(min(min(zcroco)));
zmax=max(max(max(zcroco)));
%
% Check if the min z level is below the min sigma level
%    (if not add a deep layer)
%
z=Zann;
addsurf=max(z)<zmax;
addbot=min(z)>zmin;
if addsurf
 z=[100;z];
end
if addbot
 z=[z;-100000];
end
Nz=min(find(z<zmin));
z=z(1:Nz);
var=datazgrid; clear datazgrid;
if addsurf
  var=cat(1,var(1,:,:),var);
end
if addbot
  var=cat(1,var,var(end,:,:));
end
var=var(1:Nz,:,:);
%
% Do the vertical interpolation and write in inifile
%
nc{vname}(1,:,:,:)=ztosigma(flipdim(var,1),zcroco,flipud(z));
close(nc);

return
