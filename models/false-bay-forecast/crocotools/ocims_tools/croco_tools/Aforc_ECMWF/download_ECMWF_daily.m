function download_ECMWF_daily(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
    ECMWF_dir,Yorig,My_ECMWF_dir)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract data from global netcdf format saved on my computer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Illig, 2010, from download_NCEP
%  Updated    January 2016 (E. Cadier and S. Illig)
%

if nargin < 1
    Ymin=2007;
    Ymax=2008;
    Yorig=1900;
    Mmin=12;
    Mmax=1;
    lonmin=10;
    lonmax=30;
    latmin=-40;
    latmax=-20;
    ECMWF_dir='DATA/NCEP_Peru/';
    My_ECMWF_dir='../NCEP_REA1/';
end
%
% Definitions of names and directories
%
disp(['===================='])
disp(['Direct CONVERT Procedure'])
disp(['===================='])

disp(['ECMWF directory:'])
ecmwf_url=My_ECMWF_dir
catalog={'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...    
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ... 
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    'EI_ecmwf_' ...
    ''};
vnames={'SSTK'...  % surface land-sea mask [1=land; 0=sea]
    'T2M' ...      % 2 m temp. [k]
    'SSTK' ...     % surface temp. [k]
    'U10M' ...     % 10 m u wind [m/s]
    'V10M' ...     % 10 m v wind [m/s]
    'Q' ...        % 2 m specific humidity [kg/kg]
    'SWH' ...      % significant wave height [m]
    'MWD' ...      % mean wave direction [degree]
    'PP1D' ...     % peak wave period [s]
    'STR' ...      % surface thermal radiation [w/m^2.s] -> [w/m^2]
    'STRD' ...     % surface downward thermal radiation [w/m^2.s] -> [w/m^2]
    'SSR' ...      % surface solar radiation [w/m^2.s] -> [w/m^2]
    'TP' ...       % surface precipitation rate [m]->[kg/m^2/s]
    'EWSS' ...     % east-west surface stress [N m-2 s] -> [N m-2]
    'NSSS' ...     % north-south surface stress [N m-2 s] -> [N m-2]
    };
fnames={'sst'...  % surface land-sea mask [1=land; 0=sea]
    't2m' ...      % 2 m temp. [k]
    'sst' ...     % surface temp. [k]
    'u10' ...     % 10 m u wind [m/s]
    'v10' ...     % 10 m v wind [m/s]
    'q' ...        % 2 m specific humidity [kg/kg]
    'swh' ...      % significant wave height [m]
    'mwd' ...      % mean wave direction [degree]
    'pp1d' ...     % peak wave period [s]
    'str' ...      % surface thermal radiation [w/m^2.s] -> [w/m^2]
    'strd' ...     % surface downward thermal radiation [w/m^2.s] -> [w/m^2]
    'ssr' ...      % surface solar radiation [w/m^2.s] -> [w/m^2]
    'tp' ...       % surface precipitation rate [m]->[kg/m^2/s]
    'ewss' ...     % east-west surface stress [N m-2 s] -> [N m-2]
    'nsss' ...     % north-south surface stress [N m-2 s] -> [N m-2]
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Common OpenDAP FTP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([' '])
disp(['Get ECMWF data from ',num2str(Ymin),' to ',num2str(Ymax)])
disp(['From ',ecmwf_url]);
disp([' '])
disp(['Minimum Longitude: ',num2str(lonmin)])
disp(['Maximum Longitude: ',num2str(lonmax)])
disp(['Minimum Latitude: ',num2str(latmin)])
disp(['Maximum Latitude: ',num2str(latmax)])
disp([' '])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Making output data directory ',ECMWF_dir])
eval(['!mkdir ',ECMWF_dir])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find a subset of the ECMWF grid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ifile=[char(ecmwf_url),char(catalog(1)),char(vnames(1)),'_',sprintf('%04d',Ymin),sprintf('%02d',Mmin),'.nc'];
[i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax,lon,lat]=...
 get_ECMWF_subgrid(ifile,lonmin,lonmax,latmin,latmax);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global loop on variable names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:length(vnames)
    disp(['=========================='])
    disp(['VNAME IS ',char(vnames(k))]);
    disp(['=========================='])
    %
    % 
    vname=char(vnames(k));
    fname=char(fnames(k));
    if k==1 % Dealing with the mask (using SST)
        %
        disp(['==========================']);
        disp(['Get the Land Mask tindex = 1']);
        disp(['Get the Land Mask by using SSTK']);
        disp([' '])
        %
        ifile=[char(ecmwf_url),char(catalog(k)),vname,'_',sprintf('%04d',Ymin),sprintf('%02d',Mmin),'.nc'];
        var=extract_ECMWF(ifile,fname,Ymin,Mmin,20,i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax);
        var(var == min(min(var)))=NaN;
        mask=var-var;
        write_ECMWF_Mask([ECMWF_dir,'land_Y',num2str(Ymin),'M',num2str(Mmin),'.nc'],...
		      'land',lon,lat,mask)
        disp([' '])
        %
    end
    %
    % Loop on the years
    %
    for Y=Ymin:Ymax
        disp(['=========================='])
        disp(['Processing year: ',num2str(Y)])
        disp(['=========================='])
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Loop on the months
        %
        if Y==Ymin
            mo_min=Mmin;
        else
            mo_min=1;
        end
        if Y==Ymax
            mo_max=Mmax;
        else
            mo_max=12;
        end
        %
        for M=mo_min:mo_max
            
            if k<=9   % t2m, sst, u10, v10, q
                
                file =[ECMWF_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'];
                ifile=[char(ecmwf_url),char(catalog(k)),vname,'_',sprintf('%04d',Y),sprintf('%02d',M),'.nc'];
                %
                var=extract_ECMWF(ifile,fname,Y,M,':',i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax);
                %                
                %--> do running daily mean with filter function
                b=[0.5 1 1 1 0.5]/4.;
                a=[1 0 0 0 0];
                var2=filtfilt(b,a,var); clear var;
                var3=var2(5+2:end-2,:,:);clear var2;
                %
                %--> Extract noon ponts
                var2=var3(3:4:end-1,:,:);clear var3;
                %
                time2=datenum(Y,M,1)-datenum(Yorig,1,1)+[1:size(var2,1)]-0.5;
                write_ECMWF(file,vname,lon,lat,time2,var2,Yorig);
                clear time;clear var;clear time2;clear var2;
                disp([' ']);
            
            elseif k<=13 % str, strd, ssr, tp
        
                file=[ECMWF_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'];
                ifile12 = [char(ecmwf_url),char(catalog(k)),vname,'_',sprintf('%04d',Y),sprintf('%02d',M),'_step12.nc'];
                ifile24 = [char(ecmwf_url),char(catalog(k)),vname,'_',sprintf('%04d',Y),sprintf('%02d',M),'_step24.nc'];
                %
                nc12 = netcdf(ifile12);
                nFullTime=length(squeeze(nc12{'time'}(:)));
                close(nc12);
                %
                var1 = extract_ECMWF(ifile12,fname,Y,M,1:2:nFullTime,i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax);
                var2 = extract_ECMWF(ifile24,fname,Y,M,1:2:nFullTime,i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax);
                var3 = extract_ECMWF(ifile12,fname,Y,M,2:2:nFullTime,i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax);  
                var4 = extract_ECMWF(ifile24,fname,Y,M,2:2:nFullTime,i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax);
                %
                div=(86400./2.);
                if strcmp(vname,'TP') 
                    div=div/1000.;
                end
                if strcmp(vname,'STR') 
                    div=-1.*div;
                end    
                %
                %--> Extract noon ponts
                var12=(var2-var1)/div; %devide by 12h
                var34=(var4-var3)/div;
                %
                var=(var12(2:end-1,:,:)+var34(1:end-2,:,:))/2.;
                %
                time=datenum(Y,M,1)-datenum(Yorig,1,1)+[1:size(var,1)]-0.5;
                write_ECMWF(file,vname,lon,lat,time,var,Yorig);
                clear time; clear time1;clear var12;clear var34;clear var1;clear var2;clear var3;clear var4;clear var;clear var2;clear div;
                disp([' ']);
            
            else  % ewss, nsss
                
                file=[ECMWF_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'];
                %
                ifile3  = [char(ecmwf_url),char(catalog(k)),vname,'_',sprintf('%04d',Y),sprintf('%02d',M),'_step3.nc'];
                ifile9  = [char(ecmwf_url),char(catalog(k)),vname,'_',sprintf('%04d',Y),sprintf('%02d',M),'_step9.nc'];
                ifile15 = [char(ecmwf_url),char(catalog(k)),vname,'_',sprintf('%04d',Y),sprintf('%02d',M),'_step15.nc'];
                %
                div   = (86400./4.);
                var3  = extract_ECMWF(ifile3,fname,Y,M,':',i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax)/div;  %devide by 6h;
                var9  = extract_ECMWF(ifile9,fname,Y,M,':',i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax)/div;  %devide by 6h;
                var15 = extract_ECMWF(ifile15,fname,Y,M,':',i1min,i1max,i2min,i2max,i3min,i3max,jmin,jmax)/div; %devide by 6h;
                %
                nc3   = netcdf(ifile3);
                time3  = squeeze(nc3{'time'}(:));
                close(nc3);   
                %
                var(1:2:(length(time3)-1)*2-1,:,:)=var15(1:end-1,:,:)-var9(1:end-1,:,:);
                var(2:2:(length(time3)-1)*2,:,:)=var9(2:end,:,:)-var3(2:end,:,:);
                %
                b=[1 1 1 1]/4.;
                a=[1 0 0 0];
                var2=filtfilt(b,a,var); 
                var3=var2(1:end,:,:);clear var2;
                var2=var3(5:4:end-4,:,:);
                %
                time2=datenum(Y,M,1)-datenum(Yorig,1,1)+[1:size(var2,1)]-0.5;
                %
                clear var3; clear var9; clear var15;clear div;         
                %
                write_ECMWF(file,vname,lon,lat,time2,var2,Yorig);
                clear time; clear var;
                disp([' ']);
            end % end if
        end % end loop month
    end % end loop year
end % loop k
%
return
