function field=get_missing_val(lon,lat,field,missvalue,ro,default)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function field=get_missing_val(lon,lat,field,missvalue,ro,default)
%
%  pierrick 2001
%
%  perform an objective analysis to fill
%  the missing points of an horizontal gridded slice
%
%
%  input: 
%    lon      : longitude
%    lat      : latitude
%    field    : input 2D field
%    missvalue: value of the bad points (e.g. -99.999)
%    ro       : oa decorrelation scale
%    default  : default value given if there is only missing data
%
%  output:
%    field    : output 2D field
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<4
  oa_interp=0;
  missvalue=NaN;
  default=0;
elseif nargin<5
  oa_interp=0;
  default=0;
elseif nargin<6
  default=0;
end

% 
%  Choose extrapolation method
%
oa_interp=0;

%
%  get a masking matrix and the good data matrix
%
if isnan(missvalue)
  ismask=isnan(field);
else
  ismask=(field==missvalue);
end
isdata=1-ismask;
[M,L]=size(field);

if sum(size(lon))==(length(squeeze(lon))+1)
  [lon,lat]=meshgrid(lon,lat);
end
%
% test if there are any data
%
if (sum(sum(isdata))==0) 
%  disp('no data')
  field=zeros(M,L)+default;
  return
elseif (sum(sum(isdata))<6) 
  default=min(field(isdata==1));
  disp('no enough data to fill missing values')
  disp([' ... using default value:',num2str(default)])
  field=zeros(M,L)+default;
  interp_flag=0;
  return
end
if (sum(sum(ismask))==0) 
%  disp('no mask')
  return
end

if oa_interp
%---------------------------------------------------------------
% Objective Analysis
%---------------------------------------------------------------
  if (sum(sum(ismask))==1) 
%   disp('1 mask')
    [j,i]=find(ismask==1);
    lat0=lat(j,i);
    lon0=lon(j,i);
    if j>1
      od1=1./spheric_dist(lat0,lat(j-1,i),lon0,lon(j-1,i));
      f1=field(j-1,i);
    else
      od1=0;
      f1=0;
    end
    if j<M
      od2=1./spheric_dist(lat0,lat(j+1,i),lon0,lon(j+1,i));
      f2=field(j+1,i);
    else
      od2=0;
      f2=0;
    end
    if i>1
      od3=1./spheric_dist(lat0,lat(j,i-1),lon0,lon(j,i-1));
      f3=field(j,i-1);
    else
      od3=0;
      f3=0;
    end
    if i<L
      od4=1./spheric_dist(lat0,lat(j,i+1),lon0,lon(j,i+1));
      f4=field(j,i+1);
    else
      od4=0;
      f4=0;
    end
    field(j,i)=(od1.*f1+od2.*f2+od3.*f3+od4.*f4)./...
               (od1+od2+od3+od4);
    return
  end

  field(ismask)=oainterp(lon(~ismask),lat(~ismask),field(~ismask),...
                         lon(ismask),lat(ismask),ro);

else

%---------------------------------------------------------------
% Extrapolation using nearest values
%--------------------------------------------------------------

field(ismask)=griddata(lon(~ismask),lat(~ismask),field(~ismask),...
                       lon(ismask),lat(ismask),'nearest');
end
return
