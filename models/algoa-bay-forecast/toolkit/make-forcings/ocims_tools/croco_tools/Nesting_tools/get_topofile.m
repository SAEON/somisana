function handles=get_topofile(h,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get the name of the topography file from the GUI
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
[filename, pathname] = uigetfile({'*.nc', 'All netcdf-Files (*.nc)'; ...
		'*.*','All Files (*.*)'},'TOPO FILE');
if isequal([filename,pathname],[0,0])
  set(handles.newtopo_button,'Value',0)
  handles.newtopo=0;
  set(handles.matchvolume_button,'Value',0)
  handles.matchvolume=0;
  set(handles.vcorrec_button,'Value',0)
  handles.vertical_correc=0;
  set(handles.extrap_button,'Value',0)
  handles.extrapmask=0;
  handles.toponame=[];
  return
end
handles.toponame=fullfile(pathname,filename);
set(handles.newtopo_button,'Value',1)
handles.newtopo=1;
%set(handles.matchvolume_button,'Value',1)
%handles.matchvolume=1;
set(handles.vcorrec_button,'Value',1)
handles.vertical_correc=1;
set(handles.extrap_button,'Value',1)
handles.extrapmask=1;

nc=netcdf(handles.toponame,'nowrite');
if ~isempty(nc)
  try
    a=datatype(nc{'topo'});
    close(nc)
    return
  catch
    disp('This is not a netcdf topography file')
  end
else
  disp('This is not a netcdf file')
end
set(handles.newtopo_button,'Value',0)
handles.newtopo=0;
set(handles.matchvolume_button,'Value',0)
handles.matchvolume=0;
set(handles.vcorrec_button,'Value',0)
handles.vertical_correc=0;
set(handles.extrap_button,'Value',0)
handles.extrapmask=0;
handles.toponame=[];
return
