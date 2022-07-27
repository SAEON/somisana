function write_ECMWF(fname,vname,lon,lat,time,var,Yorig)

%----------------------------------------------------------
%
% Update June 2010, S Illig
%----------------------------------------------------------

disp(['    Create ',fname])
nc=netcdf([fname],'clobber');
%
nc('lon') = length(lon);
nc('lat') = length(lat);
nc('time') = length(time);
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
nc{'time'} = ncfloat('time');
nc{'time'}.long_name = ncchar('Time');
nc{'time'}.long_name = 'Time';
eval(['nc{''time''}.units = ncchar(''days since ',num2str(Yorig),'-01-01  00:00:00'');'])
eval(['nc{''time''}.units = ''days since ',num2str(Yorig),'-01-01  00:00:00'';'])
%
nc{vname} = ncfloat('time','lat','lon');
nc{vname}.missing_value = 9999.0;
%
endef(nc);
%
nc{'lon'}(:)=lon;
nc{'lat'}(:)=lat;
nc{'time'}(:)=time;
nc{vname}(:)=var;

%
close(nc)
return

