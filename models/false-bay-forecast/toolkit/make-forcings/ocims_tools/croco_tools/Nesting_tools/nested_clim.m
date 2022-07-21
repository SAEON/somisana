function nested_clim(child_grd,parent_clim,child_clim,...
                     vertical_correc,extrapmask,biol,bioebus,pisces)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the climatology of the embedded grid
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Check the number of variables in the clim parents file
a= netcdf(parent_clim);
Vars = var(a);
Varnames = [ncnames(Vars)];
nvar =length(Varnames);
%
namebiol={''};
unitbiol={''};
namepisces={''};
unitpisces={''};
timebiol=[]; cyclebiol=[];
timepisces=[];cyclepisces=[];
tbiol=[];cbiol=[];
tpisces=[];cpisces=[];


% Check type of clim file
%
if nvar <= 31
elseif (nvar <=  41 & biol)
    timebiol={'no3_time';'o2_time';'chla_time';'phyto_time';'zoo_time'};
    cyclebiol={'no3_cyle';'o2_cycle';'chla_cycle';'phyto_cycle';'zoo_cycle'};
    namebiol={'NO3';'O2';'CHLA';'PHYTO';'ZOO'};
    unitbiol={'mMol N m-3';'mMol O m-3';'mg C l-1';'mMol N m-3';'mMol N m-3'};
    %timebiol={'no3_time';'chla_time';'phyto_time';'zoo_time'};
    disp(['Compute Biogeochemical variables type NPZD : '])
    disp(['NChlPZD or N2ChlPZD2                     '])
    disp('==========================')
elseif (46 <= nvar <=47 & biobus)
    timebiol={'no3_time';'o2_time';'chla_time';'sphyto_time';'lphyto_time';'szoo_time';'lzoo_time';'n2o_time'};
    cyclebiol={'no3_cyle';'o2_cycle';'chla_cycle';'sphyto_cycle';'lphyto_cycle';'szoo_cycle';'lzoo_cycle';'n2o_cycle'};
    namebiol={'NO3';'O2';'CHLA';'SPHYTO';'LPHYTO';'SZOO';'LZOO';'N2O'};
    unitbiol={'mMol N m-3';'mMol O m-3';'mg C l-1';'mMol N m-3';'mMol N m-3';'mMol N m-3';'mMol N m-3';'mMol N m-3'};
    disp(['Compute Biological variables for BIOEBUS : '])
    disp('==========================')
elseif (pisces & nvar>=47)
    timepisces={'no3_time';'po4_time';'si_time';'o2_time';'dic_time';'talk_time';'doc_time';'fer_time'};
    cyclepisces={'no3_cycle';'po4_cycle';'si_cycle';'o2_cycle';'dic_cycle';'talk_cycle';'doc_cycle';'fer_cycle'};
    namepisces={'NO3';'PO4';'Si';'O2';'DIC';'TALK';'DOC';'FER'};
    unitpisces={'mMol N m-3';'mMol P m-3';'mMol Si m-3';'mMol O m-3';'mMol C m-3';'mMol C m-3';'mMol C m-3';'uMol Fe m-3'};
    disp('Compute Biogeochemical variables for PISCES')
    disp('=========================')
else
    error(sprintf(['You don''t have the neccesary variables in the clim file. \n',...
        'or you didn''t choose the right bio. model. \n',...
        'Check croco_ini.nc parent file and make_clim.m']))
end
%
% Title
%
title=['Climatology file for the embedded grid :',child_clim,...
       ' using parent forcing file: ',parent_clim];
disp(' ')
disp(title)
if extrapmask==1
  disp('Extrapolation under mask is on')
  disp('====================')
end
%
if vertical_correc==1
  disp('Vertical correction is on')
  disp('===============')
end
%
if pisces & biol 
  error(['Both Biol NPZD and Pisces are ON, no possible yet...!'])
end
%
% Read in the embedded grid
%
disp(' ')
disp(' Read in the embedded grid...')
nc=netcdf(child_grd);
parent_grd=nc.parent_grid(:);
imin=nc{'grd_pos'}(1);
imax=nc{'grd_pos'}(2);
jmin=nc{'grd_pos'}(3);
jmax=nc{'grd_pos'}(4);
refinecoeff=nc{'refine_coef'}(:);
result=close(nc);
nc=netcdf(parent_grd);
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
if extrapmask==1
  mask=nc{'mask_rho'}(:);
else
  mask=[];
end
result=close(nc);
%
% Read in the parent climatology file
%
disp(' ')
disp(' Read in the parent climatology file...')
nc = netcdf(parent_clim);
theta_s = nc{'theta_s'}(:);
theta_b = nc{'theta_b'}(:);
Tcline = nc{'Tcline'}(:);
N = length(nc('s_rho'));
vtransform=nc{'Vtransform'}(:);
hc = nc{'hc'}(:);
disp([' Use parent VTRANSFORM = ',num2str(vtransform)])
if ~exist('vtransform') | isempty(vtransform)
    disp([' No VTRANSFORM parameter found'])
    disp([' Use the default one VTRANSFORM = 1'])
    vtransform=1;
end
ttime = nc{'tclm_time'}(:);
tcycle = nc{'tclm_time'}.cycle_length(:);
stime = nc{'sclm_time'}(:);
scycle = nc{'sclm_time'}.cycle_length(:);
utime = nc{'ssh_time'}(:);
ucycle = nc{'ssh_time'}.cycle_length(:);
vtime = nc{'ssh_time'}(:);
vcycle = nc{'ssh_time'}.cycle_length(:);
sshtime = nc{'ssh_time'}(:);
sshcycle = nc{'ssh_time'}.cycle_length(:);
%
if biol==1
    for k=1:length(namebiol)
        eval([char(timebiol(k)),'=nc{''',char(timebiol(k)),'''}(:);']);
        eval([char(cyclebiol(k)),'=nc{''',char(timebiol(k)),'''}.cycle_length(:);']);
        %
        eval(['tbiol(k,:)=',char(timebiol(k)),';']);
        eval(['cbiol(k,:)=',char(cyclebiol(k)),';']);
end
end
%
if pisces==1
    for k=1:length(namepisces)
        eval([char(timepisces(k)),'=nc{''',char(timepisces(k)),'''}(:);']);
        eval([char(cyclepisces(k)),'=nc{''',char(timepisces(k)),'''}.cycle_length(:);']);
        %
        eval(['tpisces(k,:)=',char(timepisces(k)),';']);
        eval(['cpisces(k,:)=',char(cyclepisces(k)),';']);
    end
end
%
result=close(nc);

climtime=ttime;
if stime~=climtime | utime~=climtime | vtime~=climtime | sshtime~=climtime
  error('Nested_clim: different times... ')
end
%
% Create the climatology file
%
disp(' ')
disp(' Create the climatology file...')
ncclim=create_nestedclim(child_clim,child_grd,parent_clim,title,...
			 theta_s,theta_b,Tcline,N,...
			 ttime,stime,utime,vtime,sshtime,...
			 tcycle,scycle,ucycle,vcycle,sshcycle,...
             tbiol,cbiol,tpisces, cpisces, ...
             'clobber',...
			 biol,pisces,...
             timebiol, cyclebiol,timepisces,cyclepisces,...
             namebiol,namepisces,unitbiol,unitpisces,hc,vtransform);
%
% parent indices
%
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));
%
% the children indices
%
ipchild=(imin:1/refinecoeff:imax);
jpchild=(jmin:1/refinecoeff:jmax);
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichildgrd_p,jchildgrd_p]=meshgrid(ipchild,jpchild);
[ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
[ichildgrd_u,jchildgrd_u]=meshgrid(ipchild,jrchild);
[ichildgrd_v,jchildgrd_v]=meshgrid(irchild,jpchild);
%
% interpolations
% 
disp(' ')
disp(' Do the interpolations...')                     
np=netcdf(parent_clim);
disp('u...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar4d(np,ncclim,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'u',mask,tindex,N)
end
disp('v...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar4d(np,ncclim,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'v',mask,tindex,N)
end
disp('zeta...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar3d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'SSH',mask,tindex)
end
disp('ubar...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar3d(np,ncclim,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'ubar',mask,tindex)
end
disp('vbar...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar3d(np,ncclim,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'vbar',mask,tindex)
end
disp('temp...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar4d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'temp',mask,tindex,N)
end
disp('salt...')
for tindex=1:length(climtime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))]) 
  interpvar4d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'salt',mask,tindex,N)
end
%
%%
%
if biol
    for k=1:length(namebiol)
        disp(char(namebiol(k)))
        for tindex=1:length(tbiol(k,:))
            disp([' Time index : ',num2str(tindex),' of ',num2str(length(tbiol(k,:)))])
            interpvar4d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,char(namebiol(k)),mask,tindex,N)
        end
    end
end
%
if pisces
    for k=1:length(namepisces)
        disp(char(namepisces(k)))
        for tindex=1:length(tpisces(k,:))
            disp([' Time index : ',num2str(tindex),' of ',num2str(length(tpisces(k,:)))])
            interpvar4d(np,ncclim,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,char(namepisces(k)),mask,tindex,N)
        end
    end
end
close(np);
close(ncclim);
%
%  Vertical corrections
%
if (vertical_correc==1)
    disp('Process variable physical variables')
    for tindex=1:length(climtime)
        disp([' Time index : ',num2str(tindex),' of ',num2str(length(climtime))])
        vert_correc(child_clim,tindex,0,0,namebiol,namepisces)
    end
    %%
    if biol
        disp('Process variable NPZD')
        for k=1:length(namebiol)
            disp(char(namebiol(k)))
            for tindex=1:length(tbiol(k,:))
                disp([' Time index : ',num2str(tindex),' of ',num2str(length(tbiol(k,:)))])
                vert_correc_onefield(child_clim,tindex,char(namebiol(k)))
            end
        end
    end
    %%
    if pisces
        disp('Process variable PISCES')
        for k=1:length(namepisces)
            disp(char(namepisces(k)))
            for tindex=1:length(tpisces(k,:))
                disp([' Time index : ',num2str(tindex),' of ',num2str(length(tpisces(k,:)))])
                vert_correc_onefield(child_clim,tindex,char(namepisces(k)))
            end
        end
    end
end
%
% Make a plot
%
disp(' ')
disp(' Make a plot...')
figure(1)
plot_nestclim(child_clim,child_grd,'temp',4)
return
