%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Create a CROCO run-off forcing file
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
%  July 2013: G.Cambon (IRD/LEGOS) & M. Herrmann (IRD/LEGOS)
%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
if (makenpzd | makepisces | makebioebus)
    makebio = 1;
else
    makebio = 0;
end
%
disp(' ')
disp(['Create runoff forcing from Dai and Trenberth''s global monthly climatological run-off dataset'])
disp(' ')
title_name='runoff forcing file (Dai and Trenberth, 2002 dataset)';
%
plotting=1;
%
define_dir=0 ;  %->flag to define directly the orientation / direction of the runoff
%
if define_dir==1
    % Define orientation/direction of the flow. First column is the u- (0) or v- (1)
    % orientation. Second column is the direction of the flow in the choosen orientation
    dir(1,:)=[0, -1];
    dir(2,:)=[0, -1];
    dir(3,:)=[1, -1];
end
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
[latriv,lonriv,my_flow,myrivername,rivernumber]=runoff_glob_extract(grdname,global_clim_rivername);

if rivernumber == 0  %at least a river
disp(['Create a "fictive" runoff forcing file :  river with no discharge'])
create_runoff(rivname,grdname,title_name,...
              qbar_time,qbar_cycle, ...
              'fictiveriver_@nest',1,18,1,psource_ts,makebio)      
my_flow=0;
nw=netcdf(rivname,'w');
disp(['Write in runoff file'])
nw{'Qbar'}(:) = my_flow;
if psource_ts==1
    nw{'temp_src'}(:) = my_temp_src;
    nw{'salt_src'}(:) = my_salt_src;
    if makebio
      nw{'NO3_src'}(:) = my_no3_src;
    end
end  
close(nw)

disp([' '])
disp(['Line to enter in the croco.in file in the psource_ncfile section :'])
disp(['-----------------------------------------------------------------'])
disp(['psource_ncfile:   Nsrc  Isrc  Jsrc  Dsrc qbardir  Lsrc  Tsrc   runoff file name'])
disp(['                           CROCO_FILES/croco_runoff.nc(.#nestlevel)'])
disp(['                 ',num2str(0)'])          

%    
else
latriv=latriv';
lonriv=lonriv';
%
rivername=strvcat(myrivername);
rivernumber=size(rivername,1);
rivname_StrLen=size(rivername,2);
%
% Determine the positions of the river, from its lon/lat position
% extract j and i to put in croco.in / croco.in.1 for that use of croco_grd.nc
%
% Read the grid
%
[lat,lon,mask]=read_latlonmask(grdname,'r');
[latu,lonu,masku]=read_latlonmask(grdname,'u');
[latv,lonv,maskv]=read_latlonmask(grdname,'v');
lonmin=min(lon(:));
lonmax=max(lon(:));
latmin=min(lat(:));
latmax=max(lat(:));
%
% Perform a first pass on each river
%
disp(' ')
disp(['First guess:'])
disp(['============'])
%
for k= 1:rivernumber
  disp([' '])
  disp(['- Process river #',num2str(k),': ',char(myrivername(k,:))])
  indomain(k)=check_domain_runoff(lon,lat,lonriv(k),latriv(k));
  [j,i]=runoff_grid_pos(lon,lat,lonriv(k),latriv(k));
  J(k)=j-1;
  I(k)=i-1;
  I(I<1)=1;
  J(J<1)=1;
  
  disp(['  Position is approximetly  J=',num2str(J(k)),' and I=',num2str(I(k))])
  disp(['lon src in grid (rho point) ~',num2str(lon(J(k),I(k)))])
  disp(['lat src in grid (rho point) ~',num2str(lat(J(k),I(k)))])
end
%
% Check the river you really have to process.
% Remove rivers out of the domain, if any...
%
rivertoprocess=find(indomain==1);
number_rivertoprocess=length(rivertoprocess);
%
rivername=strvcat(myrivername(rivertoprocess,:));
rivernumber=number_rivertoprocess;
rivname_StrLen=size(rivername,2);
%
% Make a figure
%
if plotting==1
  figure
  m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
  m_pcolor(lon,lat,mask)
  m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out');
  set(findobj('tag','m_grid_color'),'facecolor','white');
  hold on
  for k0=1:number_rivertoprocess
    k=rivertoprocess(k0);
    lon_src=lon(J(k)+1,I(k)+1);
    lat_src=lat(J(k)+1,I(k)+1);
    [px,py]=m_ll2xy(lon_src,lat_src);
    h1=plot(px,py,'ro');
    set(h1,'Clipping','off')
    legend(h1,'first guess position');
    h2=m_text(lon(J(k),I(k)),lat(J(k),I(k))+0.1,myrivername(k,:));
    set(h2,'fontweight','demi','fontsize',13);
  end
end
%
% Choose which river you really want to process...
%
indomain_last=indomain;
for k = 1 : number_rivertoprocess
  indomain_last(k)=input(['Do you want to use river (Yes[1], No[0]) ?  ', rivername(k,:)]);
end
rivertoprocess=find(indomain_last==1);
if isempty(rivertoprocess)
    error(['No river selected !'])
end
number_rivertoprocess=length(rivertoprocess);
rivername=strvcat(myrivername(rivertoprocess,:));
rivname_StrLen=size(rivername,2);
my_flow=my_flow(:,find(indomain_last==1));%
% Define the orientation/direction of the flow. First column is the u- (0) or v- (1) 
% orientation. Second column is the direction of the flow in the choosen orientation
%    
if define_dir==0
    for k0=1:length(rivertoprocess)
        k=rivertoprocess(k0);
        disp(['====='])
        disp(['River ',rivername(k0,:)])
        disp(['Choose the orientation of the flow'])
        dir11=NaN;
        while ~(dir11==0 | dir11==1)
            dir11 = input('0=zonal or 1=meridional. ');
        end
        disp(['Choose the direction of the flow. '])
        
        dir12=NaN;
        while ~(dir12==1 | dir12==-1)
            dir12= input('1 is positive [S-N or W-E], -1 negative [N-S or E-W]. ');
        end
        dir(k,:)=[dir11 dir12];
    end
end
%
% Create the runoff forcing file
%
disp(' ')
disp(' Create the runoff file...')
create_runoff(rivname,grdname,title_name,...
    qbar_time,qbar_cycle, ...
    rivername,number_rivertoprocess,rivname_StrLen,dir,psource_ts,makebio)
%
% Adjust the rivers positions relative to the mask
%
disp(['Find the real positions of the rivers in the grid: '])
disp(['==================================================='])
for k=1:number_rivertoprocess
  disp(['Process final position for river ',rivername(k,:)])
  disp(['Choose the orientation'])  
  jj=J(k); 
  ii=I(k);
  dir2=dir(k,:);
  [jj2,ii2]=locate_runoff(dir2,jj,ii,mask,masku,maskv);
  J2(k)=jj2; 
  I2(k)=ii2;
  disp([char(rivername(k,:)),' is J=',num2str(J2(k)),' and I=',num2str(I2(k))])
  disp([' '])
end
%
% Adjust the rivers temperature and salinity
%
if psource_ts==1
  disp([' '])
  disp([' Adjust the rivers temperature and salinity '])
  disp([' Use the closest surface point in the climatology file '])
  my_temp_src=zeros(number_rivertoprocess,length(woa_time));
  my_salt_src=zeros(number_rivertoprocess,length(woa_time));
  if makebio==1
    my_no3_src=zeros(number_rivertoprocess,length(woa_time));
  end
%
  ncclim=netcdf(clmname);
  N=length(ncclim('s_rho'));
%
  for k=1:number_rivertoprocess
%
% For temperature, use the closest surface point in the clim file
% to reduce any heat flux induced by the rivers
%
    T=squeeze(ncclim{'temp'}(:,N,J(k)+1,I(k)+1));
    my_temp_src(k,:)=T';
%
% For salinity ... ? 
%
%    S=squeeze(ncclim{'salt'}(:,N,J(k)+1,I(k)+1))-10; % hum... 
%    S(S<2)=2; % to prevent negative salinities in the equation of state
    S=2;
    my_salt_src(k,:)=S';
    if makebio==1
      NO3=squeeze(ncclim{'NO3'}(:,N,J(k)+1,I(k)+1));
      my_no3_src(k,:)=NO3';
    end
  end
  close(ncclim)
  
%   %Alternativaly : Define all mannually the tracer 
%   %t, s, and eventually biogeochemical tracer concentration
%   temp_src0=[11 9 9 12 20 20 24 25 21 18 13 12];
%   my_temp_src(:,:)=[temp_src0;temp_src0+2;temp_src0+2.8]; % Example for 3 sources
%   %
%   salt_src0=[2 3 5 1 5 3 2 1 4 2 1 2];
%   my_salt_src(:,:)=[salt_src0;salt_src0;salt_src0];       % Example for 3 sources
%   %
%   no3_src0=[0 0 0 0 0 0 0 0 0 0 0 0];
%   my_no3_src(:,:)=[no3_src0;no3_src0+2;no3_src0+2.8];     % Example for 3 sources
%   %
end

%
% Continue the figure
%
if plotting
  hold on
  for k=1:number_rivertoprocess
    lon_src=lon(J2(k)+1,I2(k)+1);
    lat_src=lat(J2(k)+1,I2(k)+1);
    [px,py]=m_ll2xy(lon_src,lat_src);
    h3=plot(px,py,'ko');
    set(h3,'Clipping','off')
  end
  legend([h1,h3],{'Approximative first guess river location','final adjusted river location'});
  title({'\bf Location of river in the croco grid';'(from Dai and Trenberth dataset)'});
end
%
% Fill the river discharge and eventually
% t/s concentration, no3 concentration
%
nw=netcdf(rivname,'w');
disp(['Write in runoff file'])
nw{'river_position'}(:,:)=[I2 J2];
nw{'river_direction'}(:,:)=dir;
disp(['... river positions'])
% Write qbar, temp,salt and bgc variables conc.
cff=1;
%
%cff=150;
%disp(['================== WARNING ============================'])
%disp(['Use a cff coef to increase the discharge= ',num2str(cff)])
%disp(['======================================================='])
%
my_flow=cff.*my_flow;
nw{'Qbar'}(:) = my_flow;
disp(['... discharges'])
if psource_ts==1
    nw{'temp_src'}(:) = my_temp_src;
    disp(['... temperature concentration'])
    nw{'salt_src'}(:) = my_salt_src;
    disp(['... salt concentration'])
    if makebio
      nw{'NO3_src'}(:) = my_no3_src;
      disp(['... NO3 concentration'])
    end
    
    disp([' ...'])
    disp([' ...Note : '])
    disp([' ... The Tsrc value reported in croco.in are the annual-mean tracer value'])
    disp([' ... It''s just for information !'])
    disp([' ... The Tsrc used are read in the runoff netCDF file created'])

end
close(nw)
%
% Line to enter in the croco.in file in the psource section
%
disp([' '])
disp(['Line to enter in the croco.in file in the psource_ncfile section :'])
disp(['-----------------------------------------------------------------'])
disp(['psource_ncfile:   Nsrc  Isrc  Jsrc  Dsrc qbardir  Lsrc  Tsrc   runoff file name'])
disp(['                           CROCO_FILES/croco_runoff.nc(.#nestlevel)'])
disp(['                 ',num2str(number_rivertoprocess)'])
for k=1:number_rivertoprocess
  if psource_ts==1
    T=mean(my_temp_src(k,:));
    S=mean(my_salt_src(k,:));
    
  else
    T=5;
    S=1;
  end
  if dir(k,1) == 1     %flow meridien
    disp(['                        ',num2str(I2(k)-1),'  ',num2str(J2(k)),...
	  '  ',num2str(dir(k,1)),'  ',num2str(dir(k,2)),'   30*T   ',...
	  num2str(T),' ',num2str(S)])
  elseif dir(k,1) == 0 %flow zonal
    disp(['                        ',num2str(I2(k)),'  ',num2str(J2(k)-1),...
	  '  ',num2str(dir(k,1)),'  ',num2str(dir(k,2)),'   30*T   ',...
	  num2str(T),' ',num2str(S)])
  end
end
disp(['-----------------------------------------------------------------'])
   
%
% Plot the seasonal cycle
%
figure
if psource_ts==1
  subplot(3,1,1)
end
hold on
plot([1:12],my_flow)
legend(rivername)
box on, grid on
title(['\bf Monthly clim of the domain run off']) 
xlabel(['\bf Month']);ylabel(['\bf Discharge in m3/s'])
set(gca,'Xtick',[0.5:11.5],'XtickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D']);
if psource_ts==1
  subplot(3,1,2)
  plot([1:12],my_temp_src)
  box on, grid on
  xlabel(['\bf Month']);ylabel(['\bf Temp [C]'])
  set(gca,'Xtick',[0.5:11.5],'XtickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D']);
%
  subplot(3,1,3)
  plot([1:12],my_salt_src)
  box on, grid on
  xlabel(['\bf Month']);ylabel(['\bf Salt [C]'])
  set(gca,'Xtick',[0.5:11.5],'XtickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D']);
end
end  %end at least one river !

