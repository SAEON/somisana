%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add radswbio (solar short-wave radiation without diurnal cycle) 
%  in bulk CFSR atmopheric forcing files. 
%  Variable needed by biogeochemical model PISCES
%
%
%  Further Information:
%  http://www.crocoagrif.org
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
%
%  June 2014: G.Cambon (IRD/LEGOS)
%
clear all
close all

crocotools_param;
%=============================================
if NCEP_version==3
    %frc_prefix=[frc_prefix,'_CFSR_'];
    blk_prefix=[blk_prefix,'_CFSR_'];
else
    error('MAKE_CFSR: wrong NCEP version')
end
%
if level==0
    nc_suffix='.nc';
else
    nc_suffix=['.nc.',num2str(level)];
end
%=============================================

for Y=Ymin:Ymax
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
        disp(' ')
        tic
        disp(['==================================================='])
        disp(['Processing  year ',num2str(Y),' month ',num2str(M)])
        blkname=[blk_prefix,'Y',num2str(Y),'M',num2str(M),nc_suffix];
        %
        %Add the radswbio variables in netcdf files 
        %
        nc_add_swradbio_blk(blkname)
        
        %   Begin computing 
        %       Reading radsw field
        nc=netcdf(blkname,'w');
        radsw=nc{'radsw'}(:);
        %clear
        radsw3=radsw;
        [T,M,L]=size(radsw);
        radsw3=zeros(T,M,L);
        
        %         Loop over i and j 
        disp(['Processing time avering for radsw'])
        for j=1:M
            for i=1:L
                radsw2=radsw(:,j,i);
                %   Averaging on 0h, 6h, 12h, 18h "block"
                radsw2_filt=zeros(1,length([1:4:length(radsw2)]));
                k2=0;
                for k=1:4:length(radsw2)
                    k ;
                    k2=k2+1;
                    radsw2_filt(k2)=mean(radsw2(k:k+3));
                end
                %   Re-Interpolation in time 
                %       Every 6 hours => freq=0.25
                freq=0.25;
                x=1:length(radsw2_filt) ; 
                xi=1:freq:length(radsw2_filt)+(1./freq - 1).*freq;
                radsw2_filt_6h=interp1(x,radsw2_filt,xi,'linear','extrap');
                % a bit crudy, but i am lazy and it is in the overlap !
                % optional ...
                %radsw2_filt_6h(end-2:end)=radsw2_filt_6h(end-3); %-> ok if freq =0.25 !   
                radsw3(:,j,i)=squeeze(radsw2_filt_6h);
            end
        end
        %   Fill the field radswbio
        nc{'radswbio'}(:)=radsw3;
        close(nc)
        % 
    end
end

gocheck =0
if gocheck
%Check
%======
ncload('CROCO_FILES/croco_blk_CFSR_Y2000M1.nc');
radswjan=radsw;
radswbiojan=radswbio;
scrum_time_jan=bulk_time;

ncload('CROCO_FILES/croco_blk_CFSR_Y2000M2.nc');
radswfev=radsw;
radswbiofev=radswbio;
scrum_time_fev=bulk_time;


ncload('CROCO_FILES/croco_blk_CFSR_Y2000M3.nc');
radswmar=radsw;
radswbiomar=radswbio;
scrum_time_mar=bulk_time;


I=20; J=20; 

figure
subplot(211)
plot(scrum_time_jan,squeeze(radswjan(:,J,I))); hold on ;
plot(scrum_time_jan,squeeze(radswjan(:,J,I)),'ob'); hold on ;

plot(scrum_time_fev,squeeze(radswfev(:,J,I)),'m');
plot(scrum_time_fev,squeeze(radswfev(:,J,I)),'+m');

plot(scrum_time_mar,squeeze(radswmar(:,J,I)),'k');
plot(scrum_time_mar,squeeze(radswmar(:,J,I)),'+k');

subplot(212)
plot(scrum_time_jan,squeeze(radswbiojan(:,J,I))); hold on ;
plot(scrum_time_jan,squeeze(radswbiojan(:,J,I)),'ob'); hold on ;

plot(scrum_time_fev,squeeze(radswbiofev(:,J,I)),'m');
plot(scrum_time_fev,squeeze(radswbiofev(:,J,I)),'+m');

plot(scrum_time_mar,squeeze(radswbiomar(:,J,I)),'k');
plot(scrum_time_mar,squeeze(radswbiomar(:,J,I)),'+k');

end 