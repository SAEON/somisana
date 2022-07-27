function [field,interp_flag]=get_missing_val(lon,lat,field,missvalue,ro,default,savefile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function field=get_missing_val(lon,lat,field,missvalue,ro,default)
%
%  Perform an objective analysis to fill
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
%  Contributions from Patrick Marchesiello (IRD) and Jerome Lefevre (IRD)
%
%  Updated    6-Sep-2006 by Pierrick Penven
%  Updated    2-Oct-2006 by Xavier Capet and Pierrick Penven 
%                        (add the 'savefile option')
% Menkes 2007 correct for Ro
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interp_flag=1;
if nargin<4
  oa_interp=0;
  missvalue=NaN;
  default=0;
  ro=0;
elseif nargin<5
  oa_interp=0;
  default=0;
  ro=0;
elseif nargin<6
  default=0;
end
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
%
if sum(size(lon))==(length(squeeze(lon))+1)
  [lon,lat]=meshgrid(lon,lat);
end
%
% Check dimensions
%
if size(lon)~=size(field)
 error('GET-MISSING_VALUE: sizes do not correspond')
end

%
% test if there are any data
%
if (sum(sum(isdata))==0) 
%  disp('no data')
  %disp(['GET_MISSING_VAL: No data point -> using default value:',...
  %     num2str(default)])
  field=zeros(M,L)+default;
  interp_flag=0;
  return
elseif (sum(sum(isdata))<6) 
%  default=min(field(isdata==1));
  default=mean(field(isdata==1));
  %disp(['GET_MISSING_VAL: only ',num2str(sum(sum(isdata))),...
  %      ' data points: using the mean value:',num2str(default)])
  field=zeros(M,L)+default;
  interp_flag=0;
  return
end
if (sum(sum(ismask))==0) 
%  disp('no mask')
  return
end

if ro>0
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
%
% perform the oa (if savefile is given, store the distances matrices 
%                 (r1 and r2) in a tmp.mat file)
%
  if nargin == 7
     field(ismask)=oainterp(lon(~ismask),lat(~ismask),field(~ismask),...
                            lon(ismask),lat(ismask),ro,savefile);
  else 
     field(ismask)=oainterp(lon(~ismask),lat(~ismask),field(~ismask),...
                            lon(ismask),lat(ismask),ro,2);
  end
else
%---------------------------------------------------------------
% Extrapolation using nearest values
%--------------------------------------------------------------
  field(ismask)=griddata(lon(~ismask),lat(~ismask),field(~ismask),...
                         lon(ismask),lat(ismask),'nearest');
end
return




