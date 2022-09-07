%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Create an animation from a CROCO simulation.
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    10-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
anim_mpeg=1;
anim_fli=1;
%
% Directory and file names
%
directory=[RUN_dir,'SCRATCH/'];
%
% Directory and file names
%
model='croco';
filetype='avg';  % 'his' or 'avg'
Ymin=1;
Ymax=10;
Mmin=1;
Mmax=12;
%
Yorig=NaN;     % Year origin (Nan: climatology experiment)
%
% Variable name and vertical level (< 0 if horizontal z level).
%
vname='zeta'; 
vlevel=32;
%
% Plot properties
%
zoom=0;          % Increase or reduce the size of the image.
skipanim=2;      % Using an image every .. images for the animation.
rempts=[0 0 0 0]; % Remove .. points from the boundary 
gridlevs=0;      % Number of embedded grids
pltstyle=2;      % Plot style: 1:pcolor, 2: contourf, 3: contour, ...
isobath='0 0';   % Bathymetric isolignes to add.
%
% Colors properties (minimum, maximum, number of values)
%
coeff=100;         % Multiplicate the variable by this coeff
colmin=-100;
colmax=100;
ncol=10;
%
% Current vectors property (number of spatial steps between vectors, 
% length of vectors, length of the unit vector on the bottom right).
%
cstep=0;
cscale=10;
cunit=1;
%
% Coastline, Town and Grid file names.
%
coastfile='coastline_l.mat';
townfile='';
gridfile=[directory,model,'_',filetype,'_Y',num2str(Ymin),'M',num2str(Mmin),'.nc']
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
vizdir=which('animation');
vizdir=vizdir(1:end-11);
%
[lat,lon,mask]=read_latlonmask(gridfile,'r');
lonmin=min(min(lon))-zoom;
lonmax=max(max(lon))+zoom;
latmin=min(min(lat))-zoom;
latmax=max(max(lat))+zoom;
%
moviename=[vname,'_z',num2str(vlevel),'.fli'];
%
% Initialise the animation 
%
fid = fli_begin;
fr = 0;
for Y=Ymin:Ymax
  if Y==Ymin 
    mo_min=Mmin;
  else
    mo_min=1;
  end
  if Y==Ymax
    mo_max=Mmax;
  else
    mo_max=12;
  end
  for M=mo_min:mo_max
    hisfile=[directory,model,'_',filetype,'_Y',num2str(Y),'M',num2str(M),'.nc'];
    disp(['Opening : ',hisfile])
    nc=netcdf(hisfile);
    if isempty(nc)
      disp(['Could ont open : ',hisfile])
    else
      ntime=length(nc('time'));
      close(nc)
      if (filetype=='his' & ~(Y==Ymin & M==Mmin))
        nstart=2;
      else
        nstart=1;
      end
      plot_index=nstart-1;
%
% loop on the time indexes in the file 
%
      for tindex=nstart:ntime
        plot_index=plot_index+1;
        if mod(plot_index,skipanim)==0
          fr = fr + 1;
          figure(1)
          horizslice(hisfile,vname,tindex,...
                   vlevel,rempts,coeff,gridlevs,...
    	           colmin,colmax,lonmin,lonmax,...
                   latmin,latmax,ncol,...
                   pltstyle,isobath,cstep,...
                   cscale,cunit,coastfile,...
                   townfile,gridfile,[],[],Yorig);
          getframe_fli(fr,fid);
        end
      end
    end
  end
end
if anim_mpeg==1
  eval(['!ppmtompeg ',vizdir,'inp_ppm2mpeg'])
  eval(['!mv movie.mpg ',vname,'_z',num2str(vlevel),'.mpg']);
end
if anim_fli==1
  fli_end(fid,moviename);
else
  eval(['!rm -f ','.ppm.list'])
end
