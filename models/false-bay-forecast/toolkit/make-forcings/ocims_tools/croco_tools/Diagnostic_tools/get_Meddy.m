%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  get_Meddy: Get the variance for each month.
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
Ymin=4;
Ymax=10;
Mmin=1;
Mmax=12;
filetype='avg';
nonseannal=0; % 1: compute a "non-seasonnal" mean 
%                 (i.e. remove the monthly instead of the annual mean to
%                  get the anomalies)
%
Yorig=nan; %nan: climatolgy run%
%
% CROCO files
%
avgfile=[directory,model,'_',filetype,'_Y',num2str(Ymin),'M',num2str(Mmax),'.nc'];
if nonseannal==0
  eddyfile=[directory,model,'_Meddy.nc'];
  meanfile=[directory,model,'_Smean.nc'];
else
  eddyfile=[directory,model,'_Meddy_ns.nc'];
  meanfile=[directory,model,'_Mmean.nc'];
end
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Create the file
%
eval(['! ',DIAG_dir,'copycdf.csh ',avgfile,' ',eddyfile,' "CROCO monthly eddy file"'])
%
% Initialisation
%
nc=netcdf(avgfile);
L=length(nc('xi_rho'));
M=length(nc('eta_rho'));
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
% Initialisation
%
for i=1:n3dvars
  if N(i)==1
    eval(['m',char(varcell(i)),'2=zeros(12,',...
              num2str(M(i)),',',num2str(L(i)),');'])
  else
    eval(['m',char(varcell(i)),'2=zeros(12,',num2str(N(i)),...
          ',',num2str(M(i)),',',num2str(L(i)),');'])
  end
end
nstep=0*(1:12);
%
%
%
nmean=netcdf(meanfile);
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
      if nonseannal==0
        avgindex=5;
      else
        avgindex=imonth;
      end
      nstep(imonth)=nstep(imonth)+1;
      for i=1:n3dvars
        if N(i)==1
          eval(['m',char(varcell(i)),'2(imonth,:,:)=squeeze(m',char(varcell(i)),...
	        '2(imonth,:,:))+((nc{''',char(varcell(i)),'''}(tindex,:,:)-nmean{''',...
		char(varcell(i)),'''}(avgindex,:,:)).^2);'])		
        else
          eval(['m',char(varcell(i)),'2(imonth,:,:,:)=squeeze(m',char(varcell(i)),...
	        '2(imonth,:,:,:))+((nc{''',char(varcell(i)),'''}(tindex,:,:,:)-nmean{''',...
		char(varcell(i)),'''}(avgindex,:,:,:)).^2);'])		
        end
      end
    end
    close(nc)
  end
end
close(nmean);
%
% Write it down
%
disp('Write in the file...')
nc=netcdf(eddyfile,'write');
if rutgers==1
  nc{'theta_s'}(:)=theta_s;
  nc{'theta_b'}(:)=theta_b;
  nc{'Tcline'}(:)=Tcline;
end
for imonth=1:12
  cff=1./nstep(imonth);
  if rutgers==1
    nc{'ocean_time'}(imonth)=(imonth-0.5)*30*24*3600;
  else
    nc{'scrum_time'}(imonth)=(imonth-0.5)*30*24*3600;
  end
  for i=1:n3dvars
    if N(i)==1
      eval(['nc{''',char(varcell(i)),'''}(imonth,:,:)=cff*squeeze(m',...
            char(varcell(i)),'2(imonth,:,:));'])
    else
      eval(['nc{''',char(varcell(i)),'''}(imonth,:,:,:)=cff*squeeze(m',...
            char(varcell(i)),'2(imonth,:,:,:));'])
    end
  end
end
close(nc)
