function add_ini_pisces(inifile,clobber)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2000 IRD                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                 %
%                                                                 %
%  function nc=add_ini_pisces(inifile,clobber)                    %
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
%   Pierrick Penven, IRD, 2005.                                   %
%   Olivier Aumont, IRD, 2006.                                    %
%   Patricio Marchesiello, IRD 2007                               %
%   Christophe Eugene Raoul Menkes, IRD 2007                      %
%                                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Adding PISCES data in file : ',inifile])
%
%  Create the initial file
%
nc = netcdf(inifile,clobber);
%%result = redef(nc);
%
%  Create variables
%
nc{'NO3'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'PO4'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'Si'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'O2'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'DIC'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'TALK'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'DOC'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
nc{'FER'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;

%
%  Create attributes
%
nc{'NO3'}.long_name = ncchar('NO3');
nc{'NO3'}.long_name = 'NO3';
nc{'NO3'}.units = ncchar('mMol N m-3');
nc{'NO3'}.units = 'mMol N m-3';
%
%
nc{'PO4'}.long_name = ncchar('PO4');
nc{'PO4'}.long_name = 'PO4';
nc{'PO4'}.units = ncchar('mMol P m-3');
nc{'PO4'}.units = 'mMol P m-3';
%
%
nc{'Si'}.long_name = ncchar('Si');
nc{'Si'}.long_name = 'Si';
nc{'Si'}.units = ncchar('mMol Si m-3');
nc{'Si'}.units = 'mMol Si m-3';
%
%
nc{'O2'}.long_name = ncchar('O2');
nc{'O2'}.long_name = 'O2';
nc{'O2'}.units = ncchar('mMol O m-3');
nc{'O2'}.units = 'mMol O m-3';
%
%
nc{'DIC'}.long_name = ncchar('DIC');
nc{'DIC'}.long_name = 'DIC';
nc{'DIC'}.units = ncchar('mMol C m-3');
nc{'DIC'}.units = 'mMol C m-3';
%
%
nc{'TALK'}.long_name = ncchar('TALK');
nc{'TALK'}.long_name = 'TALK';
nc{'TALK'}.units = ncchar('mMol C m-3');
nc{'TALK'}.units = 'mMol C m-3';
%
%
nc{'DOC'}.long_name = ncchar('DOC');
nc{'DOC'}.long_name = 'DOC';
nc{'DOC'}.units = ncchar('mMol C m-3');
nc{'DOC'}.units = 'mMol C m-3';
%
%
nc{'FER'}.long_name = ncchar('FER');
nc{'FER'}.long_name = 'FER';
nc{'FER'}.units = ncchar('mMol Fe m-3');
nc{'FER'}.units = 'mMol Fe m-3';
%
% Leave define mode
%
%%result = endef(nc);
%
% Write variables
%
nc{'NO3'}(:)  =  0;
nc{'PO4'}(:)  =  0;
nc{'Si'}(:) =  0;
nc{'O2'}(:)   =  0;
nc{'DIC'}(:)  =  0;
nc{'TALK'}(:) =  0;
nc{'DOC'}(:)  =  0;
nc{'FER'}(:)  =  0;
%
% Synchronize on disk
%
close(nc);
return


