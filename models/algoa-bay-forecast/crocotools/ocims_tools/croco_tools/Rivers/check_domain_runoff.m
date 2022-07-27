function indomain=check_domain_runoff(lon_grid,lat_grid,lon_real,lat_real)
%
% Function that detect that the river is in the croco domain
%
% lat_real
% lon_real

if ( lon_real >= lon_grid(1,end) | lon_real <= lon_grid(1,1) ...
        | lat_real >= lat_grid(end,1) | lat_real <= lat_grid(1,1) )
    indomain=0;
else
    indomain=1;
end
return