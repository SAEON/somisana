function write_NCEP_Mask(fname,vname,lon,lat,var)

%----------------------------------------------------------
%
% Update Feb 2008, J Lefevre
%----------------------------------------------------------

disp(['    Create ',fname])
nc=netcdf([fname],'clobber');
%
nc('lon') = length(lon);
nc('lat') = length(lat);
%
nc{'lon'} = ncfloat('lon');
nc{'lon'}.long_name = ncchar('longitude of RHO-points');
nc{'lon'}.long_name = 'longitude of RHO-points';
nc{'lon'}.units = ncchar('degree_east');
nc{'lon'}.units = 'degree_east';
% 
nc{'lat'} = ncfloat('lat');
nc{'lat'}.long_name = ncchar('latitude of RHO-points');
nc{'lat'}.long_name = 'latitude of RHO-points';
nc{'lat'}.units = ncchar('degree_north');
nc{'lat'}.units = 'degree_north';
%
nc{vname} = ncfloat('lat','lon');
%
endef(nc);
%
nc{'lon'}(:)=lon;
nc{'lat'}(:)=lat;
nc{vname}(:)=var;
%
close(nc)
return