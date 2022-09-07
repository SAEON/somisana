function extract_mercator(OGCM_dir,OGCM_prefix,url,Y,M,...
                      lon,lon_u,lat,lat_v,depth,...
                      krange,jrange,jrange_v,...
                      i1min,i1max,i2min,i2max,i3min,i3max,...
                      i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u,...
                      Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subset from ECCO using DODS
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
%  Updated    6-Sep-2006 by Pierrick Penven
%  Updated    20-Aug-2008 by Matthieu Caillaud & P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['    Download mercator for ',num2str(Y),...
      ' - ',num2str(M)])

%
% Get the dataset attributes
%

%  test if the file exist
%
%
foundfile=0;
  fname=url;
  warning off
  try
    x=loaddap('-A -e +v ', fname);
    foundfile=1;
  catch
    foundfile=0;
  end
  if foundfile==1 & ~isempty(x)
    disp('  File found')
  else
    foundfile=0;
    disp('  File does not exist')
  end
  warning on
%
%
missval=x.ssh.missing_value; %PSY3V1

%missval=x.ssh.ml__FillValue; %PSY3V2



%
% Get the time range
%
time=readdap(fname,'time',[]);
%
% Process the time
%
time=time+datenum(1950,1,1);

disp(datestr(time));
c=datevec(time);
y0=c(:,1);
m0=c(:,2);
d0=c(:,3);
oktime=1;
d=[12;13;14;15;16;17;18];
if Y~=mean(y0)
  disp(['Warning: dates are not all for year: ',num2str(Y)])
  oktime=0;
end
tndx=find(m0==M & y0==Y);
if isempty(tndx)
  error('Time problem: did not find the corresponding month')
end
%
if oktime==0 & M==12 % to get the value of 1 jan of next year %
  tndx=[tndx;tndx(end)+1];
end

trange=['[',num2str(min(tndx)-1),':',num2str(max(tndx)-1),']'];


% tndx=find(m0==M & y0==Y);
   % trange=['[',num2str(tndx(1)-1),']'];

%
% Put the time into "Yorig time"
%
time=time(tndx)-datenum(Yorig,1,1);
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
%missval=x.ssh.missing_value;
ssh(ssh>=missval)=NaN;	
%
% Get TAUX
%
disp('    ...TAUX')
taux=getdap(url,fname,...
            'taux',trange,'',jrange,...
            i1min,i1max,i2min,i2max,i3min,i3max);


%missval=x.taux.missing_value;
taux(taux>=missval)=NaN;
%
% Get TAUY
%
disp('    ...TAUY')
tauy=getdap(url,fname,...
            'tauy',trange,'',jrange,...
            i1min,i1max,i2min,i2max,i3min,i3max);
%missval=x.tauy.missing_value;
tauy(tauy>=missval)=NaN;
%

% Get U
%
disp('    ...U')
vname='u';
u=getdap(url,fname,vname,...
          trange,krange,jrange,...
          i1min_u,i1max_u,i2min_u,i2max_u,i3min_u,i3max_u);
u=permute(u,[4 3 1 2]);
%u=shiftdim(u,2);
%missval=x.u.missing_value;
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
%missval=x.v.missing_value;
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

%temp=shiftdim(temp,2);
%missval=x.temperature.missing_value;
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
%salt=shiftdim(salt,2);
%missval=x.salinity.missing_value;
salt(salt>=missval)=NaN;
%
% Create the ECCO file
%
fname=url
%
%
create_OGCM([OGCM_dir,OGCM_prefix,'Y',num2str(Y),'M',num2str(M),'.cdf'],...
             lon,lat,lon_u,lat,lon,lat_v,depth,time,...
             temp,salt,u,v,ssh,Yorig)
%
return
