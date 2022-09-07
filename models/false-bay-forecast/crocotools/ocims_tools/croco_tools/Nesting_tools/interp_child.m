function handles=interp_child(h,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get everything in order to compute the child grid
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Get the parent grid name
%
if isempty(handles.parentgrid)
  handles=get_parentgrdname(h,handles);
end
%
% Get the sub domain
%
if isempty(handles.imin)
  handles=get_findgridpos(h,handles);
end
%
% Get the child grid name
%
lev=str2num(handles.parentgrid(end));
if isempty(lev) 
  childname=[handles.parentgrid,'.1'];
else
  childname=[handles.parentgrid(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child grid name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
case {'Cancel'}
  return
case 'Yes'
  handles.childgrid=childname;
end
%
% Get the topo Name
%
if handles.newtopo==1
  if isempty(handles.toponame)
    handles=get_topofile(h,handles);
  end
end
%
% Get the rfactor and the width of the connection band
%
handles=get_rfactor(h,handles);
handles=get_nband(h,handles);
%
% Perform the interpolations
%
[imin_new,imax_new,jmin_new,jmax_new]=nested_grid(handles.parentgrid,handles.childgrid,...
            handles.imin,handles.imax,handles.jmin,handles.jmax,...
            handles.rcoeff,handles.toponame,handles.newtopo,handles.rfactor,...
            handles.nband,handles.hmin,handles.matchvolume,...
	    handles.hmax_coast,handles.n_filter_deep,...
	    handles.n_filter_final);
%
% Update the imin,imax, jmin, jmax limits
%
handles.imin=imin_new;
handles.imax=imax_new;
handles.jmin=jmin_new;
handles.jmax=jmax_new;

handles=update_limits(h,handles);

%
%
%
% Plot the river
%	    
if (~isempty(handles.Isrcparent)) & ~(isempty(handles.Jsrcparent))
  disp('   Plot the river')
  nc=netcdf(handles.parentgrid,'r');
  lon_src=nc{'lon_rho'}(handles.Jsrcparent+1,handles.Isrcparent+1);
  lat_src=nc{'lat_rho'}(handles.Jsrcparent+1,handles.Isrcparent+1);
  close(nc);
  hold on
  h1=plot(lon_src,lat_src,'s',...
                'LineWidth',1.5,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','b',...
                'MarkerSize',10);
  nc=netcdf(handles.childgrid,'r');
  lon_src=nc{'lon_rho'}(handles.Jsrcchild+1,handles.Isrcchild+1);
  lat_src=nc{'lat_rho'}(handles.Jsrcchild+1,handles.Isrcchild+1);
  close(nc);
  h2=plot(lon_src,lat_src,'o',...
                'LineWidth',1.5,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','m',...
                'MarkerSize',7);
  hold off
end
return
