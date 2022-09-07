function extract_mercator_frcst(FRCST_dir,FRCST_prefix,url,tndx,missval,...
                      lon,lon_u,lat,lat_v,depth,...
                      krange,jrange,jrange_v,...
                      i1min,i1max,i2min,i2max,i3min,i3max,...
                      i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
                      time,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subset from Mercator using DODS
% Write it in a local file (keeping the classic
% SODA netcdf format)
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
%  Updated    9-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(['    Download MERCATOR'])
trange=['[',num2str(min(tndx)-1),':',num2str(max(tndx)-1),']'];
%trange=['[',num2str(tindex-1),':',num2str(tindex-1),']'];
%
% Get the time
%
%vname='Have';
%fname=[prefix,vname,suffix];
%time=readdap(fname,'time',trange)
%time=floor(time/24+datenum(1970,1,1));
%disp(['    Date: ',datestr(time)])
%time=time-datenum(Yorig,1,1)
%
% Get SSH
%
disp('    ...SSH')
vname='ssh';
fname='';
ssh=getdap(url,fname,vname,...
            trange,'',jrange,...
            i1min,i1max,i2min,i2max,i3min,i3max);
ssh=shiftdim(ssh,2);
ssh(ssh>=missval)=NaN;
%
%
% Get U
%
disp('    ...U')
vname='u';
u=getdap(url,fname,vname,...
          trange,krange,jrange,...
          i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u);
u=permute(u,[4 3 1 2]);
u(u>=missval)=NaN;
%
% Get V
%
disp('    ...V')
vname='v';
v=getdap(url,fname,vname,...
          trange,krange,jrange_v,...
          i1min,i1max,i2min,i2max,i3min,i3max);
v=permute(v,[4 3 1 2]);
v(v>=missval)=NaN;
%
% Get TEMP
%
disp('    ...TEMP')
vname='temperature';
temp=getdap(url,fname,vname,...
             trange,krange,jrange,...
             i1min,i1max,i2min,i2max,i3min,i3max);
temp=permute(temp,[4 3 1 2]);
temp(temp>=missval)=NaN;
%
% Get SALT
%
disp('    ...SALT')
vname='salinity';
salt=getdap(url,fname,vname,...
             trange,krange,jrange,...
             i1min,i1max,i2min,i2max,i3min,i3max);
salt=permute(salt,[4 3 1 2]);
salt(salt>=missval)=NaN;
%
%
% Create the ECCO file
rundate_str=date;
rundate=datenum(rundate_str)-datenum(Yorig,1,1);

create_OGCM([FRCST_dir,FRCST_prefix,num2str(rundate),'.cdf'],...
             lon,lat,lon_u,lat,lon,lat_v,depth,time,...
             squeeze(temp),squeeze(salt),squeeze(u),...
             squeeze(v),squeeze(ssh),Yorig)
%
return
