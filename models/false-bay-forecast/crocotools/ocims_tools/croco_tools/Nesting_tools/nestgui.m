function varargout = nestgui(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  NESTGUI Application M-file for nestgui.fig
% 
%  GUI to generate embedded CROCO grid, forcing, bulk, initial, and restart
%  netcdf files 
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
%  Updated    22-Sep-2006 by Pierrick Penven (hmax coast, filter deep, filter final)
%  Updated    28-Sep-2006 by Pierrick Penven (bulk files)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0  % LAUNCH GUI
  warning off
  fig = openfig(mfilename,'new');
  warning on
  set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
  handles = guihandles(fig);
  guidata(fig, handles);
  parentgrid_Callback(fig, [], handles, varargin)  
  if nargout > 0
    varargout{1} = fig;
  end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
  try
    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
  catch
    disp(lasterr);
  end
end
%
% MENU : OPEN PARENT GRID FILE
%
function varargout = parentgrid_Callback(h, eventdata, handles, varargin)
handles=get_parentgrdname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN CHILD GRID FILE
%
function varargout = childgrid_Callback(h, eventdata, handles, varargin)
handles=get_childgrdname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT FORCING FILE
%
function varargout = parentforcing_Callback(h, eventdata, handles, varargin)
handles=get_parentfrcname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT BULK FILE
%
function varargout = parentbulk_Callback(h, eventdata, handles, varargin)
handles=get_parentblkname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT DUST FILE
%
function varargout = parentdust_Callback(h, eventdata, handles, varargin)
handles=get_parentdustname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT INITIAL FILE
%
function varargout = parentinitial_Callback(h, eventdata, handles, varargin)
handles=get_parentininame(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN TOPO FILE
%
function varargout = topo_Callback(h, eventdata, handles, varargin)
handles=get_topofile(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT RESTART FILE
%
function varargout = parentrst_Callback(h, eventdata, handles, varargin)
handles=get_parentrstname(h,handles);
guidata(h,handles)
return
%
% MENU : OPEN PARENT CLIMATOLOGY FILE
%
function varargout = parentclm_Callback(h, eventdata, handles, varargin)
handles=get_parentclmname(h,handles);
guidata(h,handles)
return
%
%  ZOOMS
%
function varargout = zoomin_Callback(h, eventdata, handles, varargin)
handles=zoomin(h,handles);
guidata(h,handles)
return
function varargout = zoomout_Callback(h, eventdata, handles, varargin)
handles=zoomout(h,handles);
guidata(h,handles)
return
%
% Get the child grid position
%
function varargout = findgridpos_Callback(h, eventdata, handles, varargin)
handles=get_findgridpos(h,handles);
guidata(h,handles)
return
%
% L,M
%
function varargout = editLchild_Callback(h, eventdata, handles, varargin)
handles=get_Lchild(h,handles);
guidata(h,handles)
return
function varargout = editMchild_Callback(h, eventdata, handles, varargin)
handles=get_Mchild(h,handles);
guidata(h,handles)
return
%
% IMIN
%
function varargout = edit_imin_Callback(h, eventdata, handles, varargin)
handles=get_imin(h,handles);
guidata(h,handles)
return
%
% IMAX
%
function varargout = edit_imax_Callback(h, eventdata, handles, varargin)
handles=get_imax(h,handles);
guidata(h,handles)
return
%
% JMIN
%
function varargout = edit_jmin_Callback(h, eventdata, handles, varargin)
handles=get_jmin(h,handles);
guidata(h,handles)
return
%
% JMAX
%
function varargout = edit_jmax_Callback(h, eventdata, handles, varargin)
handles=get_jmax(h,handles);
guidata(h,handles)
return
%
% Refinment coefficient
%
function varargout = edit_rcoef_Callback(h, eventdata, handles, varargin)
handles=get_rcoef(h,handles);
guidata(h,handles)
return
%
% r-factor
%
function varargout = editrfactor_Callback(h, eventdata, handles, varargin)
handles=get_rfactor(h,handles);
guidata(h,handles)
return
%
% n-band
%
function varargout = editnband_Callback(h, eventdata, handles, varargin)
handles=get_nband(h,handles);
guidata(h,handles)
return
%
% Hmin
%
function varargout = edithmin_Callback(h, eventdata, handles, varargin)
handles=get_hmin(h,handles);
guidata(h,handles)
return
%
% Hmax coast
%
function varargout = edithmax_Callback(h, eventdata, handles, varargin)
handles=get_hmax_coast(h,handles);
guidata(h,handles)
return
%
% edit_n_filter_deep
%
function varargout = edit_n_filter_deep_Callback(h, eventdata, handles, varargin)
handles=get_n_filter_deep(h,handles);
guidata(h,handles)
return
%
% edit_n_filter_final
%
function varargout = edit_n_filter_final_Callback(h, eventdata, handles, varargin)
handles=get_n_filter_final(h,handles);
guidata(h,handles)
return

%
% New topo switch
%
function varargout = newtopo_Callback(h, eventdata, handles, varargin)
handles=get_newtopobutton(h,handles);
guidata(h,handles)
return
%
% Match volume switch
%
function varargout = matchvolume_Callback(h, eventdata, handles, varargin)
handles=get_matchvolumebutton(h,handles);
guidata(h,handles)
return
%
% Interp the child grid
%
function varargout = interpchild_Callback(h, eventdata, handles, varargin)
handles=interp_child(h,handles);
guidata(h,handles)
return
%
% Interp the child forcing
%
function varargout=interpforcing_Callback(h, eventdata, handles, varargin)
handles=interp_forcing(h,handles);
guidata(h,handles)
return
%
% Interp the child bulk
%
function varargout=interpbulk_Callback(h, eventdata, handles, varargin)
handles=interp_bulk(h,handles);
guidata(h,handles)
return
%
% Interp the child dust
%
function varargout=interpdust_Callback(h, eventdata, handles, varargin)
handles=interp_dust(h,handles);
guidata(h,handles)
return
%
% Interp the child initial conditions
%
function varargout=interpinitial_Callback(h, eventdata, handles, varargin)
handles=interp_initial(h,handles);
guidata(h,handles)
return
%
% Interp the child restart conditions
%
function varargout=interprestart_Callback(h, eventdata, handles, varargin)
handles=interp_restart(h,handles);
guidata(h,handles)
return
%
% Interp the child boundary conditions
%
function varargout=interpclim_Callback(h, eventdata, handles, varargin)
handles=interp_clim(h,handles);
guidata(h,handles)
return
%
% Vertical correction switch
%
function varargout = vcorrec_Callback(h, eventdata, handles, varargin)
handles.vertical_correc=1-handles.vertical_correc;
guidata(h,handles)
return
%
%  Extrapolations switch
%
function varargout = extrap_Callback(h, eventdata, handles, varargin)
handles.extrapmask=1-handles.extrapmask;
guidata(h,handles)
return
%
%  Biologie switch
%
function varargout = biol_Callback(h, eventdata, handles, varargin)
handles=get_biolbutton(h,handles);
guidata(h,handles)
return
%
% Bioebus switch
%
function varargout = bioebus_Callback(h, eventdata, handles, varargin)
handles=get_bioebusbutton(h,handles);
guidata(h,handles)
return
%
% Pisces switch
%
function varargout = pisces_Callback(h, eventdata, handles, varargin)
handles=get_piscesbutton(h,handles);
guidata(h,handles)
return
%
% Rivers
%
function varargout = addriver_Callback(h, eventdata, handles, varargin)
handles=get_river(h,handles);
guidata(h,handles)
return
function varargout = edit_Isrcparent_Callback(h, eventdata, handles, varargin)
set(handles.edit_Isrcparent,'String',num2str(handles.Isrcparent));
guidata(h,handles)
return
function varargout = edit_Jsrcparent_Callback(h, eventdata, handles, varargin)
set(handles.edit_Jsrcparent,'String',num2str(handles.Jsrcparent));
guidata(h,handles)
return
function varargout = edit_Isrcchild_Callback(h, eventdata, handles, varargin)
set(handles.edit_Isrcchild,'String',num2str(handles.Isrcchild));
guidata(h,handles)
return
function varargout = edit_Jsrcchild_Callback(h, eventdata, handles, varargin)
set(handles.edit_Jsrcchild,'String',num2str(handles.Jsrcchild));
guidata(h,handles)
return
%
% Create the croco.in.# file
%
function create_crocoin_Callback(h, eventdata, handles, varargin)
[filename,pathname]=uigetfile({'*.in*','All input files (*.in*)';...
		    '*.*','All Files (*.*)'},'PARENT INPUT FILE');
if isequal([filename,pathname],[0,0])
  return
end
crocoin_parent_name=fullfile(pathname,filename);
lev=str2num(crocoin_parent_name(end));
if isempty(lev)
  crocoin_child_name=[crocoin_parent_name,'.1'];
else
  crocoin_child_name=[crocoin_parent_name(1:end-1),num2str(lev+1)];
end
create_crocoin(crocoin_parent_name,crocoin_child_name,handles.rcoeff,lev)
guidata(h,handles)
return
%
% Create the Agrif_FixedGrids.in file
%
function agrif_fixed_grid_Callback(h, eventdata, handles, varargin)
create_agrif_fixedgrids_in(handles.imin,handles.imax,handles.jmin,...
                           handles.jmax,handles.rcoeff)
guidata(h,handles)
return

