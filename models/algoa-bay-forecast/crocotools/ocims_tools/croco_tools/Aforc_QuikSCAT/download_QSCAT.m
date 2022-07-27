function download_QSCAT(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
    QSCAT_dir,Yorig,QSCAT_blk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subgrid from QSCAT to get a CROCO forcing
% Store that into monthly files (to limit the problems
% of bandwith...).
% Take care of the Greenwitch Meridian.
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
%  Copyright (c) 2007 by Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 1
    Ymin=2000;
    Ymax=2000;
    Yorig=1900;
    Mmin=1;
    Mmax=3;
    lonmin=12.3;
    lonmax=20.45;
    latmin=-35.5;
    latmax=-26.5;
    QSCAT_dir='DATA/QSCAT_Benguela/';
    QSCAT_blk    = 0;
end
%
url='http://www.ifremer.fr/opendap/cerdap1/cersat/wind/l4/quikscat/daily/';
%
% start
%
disp([' '])
disp(['Get QSCAT wind from ',num2str(Ymin),' to ',num2str(Ymax)])
disp(['Minimum Longitude: ',num2str(lonmin)])
disp(['Maximum Longitude: ',num2str(lonmax)])
disp(['Minimum Latitude: ',num2str(latmin)])
disp(['Maximum Latitude: ',num2str(latmax)])
disp([' '])
%
% Create the directory
%
disp(['Making output data directory ',QSCAT_dir])
eval(['!mkdir ',QSCAT_dir])
%
% Find a subset of the QSCAT grid
%
[i1min,i1max,i2min,i2max,i3min,i3max,jrange,lon,lat]=...
    get_QSCAT_grid([url,'1999/199907200000-199907210000.nc'],lonmin,lonmax,latmin,latmax);


disp(['...DOWNLOAD.....'])
disp(['...INFO.....'])
disp(['url= ',url])
disp(['lonmin= ',num2str(lonmin)])
disp(['lonmax= ',num2str(lonmax)])
disp(['latmin= ',num2str(latmin)])
disp(['latmax= ',num2str(latmax)])
disp(['SIZE LON=',num2str(size(lon))])
disp(['SIZE LAT=',num2str(size(lat))])
disp(['........'])
%
% Get the time
%
%time=readdap([url,'1999/199907200000-199907210000.nc'],'time',[]);
%
% Convert the time into "Yorig" time (i.e in days since Yorig/1/1 00:00:0.0)
%

%disp('TIME is=')
%time(1:10)

%time=time+datenum(1,1,1)-datenum(Yorig,1,1)-2; %-2 to match with CERSAT dates%
%[year,month,days,hour,min,sec]=datevec(time+datenum(Yorig,1,1));

%disp(['TIME is='])
%time(1:10)
%year(1:10)
%month(1:10)
%days(1:10)
%time(end-9:end)
%year(end-9:end)
%month(end-9:end)
%days(end-9:end)

if Ymin<1999
    error(['Quikscat first year is 1999 ; Ymin = ',num2str(Ymin)])
end
if Ymax>2009
    error(['Quikscat last year is 2009 ; Ymax = ',num2str(Ymax)])
end
if Ymin==1999 & Mmin<8
    error(['Quikscat first complete month in 1999 is August; Mmin = ',num2str(Mmin)])
end
if Ymax==2009 & Mmin>10
    error(['Quikscat last complete month in 2009 is October; Mmax = ',num2str(Mmax)])
end


%
% Loop on the years
%
for Y=Ymin:Ymax
    disp(['Processing year: ',num2str(Y)])
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
    for M=mo_min:mo_max
        disp(['  Processing month: ',num2str(M)])
        %
        % Get the time indices for this month
        %
        ndays=daysinmonth(Y,M)

        taux=zeros(1,length(lat),length(lon));
        tauy=0*taux;
        tndx=0;
        good_time=0;

        for day=1:ndays

            disp(['    Processing day: ',num2str(day)])

            if M<10
                myM=['0',num2str(M)];
            else
                myM=num2str(M);
            end

            if day<10
                myday=['0',num2str(day)];
            else
                myday=num2str(day);
            end

            qscatdate=[num2str(Y),myM,myday,'0000'];

            dayp=day+1;
            Mp=M;
            Yp=Y;
            if dayp>ndays
                Mp=Mp+1;
                dayp=1;
                if Mp>12
                    Yp=Yp+1;
                    Mp=1;
                end
            end

            if Mp<10
                myMp=['0',num2str(Mp)];
            else
                myMp=num2str(Mp);
            end

            if dayp<10
                mydayp=['0',num2str(dayp)];
            else
                mydayp=num2str(dayp);
            end

            qscatdatep=[num2str(Yp),myMp,mydayp,'0000'];
%            
            fname=[qscatdate,'-',qscatdatep,'.nc'];
            myurl=[url,num2str(Y),'/',fname];
            %
            %  Check if the file exists
            %
            x = loaddap('-A -e +v',myurl);
            if verLessThan('matlab','7.14')
                if (dods_err==1)
                    error(dods_err_msg)
                end
            end
            
            if ~isempty(x)

                disp('file found')

                time=readdap(myurl,'time',[]);
                %disp(['Processing date: ',datestr(time/24+datenum(1900,1,1))])
                time=time/24+datenum(1900,1,1)-datenum(Yorig,1,1);


                tx=getdap(myurl,[],'zonal_wind_stress',[],[],jrange,...
                    i1min,i1max,i2min,i2max,i3min,i3max);
                mval=x.zonal_wind_stress.ml__FillValue;
                scale_factor=x.zonal_wind_stress.scale_factor;
                add_offset=x.zonal_wind_stress.add_offset;
                tx(tx==mval)=NaN;
                tx=add_offset+tx.*scale_factor;

                ty=getdap(myurl,[],'meridional_wind_stress',[],[],jrange,...
                    i1min,i1max,i2min,i2max,i3min,i3max);
                mval=x.meridional_wind_stress.ml__FillValue;
                scale_factor=x.meridional_wind_stress.scale_factor;
                add_offset=x.meridional_wind_stress.add_offset;
                ty(ty==mval)=NaN;
                ty=add_offset+ty.*scale_factor;

                if QSCAT_blk

                    xu=getdap(myurl,[],'zonal_wind_speed',[],[],jrange,...
                        i1min,i1max,i2min,i2max,i3min,i3max);
                    mval=x.zonal_wind_speed.ml__FillValue;
                    scale_factor=x.zonal_wind_speed.scale_factor;
                    add_offset=x.zonal_wind_speed.add_offset;
                    xu(xu==mval)=NaN;
                    xu=add_offset+xu.*scale_factor;

                    yv=getdap(myurl,[],'meridional_wind_speed',[],[],jrange,...
                        i1min,i1max,i2min,i2max,i3min,i3max);
                    mval=x.meridional_wind_speed.ml__FillValue;
                    scale_factor=x.meridional_wind_speed.scale_factor;
                    add_offset=x.meridional_wind_speed.add_offset;
                    yv(yv==mval)=NaN;
                    yv=add_offset+yv.*scale_factor;

                    ws=getdap(myurl,[],'wind_speed',[],[],jrange,...
                        i1min,i1max,i2min,i2max,i3min,i3max);
                    mval=x.wind_speed.ml__FillValue;
                    scale_factor=x.wind_speed.scale_factor;
                    add_offset=x.wind_speed.add_offset;
                    ws(ws==mval)=NaN;
                    ws=add_offset+ws.*scale_factor;

                end

                if isnan(max(tx(:))) |  isnan(max(ty(:)))

                    warning('download_QSCAT - all nan values')

                end

                if (max(tx(:))==0 & min(tx(:))==0) | (max(ty(:))==0 & min(ty(:))==0)

                    warning('download_QSCAT - all 0 values')

                end

                %
                % Write in the file
                %

                tndx=tndx+1;
                good_time(tndx)=time;
                taux(tndx,:,:)=tx;
                tauy(tndx,:,:)=ty;
                if QSCAT_blk
                    uwnd(tndx,:,:)=xu;
                    vwnd(tndx,:,:)=yv;
                    wnds(tndx,:,:)=ws;
                end

            else % ~isempty(x)

                warning('download_QSCAT - file not found - try next')

            end % ~isempty(x)


        end %% --> day


        %
        disp('Checking filling of the maps...')
        disp(['...INFO.....'])
        disp(['........'])

        tot=length(lat)*length(lon);

        nbmask=max(sum(sum(squeeze(floor(mean(isnan(taux(1:tndx,:,:)),1))))),1);

        to_keep=[];
        for k=1:tndx
            tab=squeeze(taux(k,:,:));
            per=(sum(sum(isnan(tab)))-nbmask)/tot*100.;
            if per >= 5.
                disp([''])
                disp(['***********************************************'])
                disp(['More than 5% bad values -> map ',num2str(k), ' removed'])
                disp(['For your info -> per=  ',num2str(per),'%'])
                disp(['***********************************************'])
                disp([''])
            else
                to_keep=[to_keep,k];
            end
        end
        %
        good_time=good_time(to_keep);
        taux=taux(to_keep,:,:);
        tauy=tauy(to_keep,:,:);

        if QSCAT_blk
            uwnd=uwnd(to_keep,:,:);
            vwnd=vwnd(to_keep,:,:);
            wnds=wnds(to_keep,:,:);
        end

        %
        % Check for erroneous data values abs>10*max(median)
        disp('Checking erroneous data values...')
        nt=length(to_keep);

        %
        med=median(taux,1);
        %    x_ind=find( abs(taux-med(ones(nt,1),:,:)) >= 5*max(max(abs(med))) );
        x_ind=find( abs(taux-repmat(med,[nt,1,1])) >= 5*max(max(abs(med))) );
        taux(x_ind)=NaN;
        %
        med=median(tauy,1);
        %    y_ind=find( abs(tauy-med(ones(nt,1),:,:)) >= 5*max(max(abs(med))) );
        y_ind=find( abs(tauy-repmat(med,[nt,1,1])) >= 5*max(max(abs(med))) );
        tauy(y_ind)=NaN;
        %
        if QSCAT_blk
            %
            med=median(uwnd,1);
            %      x_ind=find( abs(taux-med(ones(nt,1),:,:)) >= 5*max(max(abs(med))) );
            x_ind=find( abs(uwnd-repmat(med,[nt,1,1])) >= 5*max(max(abs(med))) );
            uwnd(x_ind)=NaN;
            %
            med=median(vwnd,1);
            %      y_ind=find( abs(tauy-med(ones(nt,1),:,:)) >= 5*max(max(abs(med))) );
            y_ind=find( abs(vwnd-repmat(med,[nt,1,1])) >= 5*max(max(abs(med))) );
            vwnd(y_ind)=NaN;

            med=median(wnds,1);
            %      y_ind=find( abs(tauy-med(ones(nt,1),:,:)) >= 5*max(max(abs(med))) );
            y_ind=find( abs(wnds-repmat(med,[nt,1,1])) >= 5*max(max(abs(med))) );
            wnds(y_ind)=NaN;
        end


        write_NCEP([QSCAT_dir,'taux','Y',num2str(Y),'M',num2str(M),'.nc'],...
            'taux',lon,lat,good_time,taux,Yorig)
        write_NCEP([QSCAT_dir,'tauy','Y',num2str(Y),'M',num2str(M),'.nc'],...
            'tauy',lon,lat,good_time,tauy,Yorig)

        if QSCAT_blk
            write_NCEP([QSCAT_dir,'uwnd','Y',num2str(Y),'M',num2str(M),'.nc'],...
                'uwnd',lon,lat,good_time,uwnd,Yorig)
            write_NCEP([QSCAT_dir,'vwnd','Y',num2str(Y),'M',num2str(M),'.nc'],...
                'vwnd',lon,lat,good_time,vwnd,Yorig)
            write_NCEP([QSCAT_dir,'wnds','Y',num2str(Y),'M',num2str(M),'.nc'],...
                'wnds',lon,lat,good_time,wnds,Yorig)
        end


    end %%--> M
end   %%--> Y

return
 

