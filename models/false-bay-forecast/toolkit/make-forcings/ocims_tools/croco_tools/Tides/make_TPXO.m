%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create and fill a netcdf TPXO file ready for CROCO
% 
%  Further Information:  
%  http://www.crocoagrif.org/croco_tools/
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
%  2015  Patrick Marchesiello  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%
%  Title
%
title='OTIS Mediterranian tidal elevation/currents file';
%
%  Original TPXO files
%
hfname='DATA/hf.Med2011.nc';
uvname='DATA/uv.Med2011.nc';
grdname='DATA/gridMed.nc';
%
%  Output TPXO file for CROCO pre-processing
%
outname='OTIS_Med.nc';
%
%  Period of tidal components in TPXO files:
%     "M2 S2 N2 K2 K1 O1 P1 Q1 Mf Mm" ;
%
components = 'M2 S2 N2 K2 K1 O1 P1 Q1 Mf Mm' ;
periods = [12.4206 12 12.6583 11.9672 23.9345 25.8193 24.0659 26.8684 ...
           327.8599, 661.31 ]; 
%
%----------------------------------------------------------------------
%  Read original TPXO files
%----------------------------------------------------------------------
%
%
nc=netcdf(grdname);
lon=squeeze(nc{'lon_z'}(:,1));
lat=squeeze(nc{'lat_z'}(1,:));
h=nc{'hz'}(:);
h=permute(h,[2 1]);
close(nc)

nc=netcdf(hfname);
ssh_r=nc{'hRe'}(:);
ssh_i=nc{'hIm'}(:);
ssh_r=permute(ssh_r,[1 3 2]);
ssh_i=permute(ssh_i,[1 3 2]);
close(nc)

nc=netcdf(uvname);
u_r=nc{'URe'}(:);
u_i=nc{'UIm'}(:);
u_r=permute(u_r,[1 3 2]);
u_i=permute(u_i,[1 3 2]);
v_r=nc{'VRe'}(:);
v_i=nc{'VIm'}(:);
v_r=permute(v_r,[1 3 2]);
v_i=permute(v_i,[1 3 2]);
close(nc)

ssh_r(ssh_r==0)=NaN;
ssh_r(ssh_r==0)=NaN;
u_r(u_r==0)=NaN;
u_r(u_r==0)=NaN;
v_r(v_r==0)=NaN;
v_r(v_r==0)=NaN;

pcolor(lon,lat,squeeze(ssh_r(5,:,:)));
shading flat
colorbar

%
%----------------------------------------------------------------------
%  Create TPXO file
%----------------------------------------------------------------------
% 
[Ntides M L]=size(ssh_r);

nw = netcdf(outname, 'clobber');
%
%  Dimensions
%
nw('lon_r') = L;
nw('lat_r') = M;
nw('lon_u') = L;
nw('lat_u') = M;
nw('lon_v') = L;
nw('lat_v') = M;
nw('periods') = Ntides;
%
%  Variables and attributes
%
nw{'lon_r'} = ncfloat('lon_r');
nw{'lon_r'}.long_name = ncchar('Longitude at SSH points');
nw{'lon_r'}.long_name = 'Longitude at SSH points';
nw{'lon_r'}.units = ncchar('degree_east');
nw{'lon_r'}.units = 'degree_east';

nw{'lat_r'} = ncfloat('lat_r');
nw{'lat_r'}.long_name = ncchar('Latitude at SSH points');
nw{'lat_r'}.long_name = 'Longitude at SSH points';
nw{'lat_r'}.units = ncchar('degree_east');
nw{'lat_r'}.units = 'degree_east';

nw{'lon_u'} = ncfloat('lon_u');
nw{'lon_u'}.long_name = ncchar('Longitude at U points');
nw{'lon_u'}.long_name = 'Longitude at U points';
nw{'lon_u'}.units = ncchar('degree_east');
nw{'lon_u'}.units = 'degree_east';

nw{'lat_u'} = ncfloat('lat_u');
nw{'lat_u'}.long_name = ncchar('Latitude at U points');
nw{'lat_u'}.long_name = 'Longitude at U points';
nw{'lat_u'}.units = ncchar('degree_east');
nw{'lat_u'}.units = 'degree_east';

nw{'lon_v'} = ncfloat('lon_v');
nw{'lon_v'}.long_name = ncchar('Longitude at V points');
nw{'lon_v'}.long_name = 'Longitude at V points';
nw{'lon_v'}.units = ncchar('degree_east');
nw{'lon_v'}.units = 'degree_east';

nw{'lat_v'} = ncfloat('lat_v');
nw{'lat_v'}.long_name = ncchar('Latitude at V points');
nw{'lat_v'}.long_name = 'Longitude at V points';
nw{'lat_v'}.units = ncchar('degree_east');
nw{'lat_v'}.units = 'degree_east';

nw{'periods'} = ncfloat('periods');
nw{'periods'}.long_name = ncchar('Tide periods');
nw{'periods'}.long_name = 'Tide periods';
nw{'periods'}.units = ncchar('hours');
nw{'periods'}.units = 'hours';

nw{'h'} = ncfloat('lat_r', 'lon_r');
nw{'h'}.long_name = ncchar('Tpography at SSH-points');
nw{'h'}.long_name = 'Final bathymetry at SSH-points';
nw{'h'}.units = ncchar('meter');
nw{'h'}.units = 'meter';

nw{'ssh_r'} = ncfloat('periods', 'lat_r', 'lon_r');
nw{'ssh_r'}.long_name = ncchar('Elevation real part');
nw{'ssh_r'}.long_name = 'Elevation real part';
nw{'ssh_r'}.units = ncchar('meter');
nw{'ssh_r'}.units = 'meter';

nw{'ssh_i'} = ncfloat('periods', 'lat_r', 'lon_r');
nw{'ssh_i'}.long_name = ncchar('Elevation iimaginary part');
nw{'ssh_i'}.long_name = 'Elevation imaginary part';
nw{'ssh_i'}.units = ncchar('meter');
nw{'ssh_i'}.units = 'meter';

nw{'u_r'} = ncfloat('periods', 'lat_u', 'lon_u');
nw{'u_r'}.long_name = ncchar('U-transport component real part');
nw{'u_r'}.long_name = 'U-transport component real part';
nw{'u_r'}.units = ncchar('m2/s');
nw{'u_r'}.units = 'm2/s';

nw{'u_i'} = ncfloat('periods', 'lat_u', 'lon_u');
nw{'u_i'}.long_name = ncchar('U-transport component imaginary part');
nw{'u_i'}.long_name = 'U-transport component imaginary part';
nw{'u_i'}.units = ncchar('m2/s');
nw{'u_i'}.units = 'm2/s';

nw{'v_r'} = ncfloat('periods', 'lat_v', 'lon_v');
nw{'v_r'}.long_name = ncchar('V-transport component real part');
nw{'v_r'}.long_name = 'V-transport component real part';
nw{'v_r'}.units = ncchar('m2/s');
nw{'v_r'}.units = 'm2/s';

nw{'v_i'} = ncfloat('periods', 'lat_v', 'lon_v');
nw{'v_i'}.long_name = ncchar('V-transport component imaginary part');
nw{'v_i'}.long_name = 'V-transport component imaginary part';
nw{'v_i'}.units = ncchar('m2/s');
nw{'v_i'}.units = 'm2/s';
%
%  Global attributes
%
nw.type = ncchar('Tides file for CROCO pre-processing');
nw.type = 'Tides file for CROCO pre-processing';
nw.title = ncchar(title);
nw.title = title;
nw.date = ncchar(date);
nw.date = date;
components=components(1:3*Ntides);
nw.components = ncchar(components);
nw.components = components;

close(nw);

%
%----------------------------------------------------------------------
%  Fill in TPXO file
%----------------------------------------------------------------------
%
nw=netcdf(outname,'w');
nw{'lon_r'}(:)=lon;
nw{'lat_r'}(:)=lat;
nw{'lon_u'}(:)=lon;
nw{'lat_u'}(:)=lat;
nw{'lon_v'}(:)=lon;
nw{'lat_v'}(:)=lat;
nw{'periods'}(:)=periods(1:Ntides);
nw{'h'}(:)=h;
nw{'ssh_r'}(:)=ssh_r(1:Ntides,:,:);
nw{'ssh_i'}(:)=ssh_i(1:Ntides,:,:);
nw{'u_r'}(:)=u_r(1:Ntides,:,:);
nw{'u_i'}(:)=u_i(1:Ntides,:,:);
nw{'v_r'}(:)=v_r(1:Ntides,:,:);
nw{'v_i'}(:)=v_i(1:Ntides,:,:);
close(nw)

