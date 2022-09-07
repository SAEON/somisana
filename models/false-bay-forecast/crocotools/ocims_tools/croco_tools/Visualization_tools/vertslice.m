function vertslice(hisfile,gridfile,lonsec,latsec,vname,tindex,...
                   coef,colmin,colmax,ncol,zmin,zmax,xmin,xmax,...
		   pltstyle,h0,handles,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get a vertical section
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated 23-Oct-2006 by Pierrick Penven (seawifs colormap)
%  Updated 02-Nov-2006 by Pierrick Penven (Yorig)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Defaults values
%
if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  gridfile=hisfile;
  disp(['Default grid name: ',gridfile])
end
if nargin < 3
  lonsec=[];
end
if nargin < 4
  latsec=[];
end
if nargin < 5
  vname='temp';
  disp(['Default variable to plot: ',vname])
end
if nargin < 6
  tindex=1;
  disp(['Default time index: ',num2str(tindex)])
end
if nargin < 7
  coef=1;
end
if nargin < 8
  colmin=[];
end
if nargin < 9
  colmax=[];
end
if nargin < 10
  ncol=10;
end
if nargin < 11
  zmin=[];
end
if nargin < 12
  zmax=[];
end
if nargin < 13
  xmin=[];
end
if nargin < 14
  xmax=[];
end
if nargin < 15
  pltstyle=1;
end
if nargin < 16
  h0=[];
  handles=[];
end
if nargin < 18
  Yorig=NaN;
end
%
% Define figure location
%
if ~isempty(h0)
  set(handles.figure1,'HandleVisibility','on','CurrentAxes',handles.axes1);
  cla
end
%
% Get default values
%
if isempty(gridfile)
  gridfile=hisfile;
end
if isempty(lonsec) | isempty(latsec)
  [lat,lon,mask]=read_latlonmask(gridfile,'r');
  latsec=mean(mean(lat));
  lonsec=[min(min(lon)) max(max(lon))];
end
%
% Get the section
%
if vname(1)=='*'
  if strcmp(vname,'*Ke')
    [x,z,u]=get_section(hisfile,gridfile,lonsec,latsec,...
                        'u',tindex);
    [x,z,v]=get_section(hisfile,gridfile,lonsec,latsec,...
                        'v',tindex);
    var=coef.*0.5.*(u.^2+v.^2);
  elseif strcmp(vname,'*Speed')
    [x,z,u]=get_section(hisfile,gridfile,lonsec,latsec,...
                        'u',tindex);
    [x,z,v]=get_section(hisfile,gridfile,lonsec,latsec,...
                        'v',tindex);
    var=coef.*sqrt(u.^2+v.^2);
  elseif strcmp(vname,'*Rho')
    [x,z,temp]=get_section(hisfile,gridfile,lonsec,latsec,...
                           'temp',tindex);
    [x,z,salt]=get_section(hisfile,gridfile,lonsec,latsec,...
                          'salt',tindex);
    var=coef*rho_eos(temp,salt,z);
  elseif strcmp(vname,'*Rho_pot')
    [x,z,temp]=get_section(hisfile,gridfile,lonsec,latsec,...
                           'temp',tindex);
    [x,z,salt]=get_section(hisfile,gridfile,lonsec,latsec,...
                          'salt',tindex);
    var=coef*rho_pot(temp,salt);
  elseif strcmp(vname,'*Chla')
    [x,z,sphyto]=get_section(hisfile,gridfile,lonsec,latsec,...
                           'SPHYTO',tindex);
    [x,z,lphyto]=get_section(hisfile,gridfile,lonsec,latsec,...
                          'LPHYTO',tindex);
    theta_m  =0.020;
    CN_Phyt  = 6.625;
    var=coef*theta_m*(sphyto+lphyto)*CN_Phyt*12.;
    var(var<=0)=NaN;
  else
    disp('Sorry not implemented yet')
    return
  end 
else
  [x,z,var]=get_section(hisfile,gridfile,lonsec,latsec,...
                        vname,tindex);
end
%
% Colors
%
maxvar=max(max(var));
minvar=min(min(var));
if isempty(colmin)
  colmin=minvar;
end
if isempty(colmax)
  colmax=maxvar;
end
%
% Domain size
%
if isempty(xmin)
  xmin=min(min(x));
end
if isempty(xmax)
  xmax=max(max(x));
end
if isempty(zmin)
  zmin=min(min(z));
end
if isempty(zmax)
  zmax=max(max(z));
end
%
% Get the date
%
[day,month,year,imonth,thedate]=...
get_date(hisfile,tindex,Yorig);
%
% Do the contours
%
if maxvar>minvar
  if pltstyle==1
    pcolor(x,z,var);
    ncol=128;
    shading interp
  elseif pltstyle==2
    contourf(x,z,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax]);
%    shading flat
  elseif pltstyle==3
    [C,h1]=contour(x,z,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax],'k');
     clabel(C,h1,'LabelSpacing',1000,'Rotation',0)
  elseif pltstyle==4
   dcol=(colmax-colmin)/ncol;
   if minvar <0 
     [C11,h11]=contourf(x,z,var,[minvar 0]);
      caxis([minvar 0]);
   end
   if colmin < 0
     if minvar < 0 
       hold on
     end
     val=[colmin:dcol:min([colmax -dcol])];
     if length(val)<2
       val=[colmin colmin];
     end  
     [C12,h12]=contour(x,z,var,val,'k');
     if ~isempty(h12)
       clabel(C12,h12,'LabelSpacing',1000,'Rotation',0)
       set(h12,'LineStyle',':')
     end
     hold off
   end
   if colmax > 0
     if colmin < 0 | minvar < 0
       hold on
     end
     val=[max([dcol colmin]):dcol:colmax];
     if length(val)<2
       val=[colmax colmax];
     end  
     [C13,h13]=contour(x,z,var,val,'k');
     if ~isempty(h13)
       clabel(C13,h13,'LabelSpacing',1000,'Rotation',0)
     end
     hold off 
   end
   hold on
   [C10,h10]=contour(x,z,var,[0 0],'k');
   if ~isempty(h10)
     clabel(C10,h10,'LabelSpacing',1000,'Rotation',0)
     set(h10,'LineWidth',1.2)
   end
   hold off
   map=0.9+zeros(64,3);
   map2=1+zeros(32,3);
   map(33:64,:)=map2;
   colormap(map)
  elseif pltstyle==5
%
% Seawifs type
%
    var(var<0.01)=0.01;
    pcolor(x,z,log10(var));
    ncol=128;
    shading interp
    caxis([log10(0.01) log10(70)])
    h10=colorbar('vert');
    set(h10,'ytick',log10([.01 .02 .03 .05 .1 .2 .3 .5 1 2 3 5 10 20 30 50]),...
       'yticklabel',[.01 .02 .03 .05 .1 .2 .3 .5 1 2 3 5 10 20 30 50]);
    map=zeros(64:3);
    r=0*(1:64);
    r(1:8)=0.5-(1:8)/16;
    r(33:40)=(1:8)/8;
    r(41:60)=1;
    r(57:64)=1-(1:8)/12;
    b=0*(1:64);
    b(1:24)=1;
    b(25:32)=1-(1:8)/8;
    b(1:8)=0.5+(1:8)/16;
    g=0*(1:64);
    g(9:24)=(1:16)/16;
    g(25:40)=1;
    g(41:56)=1-(1:16)/16;
    map(:,1)=r';
    map(:,2)=g';
    map(:,3)=b';
    colormap(map)
  end
  if pltstyle<=2
    caxis([colmin colmax])
    colormap(jet)
    colorbar
  end
  axis([xmin xmax zmin zmax])
end
xlabel('Position along the section [km]')
ylabel('Depth [m]')
title([vname,' - ',thedate])
return

