function add_ini_no3(ininame,grdname,oaname,cycle,NO3min);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,no3]=add_ini_no3(ininame,grdname,...
%                                           seas_datafile,ann_datafile,...
%                                           cycle);
%
%  Add nitrate (mMol N m-3) in a CROCO initial file.
%  take seasonal data for the upper levels and annual data for the
%  lower levels.
%  do a temporal interpolation to have values at initial
%  time.
%
%  input:
%    
%    ininame       : croco initial file to process (netcdf)
%    grdname      : croco grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,no3] : surface field to plot (as an illustration)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp('Add_ini_no3: creating variable and attribute')
%
% open the grid file  
% 
nc=netcdf(grdname,'r');
h=nc{'h'}(:);
close(nc);
%
% open the initial file  
% 
nc=netcdf(ininame,'write');
theta_s = nc{'theta_s'}(:);
if isempty(theta_s)
  disp('Restart file')
  theta_s=nc.theta_s(:);
  theta_b=nc.theta_b(:);
  hc=nc.hc(:);
else
  theta_b =  nc{'theta_b'}(:);
  hc  =  nc{'hc'}(:);
  vtransform = nc{'Vtransform'}(:);
  if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
  end
end
N =  length(nc('s_rho'));
%
% open the oa file  
% 
noa=netcdf(oaname,'r');
z=-noa{'Zno3'}(:);
oatime=noa{'no3_time'}(:);
tlen=length(oatime);
%
% Get the sigma depths
%
zcroco=zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform);
zmin=min(min(min(zcroco)));
zmax=max(max(max(zcroco)));
%
% Check if the min z level is below the min sigma level 
%    (if not add a deep layer)
%
%addsurf=max(z)<zmax;
addsurf=1;
addbot=min(z)>zmin;
if addsurf
 z=[100;z];
end
if addbot
 z=[z;-100000];
end
Nz=min(find(z<zmin));
z=z(1:Nz);
%
% read in the initial file  
% 
scrum_time = nc{'scrum_time'}(:);
scrum_time = scrum_time / (24*3600);
tinilen = length(scrum_time);
%redef(nc);
nc{'NO3'} = ncdouble('time','s_rho','eta_rho','xi_rho');
nc{'NO3'}.long_name = ncchar('Nitrate');
nc{'NO3'}.long_name = 'Nitrate';
nc{'NO3'}.units = ncchar('mMol N m-3');
nc{'NO3'}.units = 'mMol N m-3';
nc{'NO3'}.fields = ncchar('NO3, scalar, series');
nc{'NO3'}.fields = 'NO3, scalar, series';
%endef(nc);
%
%  loop on initial time
%
for l=1:tinilen
  disp(['time index: ',num2str(l),' of total: ',num2str(tinilen)])
%
%  get data time indices and weights for temporal interpolation
%
  if cycle~=0
    modeltime=mod(scrum_time(l),cycle);
  else
    modeltime=scrum_time;
  end
  l1=find(modeltime==oatime);
  if isempty(l1)
    disp('temporal interpolation')
    l1=max(find(oatime<modeltime));
    time1=oatime(l1);
    if isempty(l1)
      if cycle~=0
        l1=tlen;
        time1=oatime(l1)-cycle;
      else
        error('No previous time in the dataset')
      end
    end
    l2=min(find(oatime>modeltime));
    time2=oatime(l2);
    if isempty(l2)
      if cycle~=0
        l2=1;
        time2=oatime(l2)+cycle;
      else
        error('No posterious time in the dataset')
      end
    end
    disp(['Initialisation time: ',num2str(modeltime),...
          ' - Time 1: ',num2str(time1),...
          ' - Time 2: ',num2str(time2)])	 
    cff1=(modeltime-time2)/(time1-time2);
    cff2=(time1-modeltime)/(time1-time2);
  else
    cff1=1;
    l2=l1;
    cff2=0;
  end
%
% interpole the seasonal dataset on the horizontal croco grid
%
  disp(['Add_ini_no3: vertical interpolation'])
  var=squeeze(noa{'NO3'}(l1,:,:,:));
  if addsurf
    var=cat(1,var(1,:,:),var);
  end
  if addbot
    var=cat(1,var,var(end,:,:));
  end
  var2=squeeze(noa{'NO3'}(l2,:,:,:));
  if addsurf
    var2=cat(1,var2(1,:,:),var2);
  end
  if addbot
    var2=cat(1,var2,var2(end,:,:));
  end
  var=cff1*var + cff2*var2;
  zeta = squeeze(nc{'zeta'}(l,:,:));
  zcroco=zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
  nc{'NO3'}(l,:,:,:)=ztosigma(flipdim(var,1),zcroco,flipud(z));
end
close(noa);
%
% Remove low values for oligotrophic areas
%
for l=1:tinilen
  NO3=nc{'NO3'}(l,:,:,:);
  NO3(NO3<NO3min)=0;
  nc{'NO3'}(l,:,:,:)=NO3;
end
close(nc);
return
