function write_NCEP(fname,vname,lon,lat,time,var,Yorig)

%----------------------------------------------------------
%
% Update Feb 2008, J Lefevre
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
%nc{'time'}.units = ncchar('hours since 1-1-1 00:00:00');
%nc{'time'}.units = 'hours since 1-1-1 00:00:00';
eval(['nc{''time''}.units = ncchar(''days since 1-Jan-',num2str(Yorig),' 00:00:00'');'])
eval(['nc{''time''}.units = ''days since 1-Jan-',num2str(Yorig),' 00:00:00'';'])
%
nc{vname} = ncfloat('time','lat','lon');
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

