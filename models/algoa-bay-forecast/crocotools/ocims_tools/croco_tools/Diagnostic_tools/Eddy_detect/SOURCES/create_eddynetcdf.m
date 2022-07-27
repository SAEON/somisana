function nc=create_eddynetcdf(fname);
%
%  function nc=create_eddynetcdf(fname);
%
%
%
% Create an eddy netcdf file
%
% Pierrick Penven 2011
%
nc=netcdf(fname,'clobber');
redef(nc)
nc('entries') = 0;
%
nc{'time'} = ncdouble('entries') ;
nc{'time'}.long_name = ncchar('Eddy time');
nc{'time'}.long_name = 'Eddy time';
nc{'time'}.units = ncchar('Days since Yorig/1/1');
nc{'time'}.units = 'Days since Yorig/1/1';

nc{'ID'} = ncdouble('entries') ;
nc{'ID'}.long_name = ncchar('Eddy identification number');
nc{'ID'}.long_name = 'Eddy identification number';

nc{'lon'} = ncdouble('entries') ;
nc{'lon'}.long_name = ncchar('Eddy longitude');
nc{'lon'}.long_name = 'Eddy longitude';
nc{'lon'}.units = ncchar('deg E');
nc{'lon'}.units = 'deg E';

nc{'lat'} = ncdouble('entries') ;
nc{'lat'}.long_name = ncchar('Eddy latitude');
nc{'lat'}.long_name = 'Eddy latitude';
nc{'lat'}.units = ncchar('deg N');
nc{'lat'}.units = 'deg N';

nc{'Area'} = ncdouble('entries') ;
nc{'Area'}.long_name = ncchar('Eddy area');
nc{'Area'}.long_name = 'Eddy area';
nc{'Area'}.units = ncchar('m2');
nc{'Area'}.units = 'm2';

nc{'Energy'} = ncdouble('entries') ;
nc{'Energy'}.long_name = ncchar('Eddy surface energy');
nc{'Energy'}.long_name = 'Eddy surface energy';
nc{'Energy'}.units = ncchar('m4.s-2');
nc{'Energy'}.units = 'm4.s-2';

nc{'Vorticity'} = ncdouble('entries') ;
nc{'Vorticity'}.long_name = ncchar('Eddy mean surface vorticity');
nc{'Vorticity'}.long_name = 'Eddy mean surface vorticity';
nc{'Vorticity'}.units = ncchar('s-1');
nc{'Vorticity'}.units = 's-1';

nc{'Radius'} = ncdouble('entries') ;
nc{'Radius'}.long_name = ncchar('Eddy equivalent radius');
nc{'Radius'}.long_name = 'Eddy equivalent radius';
nc{'Radius'}.units = ncchar('m');
nc{'Radius'}.units = 'm';

nc{'MaxSSH'} = ncdouble('entries') ;
nc{'MaxSSH'}.long_name = ncchar('Eddy maximum SSH');
nc{'MaxSSH'}.long_name = 'Eddy maximum SSH';
nc{'MaxSSH'}.units = ncchar('m');
nc{'MaxSSH'}.units = 'm';

nc{'MinSSH'} = ncdouble('entries') ;
nc{'MinSSH'}.long_name = ncchar('Eddy minimum SSH');
nc{'MinSSH'}.long_name = 'Eddy minimum SSH';
nc{'MinSSH'}.units = ncchar('m');
nc{'MinSSH'}.units = 'm';

nc{'MeanSSH'} = ncdouble('entries') ;
nc{'MeanSSH'}.long_name = ncchar('Eddy mean SSH');
nc{'MeanSSH'}.long_name = 'Eddy mean SSH';
nc{'MeanSSH'}.units = ncchar('m');
nc{'MeanSSH'}.units = 'm';

nc{'Amplitude'} = ncdouble('entries') ;
nc{'Amplitude'}.long_name = ncchar('Eddy amplitude');
nc{'Amplitude'}.long_name = 'Eddy amplitude';
nc{'Amplitude'}.units = ncchar('m');
nc{'Amplitude'}.units = 'm';

nc{'Ueddy'} = ncdouble('entries') ;
nc{'Ueddy'}.long_name = ncchar('Eddy rotational speed (chelton et al., 2011)');
nc{'Ueddy'}.long_name = 'Eddy rotational speed (chelton et al., 2011)';
nc{'Ueddy'}.units = ncchar('m.s-1');
nc{'Ueddy'}.units = '';

nc{'Leddy'} = ncdouble('entries') ;
nc{'Leddy'}.long_name = ncchar('Eddy scale (chelton et al., 2011)');
nc{'Leddy'}.long_name = 'Eddy scale (chelton et al., 2011)';
nc{'Leddy'}.units = ncchar('m');
nc{'Leddy'}.units = 'm';

nc{'U'} = ncdouble('entries') ;
nc{'U'}.long_name = ncchar('Eddy zonal propagation speed');
nc{'U'}.long_name = 'Eddy zonal propagation speed';
nc{'U'}.units = ncchar('m.s-1');
nc{'U'}.units = 'm.s-1';

nc{'V'} = ncdouble('entries') ;
nc{'V'}.long_name = ncchar('Eddy zonal propagation speed');
nc{'V'}.long_name = 'Eddy zonal propagation speed';
nc{'V'}.units = ncchar('m.s-1');
nc{'V'}.units = 'm.s-1';

nc.date = ncchar(date);
nc.date = date;
endef(nc)
return
