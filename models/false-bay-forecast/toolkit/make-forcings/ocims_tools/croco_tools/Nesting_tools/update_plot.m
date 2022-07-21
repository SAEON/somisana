function handles=update_plot(h,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Update the values on the GUI
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
%  Updated    6-Apr-2007 by Pierrick Penven (display MMm instead of M)
%  Updated    6-Apr-2007 by Pierrick Penven (display LLm instead of L)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(handles.edit_imin,'String',num2str(handles.imin));
set(handles.edit_imax,'String',num2str(handles.imax));
set(handles.edit_jmin,'String',num2str(handles.jmin));
set(handles.edit_jmax,'String',num2str(handles.jmax));
%
handles.Lchild=1+handles.rcoeff*(handles.imax-handles.imin);
set(handles.editLchild,'String',num2str(handles.Lchild-1));
handles.Mchild=1+handles.rcoeff*(handles.jmax-handles.jmin);
set(handles.editMchild,'String',num2str(handles.Mchild-1));
%
if (~isempty(handles.Isrcparent)) & ~(isempty(handles.Jsrcparent))
  set(handles.edit_Isrcparent,'String',num2str(handles.Isrcparent));
  set(handles.edit_Jsrcparent,'String',num2str(handles.Jsrcparent));
  handles.Isrcchild=(handles.Isrcparent-handles.imin)*handles.rcoeff+...
                    floor(0.5*handles.rcoeff)+1;
  handles.Jsrcchild=(handles.Jsrcparent-handles.jmin)*handles.rcoeff+...
                    floor(0.5*handles.rcoeff)+1;
		    
  set(handles.edit_Isrcchild,'String',num2str(handles.Isrcchild));
  set(handles.edit_Jsrcchild,'String',num2str(handles.Jsrcchild));
end



%if (~isempty(handles.Isrcchild)) & ~(isempty(handles.Jsrcchild))
%  set(handles.edit_Isrcchild,'String',num2str(handles.Isrcchild));
%   set(handles.edit_Jsrcchild,'String',num2str(handles.Jsrcchild));
%end
%
plot_nestgrid(h,handles)
%
return
