function handles=reset_handle(fig,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Put all the handles.XX objects to their default values
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
handles.toponame=[];
handles.parentgrid=[];
handles.childgrid=[];
handles.parentfrc=[];
handles.childfrc=[];
handles.parentdust=[];
handles.childdust=[];
handles.parentblk=[];
handles.childblk=[];
handles.parentini=[];
handles.childini=[];
handles.parentclm=[];
handles.childclm=[];
handles.parentrst=[];
handles.childrst=[];
handles.lonmin=[];
handles.lonmax=[];
handles.latmin=[];
handles.latmax=[];
handles.imin=[];
handles.imax=[];
handles.jmin=[];
handles.jmax=[];
handles.rcoeff=3;
handles.Lparent=[];
handles.Mparent=[];
handles.Lchild=[];
handles.Mchild=[];
handles.rfactor=0.2;
handles.nband=15;
handles.hmin=[];
handles.hmax_coast=500;
handles.newtopo=0;
handles.matchvolume=0;
handles.vertical_correc=1;
handles.extrapmask=1;
handles.biol=0;
handles.pisces=0;
handles.bioebus=0;
handles.Isrcparent=[];
handles.Jsrcparent=[];
handles.Isrcchild=[];
handles.Jsrcchild=[];

handles.n_filter_deep=4;
handles.n_filter_final=2;

guidata(fig, handles);
return
