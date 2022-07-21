function [j,i]=grid_pos(lon_grid,lat_grid,lon_real,lat_real);

%Purpose :
% find the i and j index of a real position on the CROCO grid
% lon_grid and lat_grid are 2D matrix : longitude and latitude of the CROCO grid
% lon_real,lat_real : are scalars for the real position point
%
dist=spheric_dist(lat_grid,lat_real,lon_grid,lon_real);
[j i]=find(dist==min(min(dist)));
%
return
