function extract_SODA(SODA_dir,SODA_prefix,url,year,month,...
                      lon,lat,depth,time,...
                      trange,krange,jrange,...
                      i1min,i1max,i2min,i2max,i3min,i3max,...
                      Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract a subset from SODA using OPENDAP
% Write it in a local file (keeping the classic
% SODA netcdf format) 
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated   6-Sep-2006 by Pierrick Penven
%  Updated : 23-Oct-2009 by Gildas Cambon Adapatation for the special tratment 
%            for the bry file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(['    Download SODA for ',num2str(year),...
      ' - ',num2str(month)])
%
% Get the dataset attributes
%
disp('Get the dataset attributes')
x=readattribute(url);
try 
  missval=x.ssh.missing_value	
  missname='missing_value';
catch
  missname='ml__FillValue';
end
%
% Get SSH
%
disp('    ...SSH')
ssh=getdap(url,'',...
	       'ssh',trange,'',jrange,...
	       i1min,i1max,i2min,i2max,i3min,i3max);
eval(['missval=double(x.ssh.',missname,');'])
if missval<0
  ssh(ssh<=(0.9*missval))=NaN;
else
  ssh(ssh>=(0.9*missval))=NaN;
end
%
% Get TAUX
%
disp('    ...TAUX')
taux=getdap(url,'',...
		'taux',trange,'',jrange,...
		i1min,i1max,i2min,i2max,i3min,i3max);
eval(['missval=double(x.taux.',missname,');'])
if missval<0
  taux(taux<=(0.9*missval))=NaN;
else
  taux(taux>=(0.9*missval))=NaN;
end
%
% Get TAUY
%
disp('    ...TAUY')
tauy=getdap(url,'',...
		'tauy',trange,'',jrange,...
		i1min,i1max,i2min,i2max,i3min,i3max);
eval(['missval=double(x.tauy.',missname,');'])
if missval<0
  tauy(tauy<=(0.9*missval))=NaN;
else
  tauy(tauy>=(0.9*missval))=NaN;
end
%
% Get U
%
disp('    ...U')
u=getdap(url,'',...
	     'u',trange,krange,jrange,...
	     i1min,i1max,i2min,i2max,i3min,i3max);
u=shiftdim(u,2);
eval(['missval=double(x.u.',missname,');'])
if missval<0
  u(u<=(0.9*missval))=NaN;
else
  u(u>=(0.9*missval))=NaN;
end
%
% Get V
%
disp('    ...V')
v=getdap(url,'',...
	     'v',trange,krange,jrange,...
	     i1min,i1max,i2min,i2max,i3min,i3max);
v=shiftdim(v,2);
eval(['missval=double(x.v.',missname,');'])
if missval<0
  v(v<=(0.9*missval))=NaN;
else
  v(v>=(0.9*missval))=NaN;
end
%
% Get TEMP
%
disp('    ...TEMP')
temp=getdap(url,'',...
		'temp',trange,krange,jrange,...
		i1min,i1max,i2min,i2max,i3min,i3max);
temp=shiftdim(temp,2);
eval(['missval=double(x.temp.',missname,');'])
if missval<0
  temp(temp<=(0.9*missval))=NaN;
else
  temp(temp>=(0.9*missval))=NaN;
end
%
% Get SALT
%
disp('    ...SALT')
salt=getdap(url,'',...
		'salt',trange,krange,jrange,...
		i1min,i1max,i2min,i2max,i3min,i3max);
salt=shiftdim(salt,2);
eval(['missval=double(x.salt.',missname,');'])
if missval<0
  salt(salt<=(0.9*missval))=NaN;
else
  salt(salt>=(0.9*missval))=NaN;
end
%
% Create the SODA file
%
create_SODA([SODA_dir,SODA_prefix,'Y',num2str(year),'M',num2str(month),'.cdf'],...
            lon,lat,lon,lat,lon,lat,depth,time,...
            temp,salt,u,v,ssh,taux,tauy,Yorig)
%
return
