%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the seasonnal and annual mean.
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
%  Copyright (c) 2005-2006 by Patrick Marchesiello and Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    10-Sep-2006 by Pierrick Penven
%  Updated    24-Oct-2006 by Pierrick Penven (generalisation to all CROCO
%                                             variables)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
% Directory and file names
%
directory=[RUN_dir,'SCRATCH/'];
model='croco';
%
% CROCO files
%
infile=[directory,model,'_Mmean.nc'];
outfile=[directory,model,'_Smean.nc'];
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Create the file
%
eval(['! ',DIAG_dir,'copycdf.csh ',infile,' ',outfile,' "CROCO seasonnal mean file"'])
%
% Initialisation
%
nc=netcdf(infile);
Lm=length(nc('xi_rho'));
Mm=length(nc('eta_rho'));
N=length(nc('s_rho'));
theta_s=nc.theta_s(:);
rutgers=0;
if (isempty(theta_s))
%  disp('Rutgers version')
  rutgers=1;   
  theta_s=nc{'theta_s'}(:);
  theta_b=nc{'theta_b'}(:);
  Tcline=nc{'Tcline'}(:);
end
[n3dvars,varcell,L,M,N]=get_3dvars(nc);
close(nc);
%
%
%
disp(['Opening : ',infile])
nc=netcdf(infile);
nw=netcdf(outfile,'write');
if rutgers==1
  nw{'theta_s'}(:)=theta_s;
  nw{'theta_b'}(:)=theta_b;
  nw{'Tcline'}(:)=Tcline;
end
%
% loop on the seasons
%
for season=1:5
  disp(['Computing season : ',num2str(season)])
  if season < 5 
    months=[3*season-2:3*season];
  else
    months=(1:12);
  end
  cff=1/(length(months));
  if rutgers==1
    nw{'ocean_time'}(season)=cff*sum(nc{'ocean_time'}(months));
  else
    nw{'scrum_time'}(season)=cff*sum(nc{'scrum_time'}(months));
  end
  for i=1:n3dvars
    if N(i)==1
      eval(['nw{''',char(varcell(i)),'''}(season,:,:)=cff*sum(nc{''',...
            char(varcell(i)),'''}(months,:,:));'])
    else
      eval(['nw{''',char(varcell(i)),'''}(season,:,:,:)=cff*sum(nc{''',...
            char(varcell(i)),'''}(months,:,:,:));'])
    
    end
  end
end
close(nc)
close(nw)

