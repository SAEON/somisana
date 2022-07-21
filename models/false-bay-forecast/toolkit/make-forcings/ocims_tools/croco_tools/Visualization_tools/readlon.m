function lon=readlon(nc);
lon=nc{'lon_rho'}(:);
if isempty(lon)
  lon=1e-5*nc{'x_rho'}(:);
end
if isempty(lon)
  error('READLON: no horizontal coordinate found')
end
return
