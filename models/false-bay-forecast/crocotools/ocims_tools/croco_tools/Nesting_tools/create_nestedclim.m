function ncclim=create_nestedclim(climfile,gridfile,parentfile,title,...
				  theta_s,theta_b,Tcline,N,...
				  ttime,stime,utime,vtime,sshtime,...
				  tcycle,scycle,ucycle,vcycle,sshcycle,...
                  tbiol, cbiol,tpisces,cpisces,...
                  clobber,...    
				  biol,pisces,timebiol,cyclebiol,timepisces,cyclepisce, ...
                  namebiol,namepisces,unitbiol,unitpisces,hc,vtransform)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function ncclim=create_climfile(climfile,gridfile,theta_s,...
%                  theta_b,Tcline,N,...
%            ttime,stime,utime,vtime,sshtime,...
%            tcycle,scycle,ucycle,vcycle,sshcycle,...
%                  clobber) 
%
%   This function create the header of a Netcdf climatology 
%   file.
%
%   Input: 
%
%   climfile     Netcdf climatology file name (character string)
%   gridfile     Netcdf grid file name (character string).
%   theta_s      S-coordinate surface control parameter.(Real)
%   theta_b      S-coordinate bottom control parameter.(Real)
%   Tcline       Width (m) of surface or bottom boundary layer
%                where higher vertical resolution is required 
%                during stretching.(Real)
%   N            Number of vertical levels.(Integer)
%   ttime        Temperature climatology time.(vector) 
%   stime        Salinity climatology time.(vector)
%   utime        Velocity climatology time.(vector)
%   cycle        Length (days) for cycling the climatology.(Real)
%   clobber      Switch to allow or not writing over an existing
%                file.(character string)
%
%   Output
%
%   ncclim       Output netcdf object.
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
disp(['Creating the file : ',climfile])
disp(' ')
%
%  Read the grid file
%
nc = netcdf(gridfile, 'nowrite');
h = nc{'h'}(:);
close(nc);
[Mp,Lp]=size(h);
L=Lp-1;
M=Mp-1;
Np=N+1;
%
%  Create the climatology file
%
type = 'CLIMATOLOGY file' ;
history = 'CROCO' ;
ncclim = netcdf(climfile,clobber);
result = redef(ncclim);
%
%  Create dimensions
%
ncclim('xi_u') = L;
ncclim('xi_v') = Lp;
ncclim('xi_rho') = Lp;
ncclim('eta_u') = Mp;
ncclim('eta_v') = M;
ncclim('eta_rho') = Mp;
ncclim('s_rho') = N;
ncclim('s_w') = Np;
ncclim('tracer') = 2;
ncclim('tclm_time') = size(ttime);
ncclim('sclm_time') = size(stime);
ncclim('uclm_time') = size(utime);
ncclim('vclm_time') = size(vtime);
ncclim('ssh_time') = size(sshtime);

if biol
    for k=1:length(timebiol)
       % disp(char(timebiol(k)))
        ncclim(char(timebiol(k))) = length(tbiol(k,:));
    end
end
%
if pisces
    for k=1:length(timepisces)
       % disp(char(timepisces(k)))
        ncclim(char(timepisces(k))) = length(tpisces(k,:));
    end
end
ncclim('one') = 1;
%
%  Create variables
%
ncclim{'spherical'} = ncchar('one') ;
ncclim{'Vtransform'} = ncint('one') ;
ncclim{'tstart'} = ncdouble('one') ;
ncclim{'tend'} = ncdouble('one') ;
ncclim{'theta_s'} = ncdouble('one') ;
ncclim{'theta_b'} = ncdouble('one') ;
ncclim{'Tcline'} = ncdouble('one') ;
ncclim{'hc'} = ncdouble('one') ;
ncclim{'sc_r'} = ncdouble('s_rho') ;
ncclim{'Cs_r'} = ncdouble('s_rho') ;
ncclim{'tclm_time'} = ncdouble('tclm_time') ;
ncclim{'sclm_time'} = ncdouble('sclm_time') ;
ncclim{'uclm_time'} = ncdouble('uclm_time') ;
ncclim{'vclm_time'} = ncdouble('vclm_time') ;
ncclim{'ssh_time'} = ncdouble('ssh_time') ;
ncclim{'temp'} = ncdouble('tclm_time','s_rho','eta_rho','xi_rho') ;
ncclim{'salt'} = ncdouble('sclm_time','s_rho','eta_rho','xi_rho') ;
ncclim{'u'} = ncdouble('uclm_time','s_rho','eta_u','xi_u') ;
ncclim{'v'} = ncdouble('vclm_time','s_rho','eta_v','xi_v') ;
ncclim{'ubar'} = ncdouble('uclm_time','eta_u','xi_u') ;
ncclim{'vbar'} = ncdouble('vclm_time','eta_v','xi_v') ;
ncclim{'SSH'} = ncdouble('ssh_time','eta_rho','xi_rho') ;
%
%
%  Create attributes
%
ncclim{'Vtransform'}.long_name = ncchar('vertical terrain-following transformation equation');
ncclim{'Vtransform'}.long_name = 'vertical terrain-following transformation equation';
%
ncclim{'Vstretching'}.long_name = ncchar('vertical terrain-following stretching function');
ncclim{'Vstretching'}.long_name = 'vertical terrain-following stretching function';
%
ncclim{'tstart'}.long_name = ncchar('start processing day');
ncclim{'tstart'}.long_name = 'start processing day';
ncclim{'tstart'}.units = ncchar('day');
ncclim{'tstart'}.units = 'day';
%
ncclim{'tend'}.long_name = ncchar('end processing day');
ncclim{'tend'}.long_name = 'end processing day';
ncclim{'tend'}.units = ncchar('day');
ncclim{'tend'}.units = 'day';
%
ncclim{'theta_s'}.long_name = ncchar('S-coordinate surface control parameter');
ncclim{'theta_s'}.long_name = 'S-coordinate surface control parameter';
ncclim{'theta_s'}.units = ncchar('nondimensional');
ncclim{'theta_s'}.units = 'nondimensional';
%
ncclim{'theta_b'}.long_name = ncchar('S-coordinate bottom control parameter');
ncclim{'theta_b'}.long_name = 'S-coordinate bottom control parameter';
ncclim{'theta_b'}.units = ncchar('nondimensional');
ncclim{'theta_b'}.units = 'nondimensional';
%
ncclim{'Tcline'}.long_name = ncchar('S-coordinate surface/bottom layer width');
ncclim{'Tcline'}.long_name = 'S-coordinate surface/bottom layer width';
ncclim{'Tcline'}.units = ncchar('meter');
ncclim{'Tcline'}.units = 'meter';
%
ncclim{'hc'}.long_name = ncchar('S-coordinate parameter, critical depth');
ncclim{'hc'}.long_name = 'S-coordinate parameter, critical depth';
ncclim{'hc'}.units = ncchar('meter');
ncclim{'hc'}.units = 'meter';
%
ncclim{'sc_r'}.long_name = ncchar('S-coordinate at RHO-points');
ncclim{'sc_r'}.long_name = 'S-coordinate at RHO-points';
ncclim{'sc_r'}.units = ncchar('nondimensional');
ncclim{'sc_r'}.units = 'nondimensional';
ncclim{'sc_r'}.valid_min = -1;
ncclim{'sc_r'}.valid_max = 0;
ncclim{'sc_r'}.field = ncchar('sc_r, scalar');
ncclim{'sc_r'}.field = 'sc_r, scalar';
%
ncclim{'Cs_r'}.long_name = ncchar('S-coordinate stretching curves at RHO-points');
ncclim{'Cs_r'}.long_name = 'S-coordinate stretching curves at RHO-points';
ncclim{'Cs_r'}.units = ncchar('nondimensional');
ncclim{'Cs_r'}.units = 'nondimensional';
ncclim{'Cs_r'}.valid_min = -1;
ncclim{'Cs_r'}.valid_max = 0;
ncclim{'Cs_r'}.field = ncchar('Cs_r, scalar');
ncclim{'Cs_r'}.field = 'Cs_r, scalar';
%
ncclim{'tclm_time'}.long_name = ncchar('time for temperature climatology');
ncclim{'tclm_time'}.long_name = 'time for temperature climatology';
ncclim{'tclm_time'}.units = ncchar('day');
ncclim{'tclm_time'}.units = 'day';
ncclim{'tclm_time'}.cycle_length = tcycle;
ncclim{'tclm_time'}.field = ncchar('tclm_time, scalar, series');
ncclim{'tclm_time'}.field = 'tclm_time, scalar, series'  ;
%
ncclim{'sclm_time'}.long_name = ncchar('time for salinity climatology');
ncclim{'sclm_time'}.long_name = 'time for salinity climatology';
ncclim{'sclm_time'}.units = ncchar('day');
ncclim{'sclm_time'}.units = 'day';
ncclim{'sclm_time'}.cycle_length = scycle;
ncclim{'sclm_time'}.field = ncchar('sclm_time, scalar, serie');
ncclim{'sclm_time'}.field = 'sclm_time, scalar, serie';
%
ncclim{'uclm_time'}.long_name = ncchar('time climatological u');
ncclim{'uclm_time'}.long_name = 'time climatological u';
ncclim{'uclm_time'}.units = ncchar('day');
ncclim{'uclm_time'}.units = 'day';
ncclim{'uclm_time'}.cycle_length = ucycle;
ncclim{'uclm_time'}.field = ncchar('uclm_time, scalar, serie');
ncclim{'uclm_time'}.field = 'uclm_time, scalar, serie';
%
ncclim{'vclm_time'}.long_name = ncchar('time climatological v');
ncclim{'vclm_time'}.long_name = 'time climatological v';
ncclim{'vclm_time'}.units = ncchar('day');
ncclim{'vclm_time'}.units = 'day';
ncclim{'vclm_time'}.cycle_length = vcycle;
ncclim{'vclm_time'}.field = ncchar('vclm_time, scalar, serie');
ncclim{'vclm_time'}.field = 'vclm_time, scalar, serie';
%
ncclim{'ssh_time'}.long_name = ncchar('time for sea surface height');
ncclim{'ssh_time'}.long_name = 'time for sea surface height';
ncclim{'ssh_time'}.units = ncchar('day');
ncclim{'ssh_time'}.units = 'day';
ncclim{'ssh_time'}.cycle_length = sshcycle;
ncclim{'ssh_time'}.field = ncchar('ssh_time, scalar, serie');
ncclim{'ssh_time'}.field = 'ssh_time, scalar, serie';
%
if biol
    for k=1:length(timebiol)
       % disp(char(timebiol(k)))
        ncclim{char(timebiol(k))} = ncdouble(char(timebiol(k,:)));
        ncclim{char(timebiol(k))}.long_name = ncchar(char(timebiol(k)));
        ncclim{char(timebiol(k))}.long_name = char(timebiol(k));
        ncclim{char(timebiol(k))}.units = ncchar('day');
        ncclim{char(timebiol(k))}.units = 'day';
        ncclim{char(timebiol(k))}.cycle_length = char(timebiol(k));
        ncclim{char(timebiol(k))}.field = ncchar([char(timebiol(k)),', scalar, series']);
        ncclim{char(timebiol(k))}.field = [char(timebiol(k)),', scalar, series']  ;
%     
       % disp(char(namebiol(k)))
        ncclim{char(namebiol(k))} = ncdouble(char(timebiol(k,:)),'s_rho','eta_rho','xi_rho');
        ncclim{char(namebiol(k))}.long_name = ncchar(char(namebiol(k)));
        ncclim{char(namebiol(k))}.long_name = char(namebiol(k));
        ncclim{char(namebiol(k))}.units = ncchar(char(unitbiol(k)));
        ncclim{char(namebiol(k))}.units = char(unitbiol(k));
        ncclim{char(namebiol(k))}.field = ncchar([char(namebiol(k)),', scalar, series']);
        ncclim{char(namebiol(k))}.field = [char(namebiol(k)),', scalar, series'];
        %
        %disp('Done')
    end
end
%
if pisces
    for k=1:length(timepisces)
        %disp(char(timepisces(k)))
        ncclim{char(timepisces(k))} = ncdouble(char(timepisces(k,:)));
        ncclim{char(timepisces(k))}.long_name = ncchar(char(timepisces(k)));
        ncclim{char(timepisces(k))}.long_name = char(timepisces(k));
        ncclim{char(timepisces(k))}.units = ncchar('day');
        ncclim{char(timepisces(k))}.units = 'day';
        ncclim{char(timepisces(k))}.cycle_length = ncchar([char(namepisces(k)),', scalar, series']);
        ncclim{char(timepisces(k))}.field = ncchar([char(timepisces(k)), ',scalar, series']);
        ncclim{char(timepisces(k))}.field = [char(timepisces(k)), ',scalar, series']  ;
        %
        %disp(char(namepisces(k)))
        ncclim{char(namepisces(k))} = ncdouble(char(timepisces(k,:)),'s_rho','eta_rho','xi_rho');
        ncclim{char(namepisces(k))}.long_name = ncchar(char(namepisces(k)));
        ncclim{char(namepisces(k))}.long_name = char(namepisces(k));
        ncclim{char(namepisces(k))}.units = ncchar(char(unitpisces(k)));
        ncclim{char(namepisces(k))}.units = char(unitpisces(k));
        ncclim{char(namepisces(k))}.field = ncchar([char(namepisces(k)),', scalar, series']);
        ncclim{char(namepisces(k))}.field = [char(namepisces(k)),', scalar, series'];     
    end
end

%
% Create global attributes
%
ncclim.title = ncchar(title);
ncclim.title = title;
ncclim.date = ncchar(date);
ncclim.date = date;
ncclim.clim_file = ncchar(climfile);
ncclim.clim_file = climfile;
ncclim.grd_file = ncchar(gridfile);
ncclim.grd_file = gridfile;
ncclim.parent_file = ncchar(parentfile);
ncclim.parent_file = parentfile;
ncclim.type = ncchar(type);
ncclim.type = type;
ncclim.history = ncchar(history);
ncclim.history = history;
%
% Leave define mode
%
result = endef(ncclim);
%
[sc_r,Cs_r,sc_w,Cs_w] = scoordinate(theta_s,theta_b,N,hc,vtransform);
%
% Write variables
%
ncclim{'spherical'}(:)='T';
ncclim{'Vtransform'}(:)=vtransform;
ncclim{'tstart'}(:) =  min([min(ttime) min(stime) min(utime)]);
ncclim{'tend'}(:) =  max([max(ttime) max(stime) max(utime)]);
ncclim{'theta_s'}(:) =  theta_s;
ncclim{'theta_b'}(:) =  theta_b;
ncclim{'Tcline'}(:) =  Tcline;
ncclim{'hc'}(:) =  hc;
ncclim{'sc_r'}(:) =  sc_r;
ncclim{'Cs_r'}(:) =  Cs_r;
ncclim{'tclm_time'}(:) =  ttime;
ncclim{'sclm_time'}(:) =  stime;
ncclim{'uclm_time'}(:) = utime ;
ncclim{'vclm_time'}(:) = vtime ;
ncclim{'ssh_time'}(:) = sshtime;
ncclim{'u'}(:) =  0;
ncclim{'v'}(:) =  0;
ncclim{'ubar'}(:) =  0;
ncclim{'vbar'}(:) =  0;
ncclim{'SSH'}(:) =  0;
ncclim{'temp'}(:) =  0;
ncclim{'salt'}(:) =  0;
%
if biol
   % disp('Write variable biology')
    for k=1:length(namebiol)
        eval(['ncclim{''',char(timebiol(k)),'''}(:)=squeeze(tbiol(k,:));']);
    end
    for k=1:length(namebiol)
        ncclim{char(namebiol(k))}(:)=0;
    end
end

%
if pisces
   % disp('Write variable pisces')
    for k=1:length(namepisces)
        eval(['ncclim{''',char(timepisces(k)),'''}(:)=squeeze(tpisces(k,:));']);
    end
    for k=1:length(namepisces)
        ncclim{char(namepisces(k))}(:)=0;
    end
end
%
%
% Synchronize on disk
%
sync(ncclim);
return


