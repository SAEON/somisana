function handles=interp_dust(h,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get everything in order to compute the child dust forcing file
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
%  Update Gildas Cambon 13 Oct 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(handles.parentgrid)
  handles=get_parentdustname(h,handles);
end
if isempty(handles.childgrid)
  handles=get_childgrdname(h,handles); 
end
if isempty(handles.parentdust)
  handles=get_parentdustname(h,handles);
end
lev=str2num(handles.parentdust(end));
if isempty(lev)
  childname=[handles.parentdust,'.1'];
else
  childname=[handles.parentdust(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child dust name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
 case {'Cancel'}
  return
 case 'Yes'
  handles.childdust=childname;
end
nested_dust(handles.childgrid,handles.parentdust,handles.childdust)
return
