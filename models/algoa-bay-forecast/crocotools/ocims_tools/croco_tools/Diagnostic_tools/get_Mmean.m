%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  get_Mmean: Get the mean for each month.
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
Ymin=6;
Ymax=10;
Mmin=1;
Mmax=12;
filetype='avg';
%
Yorig=nan; %nan: climatolgy run%
%
% CROCO files
%
infile=[directory,model,'_',filetype,'_Y',num2str(Ymin),'M',num2str(Mmax),'.nc'];
outfile=[directory,model,'_Mmean.nc'];
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Create the file
%
eval(['! ',DIAG_dir,'copycdf.csh ',infile,' ',outfile,' "CROCO monthly mean file"'])
%
% Initialisation
%
nc=netcdf(infile);
Lm=length(nc('xi_rho'));
Mm=length(nc('eta_rho'));
Nm=length(nc('s_rho'));
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
% Initialisation
%
for i=1:n3dvars
  if N(i)==1
    eval(['m',char(varcell(i)),'=zeros(12,',...
              num2str(M(i)),',',num2str(L(i)),');'])
  else
    eval(['m',char(varcell(i)),'=zeros(12,',num2str(N(i)),...
          ',',num2str(M(i)),',',num2str(L(i)),');'])
  end
end
nstep=0*(1:12);
%
%
%
for Y=Ymin:Ymax
  if Y==Ymin 
    mo_min=Mmin;
  else
    mo_min=1;
  end
  if Y==Ymax
    mo_max=Mmax;
  else
    mo_max=12;
  end  
  for M=mo_min:mo_max
    fname=[directory,model,'_',filetype,'_Y',num2str(Y),'M',num2str(M),'.nc'];
    disp(['Opening : ',fname])
    nc=netcdf(fname);
    ntime=length(nc('time'));
    if (filetype=='his' & ~(Y==Ymin & M==Mmin))
      nstart=2;
    else
      nstart=1;
    end
%
% loop on the time indexes in the file 
%
    for tindex=nstart:ntime
      [day,month,year,imonth,thedate]=get_date(fname,tindex,Yorig);
      nstep(imonth)=nstep(imonth)+1;
      for i=1:n3dvars
        if N(i)==1
          eval(['m',char(varcell(i)),'(imonth,:,:)=squeeze(m',char(varcell(i)),...
	        '(imonth,:,:))+nc{''',char(varcell(i)),'''}(tindex,:,:);'])		
        else
	  
          eval(['m',char(varcell(i)),'(imonth,:,:,:)= squeeze(m',char(varcell(i)),...
	        '(imonth,:,:,:))+nc{''',char(varcell(i)),'''}(tindex,:,:,:);'])
        end
      end
    end
    close(nc)
  end
end
%
% Write it down
%
disp('Write in the file...')
nc=netcdf(outfile,'write');
if rutgers==1
  nc{'theta_s'}(:)=theta_s;
  nc{'theta_b'}(:)=theta_b;
  nc{'Tcline'}(:)=Tcline;
end
for imonth=1:12
  cff=1/nstep(imonth);
  if rutgers==1
    nc{'ocean_time'}(imonth)=(imonth-0.5)*30*24*3600;
  else
    nc{'scrum_time'}(imonth)=(imonth-0.5)*30*24*3600;
  end
  for i=1:n3dvars
    if N(i)==1
      eval(['nc{''',char(varcell(i)),'''}(imonth,:,:)=cff*squeeze(m',...
            char(varcell(i)),'(imonth,:,:));'])
    else
      eval(['nc{''',char(varcell(i)),'''}(imonth,:,:,:)=cff*squeeze(m',...
            char(varcell(i)),'(imonth,:,:,:));'])
    end
  end
end
close(nc)
