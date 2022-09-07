%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get averaged quantities from a CROCO simulation.
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    10-Sep-2006 by Pierrick Penven
%  Updated    24-Oct-2006 by Pierrick Penven (Generalization to all tracers)
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
filetype='avg';  % 'his' or 'avg'
Ymin=1;
Ymax=10;
Mmin=1;
Mmax=12;
dataname='croco.mat';
rempts=[2 2 2 2]; % Remove .. points from the boundary 
z0=-300; % compute average above z0
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
nc=netcdf([directory,model,'_',filetype,'_Y',num2str(Ymin),'M',num2str(Mmin),'.nc']);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
mask=nc{'mask_rho'}(:);
N=length(nc('s_rho'));
pm=rempoints(pm,rempts);
pn=rempoints(pn,rempts);
mask=rempoints(mask,rempts);
[M,L]=size(pm);
ds2d=mask./(pm.*pn);
S=sum(sum(ds2d));
ds=reshape(ds2d,1,M,L);
ds=repmat(ds,[N 1 1]);
mask3d=reshape(mask,1,M,L);
mask3d=repmat(mask3d,[N 1 1]);
%
[n3dvars,varcell,L1,M1,N1]=get_3dvars(nc);
L1=L1-rempts(1)-rempts(2);
M1=M1-rempts(3)-rempts(4);
%
close(nc)
%
% Loop on the files...
%
tndx=0;
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
  for Mo=mo_min:mo_max
    fname=[directory,model,'_',filetype,'_Y',num2str(Y),'M',num2str(Mo),'.nc'];
    disp(['Opening : ',fname])
    nc=netcdf(fname);
    if isempty(nc)
      disp(['Could ont open : ',fname])
    else
      ntime=length(nc('time'));
      if (filetype=='his' & ~(Y==Ymin & Mo==Mmin))
        nstart=2;
      else
        nstart=1;
      end
      scrumtime=nc{'scrum_time'}(:);
%
% loop on the time indexes in the file 
%
      for n=nstart:ntime
        tndx=tndx+1;
        disp(['Processing time index ',num2str(tndx)])
%
% Get the vertical grid
%
        zw=get_depths(fname,fname,n,'w');
	zw=zw(:,rempts(3)+1:end-rempts(4),rempts(1)+1:end-rempts(2));
        dz=zw(2:end,:,:)-zw(1:end-1,:,:);
        zr=get_depths(fname,fname,n,'r');
	zr=zr(:,rempts(3)+1:end-rempts(4),rempts(1)+1:end-rempts(2));
%
%  Remove depths > z0
%
        dz0=dz;
        dz0(zr<z0)=0;	
%
% 1: Volume
%
	dvz0=mask3d.*ds.*dz0;
	Vz0=sum(sum(sum(dvz0)));
        dv=mask3d.*ds.*dz;
        V(tndx)=sum(sum(sum(dv)));
%
% 2: Kinetic Energy
%
        var=(u2rho_3d(nc{'u'}(n,:,:,:))).^2 ...
          +(v2rho_3d(nc{'v'}(n,:,:,:))).^2;
        var=var(:,rempts(3)+1:end-rempts(4),rempts(1)+1:end-rempts(2));
        avgke(tndx)=sum(sum(sum(var.*dv)))/V(tndx);
        surfke(tndx)=sum(sum(squeeze(var(N,:,:)).*ds2d))/S;
%
% 3: SSH
%
        var=squeeze(nc{'zeta'}(n,:,:));
        var=var(rempts(3)+1:end-rempts(4),rempts(1)+1:end-rempts(2));
        avgzeta(tndx)=sum(sum(var.*ds2d))/S;
        time(tndx)=scrumtime(n);
%
% 4: Tracers (any 3D variable at rho points).
%
        for i=1:n3dvars
          if N1(i)==N & M1(i)==M & L1(i)==L
	    eval(['[avg',char(varcell(i)),'(tndx),avgz0',char(varcell(i)),...
	   '(tndx),surf',char(varcell(i)),'(tndx)]=get_avgtracer(nc,''',...
	         char(varcell(i)),''',n,rempts,dv,V(tndx),dvz0,Vz0,N,ds2d,S);']);	
          end
        end
      end
      close(nc)
    end
  end
end
%
% SAVE the timeseries in a .mat file
%
cmd='save(dataname,''nvars'',''varnames'',''time'',''V'',''avgzeta'',''avgke'',''surfke''';
cmd2='varnames={';
nvars=0;
for i=1:n3dvars
   if N1(i)==N & M1(i)==M & L1(i)==L
     nvars=nvars+1;
     eval(['cmd2=[cmd2,''''''',char(varcell(i)),''''' ''];'])
     eval(['cmd=[cmd,'',''''avg',char(varcell(i)),...
                ''''',''''avgz0',char(varcell(i)),...
                 ''''',''''surf',char(varcell(i)),'''''''];'])
   end
end
cmd2=[cmd2,'};'];
eval(cmd2)
cmd=[cmd,');'];
eval(cmd)

