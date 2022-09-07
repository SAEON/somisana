function data=ext_data_tpxo(datafile,dataname,itide,lon,lat,type,Roa)
%
%  Read in TPXO tide file and extrapole 1 horizontal
%  slice on a CROCO grid
%
%  Change the transport into barotropic velocities
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Getting ',dataname,' for time index ',num2str(itide)])
%
% Default values
%
default=NaN;
%
% Missing values
%
missval=NaN;
%
% Distance (deg) to look for data outside croco grid.
%
dl=1;
%
[x,y,data]=read_data_tpxo(datafile,dataname,itide,lon,lat,type,dl);
%
% Transform the transports into velocities
%
if dataname(1)=='u' | dataname(1)=='v'
  [xh,yh,h]=read_data_tpxo(datafile,'h',[],lon,lat,'r',2*dl);
  h=interp2(xh,yh,h,x,y,'linear');
  h(h<10)=NaN;  %problems in shallow water with TPXO7
  data=data./h;
end
%
% Perform the extrapolation
%
data=get_missing_val(x,y,data,missval,Roa,default);
%
% Interpolation on the CROCO grid
%
data=interp2(x,y,data,lon,lat,'cubic');
%
return
