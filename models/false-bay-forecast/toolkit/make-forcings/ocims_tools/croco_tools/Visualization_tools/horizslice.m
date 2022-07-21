function horizslice(hisfile,vname,tindex,vlevel,rempts,coef,gridlevs,...
                    colmin,colmax,lonmin,lonmax,latmin,latmax,...
		    ncol,pltstyle,isobath,cstep,cscale,cunit,...
		    coastfile,townfile,gridfile,h0,handles,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Plot an horizontal slice into a CROCO variable.
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

refine_coeff=3;
fontsize=10;
width=1;
height=0.8;
%
% Defaults values
%
if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  disp('Default variable to plot: temp')
  vname='temp';
end
if nargin < 3
  disp('Default time index: 1')
  tindex=1;
end
if nargin < 4
  disp('Default level: -10 m')
  vlevel= -10;
end
if nargin < 5
  rempts=[0 0 0 0];
end
if nargin < 6
  coef=1;
end
if nargin < 7
  gridlevs=0;
end
if nargin < 8
  colmin=[];
end
if nargin < 9
  colmax=[];
end
if nargin < 10
  lonmin=[];
end
if nargin < 11 
  lonmax=[];
end
if nargin < 12
  latmin=[];
end
if nargin < 13 
  latmax=[];
end
if nargin < 14 
  ncol=10;
end
if nargin < 15 
  pltstyle=1;
end
if nargin < 16
  isobath='100 100';
end
if nargin < 17
  cstep=0;
end
if nargin < 18
  cscale=1;
end
if nargin < 19
  cunit=0.1;
end
if nargin < 20
  coastfile=[];
end
if nargin < 21
  townfile=[];
end
if nargin < 22
  gridfile=hisfile;
end
if nargin < 23
  h0=[];
end
if nargin < 24
  handles=[];
end
if nargin < 25
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
% Read parent data
%
[lat,lon,mask,var]=get_var(hisfile,gridfile,vname,tindex,...
                           vlevel,coef,rempts);
%
% Get the domain
%
if isempty(lonmin)
  lonmin=min(min(lon));
end
if isempty(lonmax)
  lonmax=max(max(lon));
end
if isempty(latmin)
  latmin=min(min(lat));
end
if isempty(latmax)
  latmax=max(max(lat));
end
%
% Get the date
%
[day,month,year,imonth,thedate]=...
get_date(hisfile,tindex,Yorig);
%
%  Color values
%
maxvar=max(max(var));
minvar=min(min(var));
if isnan(maxvar)|isnan(minvar)
 maxvar=0;
 minvar=0;
end
if isempty(colmin) | colmin>=colmax 
  colmin=minvar;
  if ~isempty(h0)
    handles.colmin=colmin;
    set(handles.editcolmin,'String',num2str(handles.colmin,3));
  end
end
if isempty(colmax) | colmin>=colmax
  colmax=maxvar;
  if ~isempty(h0)
    handles.colmax=colmax;
    set(handles.editcolmax,'String',num2str(handles.colmax,3));
  end
end
if ~isempty(h0)
  guidata(h0,handles)  
end
%
% Colorbar (external plot case)
%
if isempty(h0)
  if (pltstyle==1 | pltstyle==2) & maxvar>minvar
    if cstep~=0
      fixcolorbar([0.25 0.05 0.35 0.03],[colmin colmax],vname,fontsize)
    else
      fixcolorbar([0.25 0.05 0.5 0.03],[colmin colmax],vname,fontsize)
    end
  end
  if pltstyle==5
%
% Seawifs type colorbar
%
    if cstep~=0
      seawifscolorbar([0.25 0.05 0.35 0.03],vname,fontsize)
    else
      seawifscolorbar([0.25 0.05 0.5 0.03],vname,fontsize)
    end
  end
end
%
% Define the domain
%
if isempty(h0)
  subplot('position',[0. 0.14 width height])
end
m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
%
% Do the plot
%
do_plot(lon,lat,var,maxvar,minvar,...
        pltstyle,colmin,colmax,ncol,...
	isobath,hisfile,gridfile,tindex,...
        vlevel,cstep,rempts,cscale)
%
% Add the embedded levels
%
for grid_lev=1:gridlevs
  hold on
  chisfile=[hisfile,'.',num2str(grid_lev)];
  cgridfile=[gridfile,'.',num2str(grid_lev)];
%
% Read child data
%
  [lat,lon,mask,var]=get_var(chisfile,cgridfile,vname,tindex,...
                             vlevel,coef,[0 0 0 0]);
%
% Do the plot
%
  cstep=cstep*refine_coeff;
  do_plot(lon,lat,var,maxvar,minvar,...
          pltstyle,colmin,colmax,ncol,...
	  isobath,chisfile,cgridfile,tindex,...
          vlevel,cstep,rempts,cscale)
%
% Add a parent-child boundary 
%	  
  h=bounddomain(lon,lat);
  set(h,'color','black')
  hold off
end
%
% Add the coast
%
if ~isempty(coastfile)
  hold on
  m_usercoast(coastfile,'patch',[.9 .9 .9]);
  hold off
end
%
% Add town names
%
if ~isempty(townfile)
  add_towns(townfile,10,...
            lonmin,lonmax,...
            latmin,latmax)
end
%
% Put a nice grid
%
%m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out');
m_grid('box','fancy','tickdir','in');
set(findobj('tag','m_grid_color'),'facecolor','white')
%
% Title
%
if isempty(h0)
  title([vname,' - ',thedate])
else
  set(handles.edittitle,'String',[vname,' - ',thedate]);
  set(handles.editdate,'String',thedate);
  guidata(h0,handles)
end
%
% add a vector showing the value of the current 
%
if isempty(h0) & cstep~=0;
  add_arrow(lonmin,lonmax,latmin,latmax,cunit,cscale,width,height)
end
%
% Colorbar
%
if ~isempty(h0)
  if pltstyle<3 & maxvar>minvar
    set(handles.figure1,'HandleVisibility','on','CurrentAxes',handles.axes2);
    dc=(colmax-colmin)/ncol;
    x=[0:1];
    y=[colmin:dc:colmax];
    [X,Y]=meshgrid(x,y);
    if pltstyle==1
      pcolor(X,Y,Y)
    elseif pltstyle==2
      contourf(X,Y,Y,[colmin:dc:colmax])
    end
    shading flat
    caxis([colmin colmax])
    set(gca,'YAxisLocation','right','Xtick',[])
  elseif pltstyle==5
    set(handles.figure1,'HandleVisibility','on','CurrentAxes',handles.axes2);
    x=[0:1];
    y=[0:70];
    [X,Y]=meshgrid(x,y);
    pcolor(X,Y,Y)
    L = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50];
    l=(log10(L)+2)*70/(log10(70)+2);
    set(gca,'YTick',l,'YTickLabel',L)
    set(gca,'YAxisLocation','right','Xtick',[])
    shading flat
    caxis([0.01 70])


  else
    set(handles.figure1,'HandleVisibility','on','CurrentAxes',handles.axes2);
    cla
    set(gca,'Visible','off')
  end
end
