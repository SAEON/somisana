function ncrst=create_nestedrestart(rstfile,gridfile,parentfile,title,clobber,...
				    biol,pisces,namebiol,namepisces,unitbiol,unitpisces,hc,vtransform)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function ncrst=create_nestedrestart(rstfile,gridfile,parentfile,...
%                                      title,clobber)
%
%   This function create the header of a Netcdf initial 
%   file.
%
%   Input: 
%
%   rstfile     Netcdf restart file name (character string)
%   gridfile    Netcdf grid file name (character string).
%   parentfile  Netcdf parent restart file name (character string).
%   clobber      Switch to allow or not writing over an existing
%                file.(character string)
%
%   Output
%
%   ncrst       Output netcdf object.
% 
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp(' ')
%biol
%pisces
%namebiol
%namepisces
%unitbiol
%unitpisces

disp(['Creating the file : ',rstfile])
disp(' ')
%
%  Open the grid file
%
ncgrd = netcdf(gridfile,'nowrite');
%
%  Open the parent file
%
ncprt=netcdf(parentfile,'nowrite');
%
%  Create the restart file
%
type = 'restart file' ; 
history = 'CROCO' ;
ncrst = netcdf(rstfile,clobber);
result = redef(ncrst);

%
%  Create dimensions
%
ncrst('xi_u') = length(ncgrd('xi_u'));
ncrst('xi_rho') = length(ncgrd('xi_rho'));
ncrst('eta_v') = length(ncgrd('eta_v'));
ncrst('eta_rho') = length(ncgrd('eta_rho'));
ncrst('s_rho') = length(ncprt('s_rho'));
ncrst('s_w') = length(ncprt('s_w'));
ncrst('one') = 1;
ncrst('auxil')  = 4 ;
ncrst('time') = 0;
ncrst('one') = 1;
%
%  Create variables
%
ncrst{'spherical'} = ncchar('one');
ncrst{'el'} = ncdouble('one');
ncrst{'xl'} = ncdouble('one');
% ncrst{'xi_rho'} = ncdouble('xi_rho');
% ncrst{'xi_u'} = ncdouble('xi_u');
% ncrst{'eta_rho'} = ncdouble('eta_rho');
% ncrst{'eta_v'} = ncdouble('eta_v');
ncrst{'Vtransform'} =ncdouble('one');
ncrst{'h'} = ncdouble('eta_rho','xi_rho');
ncrst{'f'} = ncdouble('eta_rho','xi_rho');
ncrst{'pm'} = ncdouble('eta_rho','xi_rho');
ncrst{'pn'} = ncdouble('eta_rho','xi_rho');
ncrst{'lon_rho'} = ncdouble('eta_rho','xi_rho');
ncrst{'lat_rho'} = ncdouble('eta_rho','xi_rho');
ncrst{'angle'} = ncdouble('eta_rho','xi_rho');
ncrst{'mask_rho'} = ncdouble('eta_rho','xi_rho');
ncrst{'time_step'} = ncint('time','auxil');
ncrst{'scrum_time'} = ncdouble('time');
ncrst{'u'} = ncdouble('time','s_rho','eta_rho','xi_u');
ncrst{'v'} = ncdouble('time','s_rho','eta_v','xi_rho');
ncrst{'ubar'} = ncdouble('time','eta_rho','xi_u');
ncrst{'vbar'} = ncdouble('time','eta_v','xi_rho');
ncrst{'zeta'} = ncdouble('time','eta_rho','xi_rho');
ncrst{'temp'} = ncdouble('time','s_rho','eta_rho','xi_rho');
ncrst{'salt'} = ncdouble('time','s_rho','eta_rho','xi_rho');
%
%
if biol == 1
    for k=1:length(namebiol)
        ncrst{char(namebiol(k))}= ncdouble('time','s_rho','eta_rho','xi_rho');
    end
end
if pisces ==1
  for k=1:length(namepisces)
    ncrst{char(namepisces(k))}= ncdouble('time','s_rho','eta_rho','xi_rho');
  end
end
%
%  Create attributes
%
ncrst{'spherical'}.long_name = ncchar('grid type logical switch');
ncrst{'spherical'}.long_name = 'grid type logical switch';
%

ncrst{'xl'}.long_name = ncchar('domain length in the XI-direction');
ncrst{'xl'}.long_name = 'domain length in the XI-direction';
ncrst{'xl'}.units = ncchar('meter');
ncrst{'xl'}.units = 'meter';
%
ncrst{'el'}.long_name = ncchar('domain length in the ETA-direction');
ncrst{'el'}.long_name = 'domain length in the ETA-direction';
ncrst{'el'}.units = ncchar('meter');
ncrst{'el'}.units = 'meter';
%
% ncrst{'xi_rho'}.long_name = ncchar('x-dimension of the grid');
% ncrst{'xi_rho'}.long_name = 'x-dimension of the grid';
% ncrst{'xi_rho'}.standard_name = 'x_grid_index_at_u_location' ;
% %
% ncrst{'xi_u'}.long_name = ncchar('x-dimension of the grid at u location');
% ncrst{'xi_u'}.long_name = 'x-dimension of the grid at u location';
% ncrst{'xi_u'}.standard_name = 'x_grid_index_at_u_location' ;
% %
% ncrst{'eta_rho'}.long_name = ncchar('y-dimension of the grid');
% ncrst{'eta_rho'}.long_name = 'y-dimension of the grid';
% ncrst{'eta_rho'}.standard_name = 'x_grid_index_at_v_location'
% %
% ncrst{'eta_v'}.long_name = ncchar('y-dimension of the grid at v location');
% ncrst{'eta_v'}.long_name = 'y-dimension of the grid at v location';
% ncrst{'eta_v'}.standard_name = 'x_grid_index_at_v_location';
%
ncrst{'Vtransform'}.long_name = ncchar('vertical terrain-following transformation equation');
ncrst{'Vtransform'}.long_name = 'vertical terrain-following transformation equation';
%
ncrst{'h'}.long_name = ncchar('bathymetry at RHO-points');
ncrst{'h'}.long_name = 'bathymetry at RHO-points';
ncrst{'h'}.units = ncchar('meter');
ncrst{'h'}.units = 'meter';
%
ncrst{'f'}.long_name = ncchar('Coriolis parameter at RHO-points');
ncrst{'f'}.long_name = 'Coriolis parameter at RHO-points';
ncrst{'f'}.units = ncchar('second-1');
ncrst{'f'}.units = 'second-1';
%
ncrst{'pm'}.long_name = ncchar('curvilinear coordinate metric in XI');
ncrst{'pm'}.long_name = 'curvilinear coordinate metric in XI';
ncrst{'pm'}.units = ncchar('meter-1');
ncrst{'pm'}.units = 'meter-1';
%
ncrst{'pn'}.long_name = ncchar('curvilinear coordinate metric in ETA');
ncrst{'pn'}.long_name = 'curvilinear coordinate metric in ETA';
ncrst{'pn'}.units = ncchar('meter-1');
ncrst{'pn'}.units = 'meter-1';
%
ncrst{'lon_rho'}.long_name = ncchar('longitude of RHO-points');
ncrst{'lon_rho'}.long_name = 'longitude of RHO-points';
ncrst{'lon_rho'}.units = ncchar('degree_east');
ncrst{'lon_rho'}.units = 'degree_east';
%
ncrst{'lat_rho'}.long_name = ncchar('latitude of RHO-points');
ncrst{'lat_rho'}.long_name = 'latitude of RHO-points';
ncrst{'lat_rho'}.units = ncchar('degree_north');
ncrst{'lat_rho'}.units = 'degree_north';
%
ncrst{'angle'}.long_name = ncchar('angle between XI-axis and EAST');
ncrst{'angle'}.long_name = 'angle between XI-axis and EAST';
ncrst{'angle'}.units = ncchar('radians');
ncrst{'angle'}.units = 'radians';
%
ncrst{'mask_rho'}.long_name = ncchar('mask on RHO-points');
ncrst{'mask_rho'}.long_name = 'mask on RHO-points';
%
ncrst{'time_step'}.long_name = ncchar('time step and record numbers from initialization');
ncrst{'time_step'}.long_name = 'time step and record numbers from initialization';
%
ncrst{'scrum_time'}.long_name = ncchar('time since intialization');
ncrst{'scrum_time'}.long_name = 'time since intialization';
ncrst{'scrum_time'}.units = ncchar('second');
ncrst{'scrum_time'}.units = 'second';
%
ncrst{'u'}.long_name = ncchar('u-momentum component');
ncrst{'u'}.long_name = 'u-momentum component';
ncrst{'u'}.units = ncchar('meter second-1');
ncrst{'u'}.units = 'meter second-1';
%
ncrst{'v'}.long_name = ncchar('v-momentum component');
ncrst{'v'}.long_name = 'v-momentum component';
ncrst{'v'}.units = ncchar('meter second-1');
ncrst{'v'}.units = 'meter second-1';
%
ncrst{'ubar'}.long_name = ncchar('vertically integrated u-momentum component');
ncrst{'ubar'}.long_name = 'vertically integrated u-momentum component';
ncrst{'ubar'}.units = ncchar('meter second-1');
ncrst{'ubar'}.units = 'meter second-1';
%
ncrst{'vbar'}.long_name = ncchar('vertically integrated v-momentum component');
ncrst{'vbar'}.long_name = 'vertically integrated v-momentum component';
ncrst{'vbar'}.units = ncchar('meter second-1');
ncrst{'vbar'}.units = 'meter second-1';
%
ncrst{'zeta'}.long_name = ncchar('free-surface');
ncrst{'zeta'}.long_name = 'free-surface';
ncrst{'zeta'}.units = ncchar('meter');
ncrst{'zeta'}.units = 'meter';
%
ncrst{'temp'}.long_name = ncchar('potential temperature');
ncrst{'temp'}.long_name = 'potential temperature';
ncrst{'temp'}.units = ncchar('Celsius');
ncrst{'temp'}.units = 'Celsius';
%
ncrst{'salt'}.long_name = ncchar('salinity');
ncrst{'salt'}.long_name = 'salinity';
ncrst{'salt'}.units = ncchar('PSU');
ncrst{'salt'}.units = 'PSU';

%
if  biol == 1
  for k=1:length(namebiol)
    %disp(['K=',num2str(k)])
    ncrst{char(namebiol(k))}.long_name = ncchar(char(namebiol(k)));
    ncrst{char(namebiol(k))}.long_name = char(namebiol(k));
    ncrst{char(namebiol(k))}.units = ncchar(char(unitbiol(k)));
    ncrst{char(namebiol(k))}.units = char(unitbiol(k));
    ncrst{char(namebiol(k))}.field = ncchar([char(namebiol(k)),', scalar, series']);
    ncrst{char(namebiol(k))}.field = [char(namebiol(k)),', scalar, series'];
  end
end
%
if pisces ==1
  for k=1:length(namepisces)
    %disp(['K=',num2str(k)])
    ncrst{char(namepisces(k))}.long_name = ncchar(char(namepisces(k)));
    ncrst{char(namepisces(k))}.long_name = char(namepisces(k));
    ncrst{char(namepisces(k))}.units = ncchar(char(unitpisces(k)));
    ncrst{char(namepisces(k))}.units = char(unitpisces(k));
    ncrst{char(namepisces(k))}.field = ncchar([char(namepisces(k)),', scalar, series']);
    ncrst{char(namepisces(k))}.field = [char(namepisces(k)),', scalar, series'];
  end
end;
%
% Create global attributes
%
disp('Create global attribute')
ncrst.type = ncchar(type);
ncrst.type = type;
ncrst.title = ncchar(title);
ncrst.title = title;
ncrst.date = ncchar(date);
ncrst.date = date;
ncrst.rst_file = ncchar(rstfile);
ncrst.rst_file = rstfile;
ncrst.grd_file = ncchar(gridfile);
ncrst.grd_file = gridfile;
ncrst.parent_file = ncchar(parentfile);
ncrst.parent_file = parentfile;
ncrst.history = ncchar(history);
ncrst.history = history;
ncrst.creation_method = ncchar('Nestgui @ CROCOTOOLS');
ncrst.creation_method = 'Nestgui @ CROCOTOOLS';
%
% Get the vertical grid
%
disp('Get the vertical grid')
ncrst.theta_s=ncprt.theta_s(:);
ncrst.theta_b=ncprt.theta_b(:);
ncrst.hc=ncprt.hc(:);
ncrst.sc_w=ncprt.sc_w(:);
ncrst.Cs_w=ncprt.Cs_w(:);
ncrst.sc_r=ncprt.sc_r(:);
ncrst.Cs_r=ncprt.Cs_r(:);
ncrst.ntimes=ncprt.ntimes(:);
ncrst.ndtfast=ncprt.ndtfast(:);
ncrst.dt=ncprt.dt(:);
ncrst.dtfast=ncprt.dtfast(:);
ncrst.nwrt=ncprt.nwrt(:);
ncrst.visc2=ncprt.visc2(:);
ncrst.rdrg=ncprt.rdrg(:);
ncrst.rdrg2=ncprt.rdrg2(:);
ncrst.rho0=ncprt.rho0(:);
ncrst.gamma2=ncprt.gamma2(:);
ncrst.SRCS=ncprt.SRCS(:);
ncrst.CPPS=ncprt.CPPS(:);

%
% Leave define mode
%
result = endef(ncrst);
%
% Fill variables
%
ncrst{'spherical'}(:)=ncgrd{'spherical'}(:);
ncrst{'el'}(:)=ncgrd{'el'}(:);
ncrst{'xl'}(:)=ncgrd{'xl'}(:);
ncrst{'h'}(:)=ncgrd{'h'}(:);
ncrst{'f'}(:)=ncgrd{'f'}(:);
ncrst{'pm'}(:)=ncgrd{'pm'}(:);
ncrst{'pn'}(:)=ncgrd{'pn'}(:);
ncrst{'lon_rho'}(:)=ncgrd{'lon_rho'}(:);
ncrst{'lat_rho'}(:)=ncgrd{'lat_rho'}(:);
ncrst{'angle'}(:)=ncgrd{'angle'}(:);
ncrst{'mask_rho'}(:)=ncgrd{'mask_rho'}(:);
ncrst{'Vtransform'}(:)=vtransform;
%
% Synchronize on disk
%
sync(ncrst);
close(ncgrd);
close(ncprt);
return


