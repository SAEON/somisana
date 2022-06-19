function extract_ECCO_V2(OGCM_dir,OGCM_prefix,url,Y,M,catalog_vname,...
    catalog_vname2,...
    lon,lat,depth,...
    krange,jrange,...
    i1min,i1max,i2min,i2max,i3min,i3max,......
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
%  Updated    6-Sep-2006 by Pierrick Penvenmake_C
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['    Download ECCO2 for ',num2str(Y),...
    ' - ',num2str(M)])
%
% Get Matlab version
%
matversion=version('-release');
matlab_new=~verLessThan('matlab','7.14');
disp([' Matlab version : ',matversion])
disp(['    !!! WARNING !!! '])
if matlab_new
  disp(['    Matlab version >= 2012a '])
  disp(['    --> use Matlab built-in support for OPeNDAP'])
  disp(['        with Matlab scripts in Opendap_tools_no_loaddap'])
  disp(['        (set path in start.m)'])
else
  disp(['    Matlab version < 2012a '])
  disp(['    --> use Matlab scripts in Opendap_tools'])
  disp(['        (set path in start.m)'])
end
disp(['    !!! WARNING !!! '])
%
% Get the number of days in the month
%
nmax=daysinmonth(Y,M);
%%nmax=5;
Lm=length(lon);
Mm=length(lat);
N=length(depth);
%int_3D=3; % Interval in days between ECCO2 data for 3D variables
%int_2D=1; % Interval in days between ECCO2 data for 2D variables
for vv=1:length(catalog_vname)
    vname=char(catalog_vname(vv));
    vname2=char(catalog_vname2(vv));
    prefix=[char(vname),'.nc/'];
    % Get starting day of month
    if strcmp(vname,'THETA')
        Dst=1;
        disp(['-->'])
        disp([' Check ',vname,' for ',datestr(datenum(Y,M,Dst,0,0,0))])
        fname0=get_filename_ECCO2(vname,Y,M,Dst);
        fname=[url,prefix,fname0];
        % Determine if dap file exists at day D0
        %   --> if not, increment
        dok=[];
        try; dok=loaddap('-A -e +v ',fname); end;
        while isempty(dok)==1
            Dst=Dst+1;
            fname0=get_filename_ECCO2(vname,Y,M,Dst);
            fname=[url,prefix,fname0];
            try; dok=loaddap('-A -e +v ',fname); end;
        end
    end
    % Compute 3D variable every 3 days
    if ~strcmp(vname,'SSH')% v-> name='UVEL, VVEL'
        var0=nan*zeros(N,Mm,Lm);
        tndx=0;
        for D=Dst:3:nmax
            tndx=tndx+1;
            disp(['===>'])
            disp([' Downloading ',vname,' for ',datestr(datenum(Y,M,D,0,0,0))])
            fname0=get_filename_ECCO2(vname,Y,M,D);
            fname=[url,prefix,fname0];
            time=readdap(fname,'TIME',[]);
            time3d(tndx)=time+datenum(1992,1,1)-datenum(Yorig,1,1);
            x=readattribute(fname);
            eval(['missing_value=x.',vname,'.missing_value;'])
            var0=getdap('',fname,vname,'[0:0]', ...
                           krange,jrange,i1min,i1max,i2min,i2max,i3min,i3max);
            var0(var0<=-2000)=NaN;
            if matlab_new
              var(tndx,:,:,:)=var0;
            else
              var(tndx,:,:,:)=permute(var0,[3 1 2]); % old readdap version
            end
            %size(var)
        end
        if strcmp(vname,'UVEL')
            u=var;
        elseif strcmp(vname,'VVEL')
            v=var;
        elseif strcmp(vname,'THETA')
            temp=var;
        elseif strcmp(vname,'SALT')
            salt=var;
        end
        % disp(['Write variable ',vname2])
        % create_ECCO2_3D([OGCM_dir,vname2,'_Y',num2str(Y),'M',num2str(M),'.cdf'], ...
        %                 vname2,lon,lat,depth,time3d,var,Yorig)
        clear var
        
    else
        
        % Compute 2D variable every 3 days also!
        var0=nan*zeros(Mm,Lm);
        tndx=0;
        for D=Dst:3:nmax
            tndx=tndx+1;
            disp(['===>'])
            disp([' Downloading ',vname,' for ',datestr(datenum(Y,M,D,0,0,0))])
            fname0=get_filename_ECCO2(vname,Y,M,D);
            fname=[url,prefix,fname0];
            time=readdap(fname,'TIME',[]);
            time3d(tndx)=time+datenum(1992,1,1)-datenum(Yorig,1,1);
            x=readattribute(fname);
            eval(['missing_value=x.',vname,'.missing_value;'])
            var0=getdap('',fname,vname,'[0:0]','', ...
                           jrange,i1min,i1max,i2min,i2max,i3min,i3max);
            var0(var0<=-2000)=NaN;
            var(tndx,:,:)=var0;
        end
        if strcmp(vname,'SSH')
            ssh=var;
        end
        % disp(['Write variable ',vname2])
        % create_ECCO2_2D([OGCM_dir,vname2,'_Y',num2str(Y),'M',num2str(M),'.cdf'], ...
        %                 vname2,lon,lat,time3d,var,Yorig)
        clear var

    end %-> if

end     %-> catalogue_vname list

%
% Create ECCO file and write variables
%
create_ECCO2([OGCM_dir,OGCM_prefix,'Y',num2str(Y),'M',num2str(M),'.cdf'],...
             lon,lat,lon,lat,lon,lat,depth,time3d,temp,salt,u,v,ssh,Yorig)

return
