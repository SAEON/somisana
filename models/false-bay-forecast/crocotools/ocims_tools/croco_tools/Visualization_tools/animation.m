function animation(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  animation(handles)
%
%  Create an animation from a CROCO netcdf file
%
%  Switch to enable fli animations and/or mpeg animations 
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
%  Updated 02-Nov-2006 by Pierrick Penven (Yorig)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
anim_mpeg=1;
anim_fli=1;
%
moviename=[handles.vname,'_z',num2str(handles.vlevel),'.fli'];
%
vizdir=which('animation');
vizdir=vizdir(1:end-11);
%
% Initialise the animation 
%
fid = fli_begin;
fr = 0;
plot_index=0;
nc=netcdf(handles.hisfile);
ntime=length(nc('time'));
if ntime==0
  disp('Warning no time dimension found.. looking for tclm_time')
  ntime=length(nc('tclm_time'));
end
if ntime==0
  disp('Warning no time dimension found.. looking for time_counter')
  ntime=length(nc('time_counter'));
end
if ntime==0
  error('Warning no time dimension found')
end
close(nc)
%
% loop on the time 
%
for tindex=1:ntime
  plot_index=plot_index+1;
  if mod(plot_index,handles.skipanim)==0
    fr = fr + 1;
    figure(1)
    horizslice(handles.hisfile,handles.vname,plot_index,...
           handles.vlevel,handles.rempts,handles.coef,handles.gridlevs,...
	   handles.colmin,handles.colmax,handles.lonmin,handles.lonmax,...
           handles.latmin,handles.latmax,handles.ncol,...
           handles.pltstyle,handles.isobath,handles.cstep,...
           handles.cscale,handles.cunit,handles.coastfile,...
           handles.townfile,handles.gridfile,[],[],...
	   handles.Yorig)
    getframe_fli(fr,fid)
  end
end
if anim_mpeg==1
  eval(['!ppmtompeg ',vizdir,'inp_ppm2mpeg'])
  eval(['!mv movie.mpg ',handles.vname,'_z',num2str(handles.vlevel),'.mpg']);
end
if anim_fli==1
  fli_end(fid,moviename);
else
  eval(['!rm -f ','.ppm.list'])
end
