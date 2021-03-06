function handles=interp_forcing(h,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get everything in order to compute the child forcing file
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

if isempty(handles.parentgrid)
  handles=get_parentfrcname(h,handles);
end
if isempty(handles.childgrid)
  handles=get_childgrdname(h,handles); 
end
if isempty(handles.parentfrc)
  handles=get_parentfrcname(h,handles);
end
lev=str2num(handles.parentfrc(end));
if isempty(lev)
  childname=[handles.parentfrc,'.1'];
else
  childname=[handles.parentfrc(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child forcing name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
case {'Cancel'}
  return
case 'Yes'
  handles.childfrc=childname;
end
nested_forcing(handles.childgrid,handles.parentfrc,handles.childfrc)
return
