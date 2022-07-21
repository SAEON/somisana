%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO grid file
%
% script created by Giles Fearon, adapted from existing CROCOTOOLS scripts
%  This file is derived from make_grid.m part of croco_tools, but has been
%  edited to read a grid generated using Delft3D's RGFGRID software
%
%  Also edited is that the call to add_topo has been changed to 
%  add_topo_scatter, where bathy is gridded from scatter data
%  e.g. electronic charts and/or bathy surveys. The mask must be created
%  manually in this case, but is saved as mask_rho.mat so no need to keep
%  repeating the manual mask generation
%  
%
%  Further Information:  
%  http://www.brest.ird.fr/Roms_tools/
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Contributions of P. Marchesiello (IRD) and X. Capet (UCLA)
%
%  Updated    Aug-2006 by Pierrick Penven
%  Updated    24-Oct-2006 by Pierrick Penven (mask correction)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
warning off
isoctave=exist('octave_config_info');
%
% Title
%
if level>0
    grdname=[grdname,'.',num2str(level)];
end
disp(' ')
disp([' Making the grid: ',grdname])
disp(' ')
disp([' Title: ',CROCO_title])
%

% read the delft3d grid file
% (note I'm reading the delft3d native grid format, not the netcdf exported
% from delft3d as we are only need to use the lon and lat variables)
% we use the uncut delft3d grid for generating the croco grid
grd_d3d_uncut = wlgrid('read', grdfile_d3d_uncut);
Lonr=grd_d3d_uncut.X;
Latr=grd_d3d_uncut.Y;
% invert so first dimension is latitude, then longitude, as per croco
% convention
Lonr=Lonr'; 
Latr=Latr';

if nanmean(Lonr(:,1))>nanmean(Lonr(:,end))
    disp('you need to run flip_grd.m function on your delft3d grid to ensure')
    disp('the grid indices or ordered properly (as expected by this funciton')
    return
end
if nanmean(Latr(1,:))>nanmean(Latr(end,:))
    disp('you need to run flip_grd.m function on your delft3d grid to ensure')
    disp('the grid indices or ordered properly (as expected by this funciton')
    return
end

[Lonu,Lonv,Lonp]=rho2uvp(Lonr); 
[Latu,Latv,Latp]=rho2uvp(Latr);
[Mp,L]=size(Latu);
[M,Lp]=size(Latv);
Lm=L-1;
Mm=M-1;
%
% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[M,L]=size(Latp);
disp([' LLm = ',num2str(L-1)])
disp([' MMm = ',num2str(M-1)])
create_grid(L,M,grdname,CROCO_title)
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
nc=netcdf(grdname,'write');
nc{'lat_u'}(:)=Latu;
nc{'lon_u'}(:)=Lonu;
nc{'lat_v'}(:)=Latv;
nc{'lon_v'}(:)=Lonv;
nc{'lat_rho'}(:)=Latr;
nc{'lon_rho'}(:)=Lonr;
nc{'lat_psi'}(:)=Latp;
nc{'lon_psi'}(:)=Lonp;
close(nc)
%
%  Compute the metrics
%
disp(' ')
disp(' Compute the metrics...')
[pm,pn,dndx,dmde]=get_metrics(grdname);
xr=0.*pm;
yr=xr;
for i=1:L
  xr(:,i+1)=xr(:,i)+2./(pm(:,i+1)+pm(:,i));
end
for j=1:M
  yr(j+1,:)=yr(j,:)+2./(pn(j+1,:)+pn(j,:));
end
[xu,xv,xp]=rho2uvp(xr);
[yu,yv,yp]=rho2uvp(yr);
dx=1./pm;
dy=1./pn;
dxmax=max(max(dx/1000));
dxmin=min(min(dx/1000));
dymax=max(max(dy/1000));
dymin=min(min(dy/1000));
disp(' ')
disp([' Min dx=',num2str(dxmin),' km - Max dx=',num2str(dxmax),' km'])
disp([' Min dy=',num2str(dymin),' km - Max dy=',num2str(dymax),' km'])
%
%  Angle between XI-axis and the direction
%  to the EAST at RHO-points [radians].
%
angle=get_angle(Latu,Lonu);
%
%  Coriolis parameter
%
f=4*pi*sin(pi*Latr/180)*366.25/(24*3600*365.25);
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
nc=netcdf(grdname,'write');
nc{'pm'}(:)=pm;
nc{'pn'}(:)=pn;
nc{'dndx'}(:)=dndx;
nc{'dmde'}(:)=dmde;
nc{'x_u'}(:)=xu;
nc{'y_u'}(:)=yu;
nc{'x_v'}(:)=xv;
nc{'y_v'}(:)=yv;
nc{'x_rho'}(:)=xr;
nc{'y_rho'}(:)=yr;
nc{'x_psi'}(:)=xp;
nc{'y_psi'}(:)=yp;
nc{'angle'}(:)=angle;
nc{'f'}(:)=f;
nc{'spherical'}(:)='T';
close(nc);
%

% get the cut grid used to define bathy and also the land mask
grd_d3d = wlgrid('read', grdfile_d3d);
Lonr_cut=grd_d3d.X;
Latr_cut=grd_d3d.Y;
Lonr_cut=Lonr_cut';
Latr_cut=Latr_cut';
[Mp_cut,Lp_cut]=size(Latr_cut);
%
% The cut grid may have entire rows and columns on the ends missing, so check
% where the cut grid fits into the uncut grid. We assume that at least one
% of the corners of the cut grid will cooincide with a corner of the uncut
% grid. That way it is easy to place the cut grid inside the uncut grid.
% Bit of a clunky way of doing it but after trying a few other options 
% couldn't find a catch-all easy alternative
% 
if Lonr(1,1) == Lonr_cut(1,1) % check the southwest corner
    j_start=1;
    j_end=Mp_cut;
    i_start=1;
    i_end=Lp_cut;
elseif Lonr(1,end) == Lonr_cut(1,end) % check the southeast corner
    j_start=1;
    j_end=Mp_cut;
    i_start=Lp-Lp_cut+1;
    i_end=Lp;
elseif Lonr(end,end) == Lonr_cut(end,end) % check the northeast corner
    j_start=Mp-Mp_cut+1;
    j_end=Mp;
    i_start=Lp-Lp_cut+1;
    i_end=Lp;
elseif Lonr(end,1) == Lonr_cut(end,1) % check the northwest corner
    j_start=Mp-Mp_cut+1;
    j_end=Mp;
    i_start=1;
    i_end=Lp_cut;
else    
    disp('oh dear, this method needs to be changed')
    return
end
%
%  Add topography
%
disp(' ')
disp(' Add topography...')
%
if use_d3d_bathy==1
    %
    % we use the cut grid for this as delft3d flow bathy is usually defined
    % on a cut grid
    %
    %x=grd_d3d.X;
    %y=grd_d3d.Y;

    dep = wldep('read',depfile_d3d,grd_d3d);
    dep=dep(1:end-1,1:end-1);
    dep=dep';
    dep(dep==-999)=hmin;
    %
    %x = x(~isnan(x));
    %y = y(~isnan(y));
    %dep = dep(~isnan(dep));
    %
    % using nearest interpolation will ensure that the exact depth values
    % from the cut grid will be used on the cut grid
    %h=griddata(x,y,dep,Lonr,Latr,'nearest');
    
    % assign depths directly from the delft3d cut grid
    h=zeros(size(Lonr))+hmin;
    h(j_start:j_end,i_start:i_end)=dep;
    
else
    h=add_topo_scatter(grdname,topofile,hmin,hmax);
end
%
% Compute the mask 
%
% compute the mask from delft3d grid cut grid missing values 
maskr_cut=zeros(size(Lonr_cut))+1;
maskr_cut(isnan(Lonr_cut))=0;
%
maskr=zeros(size(Lonr))+1;
maskr(j_start:j_end,i_start:i_end)=maskr_cut;

% Code below commented as we're using the delft3d cut grid as a starting
% point
% if exist('mask_rho.mat', 'file')
%     maskr_str=load('mask_rho.mat');
%     maskr=maskr_str.mask_rho;
% else 
%     maskr=h>0;
% end
maskr=process_mask(maskr);
[masku,maskv,maskp]=uvp_mask(maskr);
%
%  Write it down
%
nc=netcdf(grdname,'write');
nc{'h'}(:)=h;
nc{'mask_u'}(:)=masku;
nc{'mask_v'}(:)=maskv;
nc{'mask_psi'}(:)=maskp;
nc{'mask_rho'}(:)=maskr;
close(nc);

if (isoctave == 0)
%
% Create the coastline
%
if ~isempty(coastfileplot)
  make_coast(grdname,coastfileplot);
end
%
r=input('Do you want to use editmask ? y,[n]','s');
if strcmp(r,'y')
  disp(' Editmask:')
  disp(' Edit manually the land mask.')
  disp(' Press enter when finished.')
  disp(' ')
  if ~isempty(coastfileplot)
    editmask(grdname,coastfilemask)
  else
    editmask(grdname)
  end
  r=input(' Finished with edit mask ? [press enter when finished]','s');
end
%
close all
end % isoctave
%
%  Smooth the topography
%
nc=netcdf(grdname,'write');
h=nc{'h'}(:);
mask_rho=nc{'mask_rho'}(:);

if use_d3d_bathy~=1
    %
    h=smoothgrid(h,mask_rho,hmin,hmax_coast,hmax,...
        rtarget,n_filter_deep_topo,n_filter_final);
    %
    %  Write it down
    %
    disp(' ')
    disp(' Write it down...')
    nc{'h'}(:)=h;
end

close(nc);
%
% save the mask
%save mask_rho.mat mask_rho

% make a plot
%
% if (isoctave == 0)
% if makeplot==1
%   disp(' ')
%   disp(' Do a plot...')
%   themask=ones(size(maskr));
%   themask(maskr==0)=NaN; 
%   domaxis=[min(min(Lonr)) max(max(Lonr)) min(min(Latr)) max(max(Latr))];
%   colaxis=[min(min(h)) max(max(h))];
%   fixcolorbar([0.25 0.05 0.5 0.03],colaxis,...
%               'Topography',10)
%   width=1;
%   height=0.8;
%   subplot('position',[0. 0.14 width height])
%   m_proj('mercator',...
%          'lon',[domaxis(1) domaxis(2)],...
%          'lat',[domaxis(3) domaxis(4)]);
%   m_pcolor(Lonr,Latr,h.*themask);
%   shading flat
%   caxis(colaxis)
%   hold on
%   [C1,h1]=m_contour(Lonr,Latr,h,[hmin 100 200 500 1000 2000 4000],'k');
%   clabel(C1,h1,'LabelSpacing',1000,'Rotation',0,'Color','r')
%   if ~isempty(coastfileplot)
%     m_usercoast(coastfileplot,'color','r');
%     %m_usercoast(coastfileplot,'speckle','color','r');
%   else
%     m_gshhs_l('color','r');
%     m_gshhs_l('speckle','color','r');
%   end
%   m_grid('box','fancy',...
%          'xtick',5,'ytick',5,'tickdir','out',...
%          'fontsize',7);
%   hold off
% end
% warning on
% end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

