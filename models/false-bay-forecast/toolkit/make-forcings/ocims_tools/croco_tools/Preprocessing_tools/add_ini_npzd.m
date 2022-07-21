function add_ini_npzd(inifile,clobber)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2014 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%  function nc=add_ini_npzd(inifile,clobber)                      %
%                                                                 %
%   This function create the header of a Netcdf climatology       %
%   file.                                                         %
%                                                                 %
%   Input:                                                        %
%                                                                 %
%   inifile      Netcdf initial file name (character string).     %
%   clobber      Switch to allow or not writing over an existing  %
%                file.(character string)                          %
%                                                                 %
%   Output                                                        %
%                                                                 %
%   nc       Output netcdf object.                                %
%                                                                 %
%   Gildas Cambon, IRD, 20123                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding NPZD data in file : ',inifile])
%
%  Create the initial file
%
nc = netcdf(inifile,clobber);
%%result = redef(nc);
%
%  Create variables
%
nc{'NO3'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'O2'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
%
%  Create attributes
%
nc{'NO3'}.long_name = ncchar('NO3');
nc{'NO3'}.long_name = 'NO3';
nc{'NO3'}.units = ncchar('mMol N m-3');
nc{'NO3'}.units = 'mMol N m-3';
%
nc{'O2'}.long_name = ncchar('O2');
nc{'O2'}.long_name = 'O2';
nc{'O2'}.units = ncchar('mMol O m-3');
nc{'O2'}.units = 'mMol O m-3';
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
nc{'NO3'}(:)  =  0;
nc{'O2'}(:)   =  0;
%
% Synchronize on disk
%
close(nc);
return


