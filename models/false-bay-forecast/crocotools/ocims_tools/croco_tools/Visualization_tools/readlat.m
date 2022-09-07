function lat=readlat(nc);
lat=nc{'lat_rho'}(:);
if isempty(lat)
  lat=1e-5*nc{'y_rho'}(:);
end
if isempty(lat)
  error('READLAT: no horizontal coordinnate found')
end
return
