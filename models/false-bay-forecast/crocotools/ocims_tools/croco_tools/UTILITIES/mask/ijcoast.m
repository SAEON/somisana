function [C]=ijcoast(Gname,Cname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Hernan G. Arango %%%%
% Copyright (c) 2001 Rutgers University.                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
% function [C]=ijcoast(Gname,Cname)                                    %
%                                                                      %
% This script converts coastline data to GRID indices for a particular %
% application.  This will used in the Land/Sea masking tools.          %
%                                                                      %
% On Input:                                                            %
%                                                                      %
%    Gname       NetCDF file name (character string).                  %
%    Cname       Coastline file name (character string).               %
%                                                                      %
% On Output:                                                           %
%                                                                      %
%    C           Coastline indices (structure array):                  %
%                  C.grid    => Grid file name.                        %
%                  C.coast   => Coastline file name.                   %
%                  C.indices => Coastline indices file name.           %
%                  C.lon     => Coastline longitudes.                  %
%                  C.lat     => Coastline latitudes.                   %
%                  C.Icst    => Coastline I-grid coordinates, (0:L).   %
%                  C.Jcst    => Coastline J-grid coordinates, (0:M).   %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EXTRACT=0;
method='linear';

C.grid=Gname;
C.coast=Cname;
C.indices='ijcoast.mat';

%-----------------------------------------------------------------------
% Read in grid coordinates at rho-points.
%-----------------------------------------------------------------------

rlon=nc_read(Gname,'lon_rho');
rlat=nc_read(Gname,'lat_rho');

[Lp,Mp]=size(rlon);
L=Lp-1;
M=Mp-1;

%-----------------------------------------------------------------------
% Read in coastline data.
%-----------------------------------------------------------------------

load(Cname);
Clon=lon;
Clat=lat;

%-----------------------------------------------------------------------
% Extract need coasline data.
%-----------------------------------------------------------------------

if (EXTRACT),

  dx=5*abs(mean(mean(gradient(rlon))));
  dy=5*abs(mean(mean(gradient(rlat))));

  C.Llon=min(min(rlon));  C.Llon=C.Llon-dx;
  C.Rlon=max(max(rlon));  C.Rlon=C.Rlon+dx;
  C.Blat=min(min(rlat));  C.Blat=C.Blat-dy;
  C.Tlat=max(max(rlat));  C.Tlat=C.Tlat+dy;

  ind=find(Clon > C.Rlon | Clon < C.Llon | Clat > C.Tlat | Clat < C.Blat);
  clon=Clon;
  clat=Clat;
  if (~isempty(ind)),
    clon(ind)=[];
    clat(ind)=[];
  end,

  C.lon=[NaN; clon; NaN];
  C.lat=[NaN; clat; NaN];

else,

  clon=Clon;
  clat=Clat;

  C.lon=clon;
  C.lat=clat;

end,

clear Clon Clat clon clat

%-----------------------------------------------------------------------
% Interpolate coastline to grid units.
%-----------------------------------------------------------------------

disp(['Converting coastline (lon,lat) to (I,J) grid indices.']);

[y,x]=meshgrid(1:Mp,1:Lp);

C.Icst=griddata(rlon,rlat,x,C.lon,C.lat,method);
C.Jcst=griddata(rlon,rlat,y,C.lon,C.lat,method);

%  Substrat one to have indices in the range (0:L,0:M).

C.Icst=C.Icst-1;
C.Jcst=C.Jcst-1;

%-----------------------------------------------------------------------
%  Save sctructure array into a Matlab file.
%-----------------------------------------------------------------------

disp(['Saving coastline (I,J) into file: ',C.indices]);

save(C.indices,'C');

return
