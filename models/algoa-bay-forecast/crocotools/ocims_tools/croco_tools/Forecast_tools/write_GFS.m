function write_GFS(fname,Yorig,lon,lat,mask,time,tx,ty,tair,rhum,prate,wspd,uwnd,vwnd,radlw,radlw_in,radsw)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function write_GFS(fname,Yorig,lon,lat,mask,time,tx,ty,...
%                     tair,rhum,prate,wspd,radlw,radsw)
%
%  Write into a GFS file
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
%  Updated    9-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(['Create ',fname])
nc=netcdf([fname],'clobber');
%
nc('lon') = length(lon);
nc('lat') = length(lat);
%
% nc('latu') = length(lat);
% nc('latv') = length(lat)-1;
% nc('lonu') = length(lon)-1;
% nc('lonv') = length(lon);
%
nc('time') = length(time);
%
nc{'lon'} = ncfloat('lon');
nc{'lon'}.long_name = ncchar('longitude of RHO-points');
nc{'lon'}.long_name = 'longitude of RHO-points';
nc{'lon'}.units = ncchar('degree_east');
nc{'lon'}.units = 'degree_east';
% 
nc{'lat'} = ncfloat('lat');
nc{'lat'} = ncdouble('eta_rho', 'xi_rho');
nc{'lat'}.long_name = ncchar('latitude of RHO-points');
nc{'lat'}.long_name = 'latitude of RHO-points';
nc{'lat'}.units = ncchar('degree_north');
nc{'lat'}.units = 'degree_north';
%
nc{'time'} = ncfloat('time');
nc{'time'}.long_name = ncchar('Time');
nc{'time'}.long_name = 'Time';
eval(['nc{''time''}.units = ncchar(''days since 1-Jan-',num2str(Yorig),' 00:00:0.0'');'])
eval(['nc{''time''}.units = ''days since 1-Jan-',num2str(Yorig),' 00:00:0.0'';'])
%
nc{'mask'} = ncfloat('lat','lon');
nc{'tx'} = ncfloat('time','lat','lon');
nc{'ty'} = ncfloat('time','lat','lon');
nc{'tair'} = ncfloat('time','lat','lon');
nc{'rhum'} = ncfloat('time','lat','lon');
nc{'prate'} = ncfloat('time','lat','lon');
nc{'wspd'} = ncfloat('time','lat','lon');
nc{'radlw'} = ncfloat('time','lat','lon');
nc{'radsw'} = ncfloat('time','lat','lon');
nc{'radlw_in'} = ncfloat('time','lat','lon');
nc{'uwnd'} = ncfloat('time','lat','lon');
nc{'vwnd'} = ncfloat('time','lat','lon');
%
endef(nc);
%
nc{'lon'}(:)=lon;
nc{'lat'}(:)=lat;
nc{'time'}(:)=time;
nc{'mask'}(:)=mask;
nc{'tx'}(:)=tx;
nc{'ty'}(:)=ty;
nc{'tair'}(:)=tair;
nc{'rhum'}(:)=rhum;
nc{'prate'}(:)=prate;
nc{'wspd'}(:)=wspd;
nc{'uwnd'}(:)=uwnd;
nc{'vwnd'}(:)=vwnd;
nc{'radlw'}(:)=radlw;
nc{'radlw_in'}(:)=radlw_in;
nc{'radsw'}(:)=radsw;
%
close(nc)








