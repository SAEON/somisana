function nested_restart(child_grd,parent_rst,child_rst,...
                        vertical_correc,extrapmask)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the restart file of the embedded grid
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
a= netcdf(parent_rst);
Vars = var(a);
Varnames = [ncnames(Vars)];
nvar=length(Varnames);
%
namebiol={''};
unitbiol={''};
namepisces={''};
unitpisces={''};
biol=0;
pisces=0;
%biol_NPZD=0;
%biol_NPZD_wO2=0;
%biol_N2PZD2=0;

if nvar <= 37
    disp(['No biology'])
elseif nvar == 42
    %biol_NPZD=1;
    namebiol={'NO3';'CHLA';'PHYTO';'ZOO';'DET'};
    unitbiol={'mMol N m-3' ; 'mg C l-1' ; 'mMol N m-3';...
        'mMol N m-3' ; 'mMol N m-3'};
    biol=1;
    disp('Biol NPZD is on')
    disp('==========')
elseif nvar == 43
    %biol_NPZD_wO2=1;
    namebiol={'NO3';'O2';'CHLA';'PHYTO';'ZOO';'DET'};
    unitbiol={'mMol N m-3' ;'mMol O m-3' ; 'mg C l-1' ; 'mMol N m-3';...
        'mMol N m-3' ; 'mMol N m-3'};
    biol=1;
    disp('Biol NPZD_wO2 is on')
    disp('==========')
elseif nvar == 44
    %biol_N2PZD2=1;
    namebiol={'NO3' ; 'NH4' ; 'CHLA' ; 'PHYTO' ; 'ZOO' ; 'SDET' ; 'LDET'};
    unitbiol={'mMol N m-3' ; 'mMol N m-3' ; 'mg C l-1' ; ...
        'mMol N m-3' ; 'mMol N m-3' ; 'mMol N m-3' ; ...
        'mMol N m-3'};
    biol=1;
    disp('Biol N2PZD2 is on')
    disp('==========')
elseif nvar == 49
    %biol_bioebus=1;
    namebiol={'NO3';'NO2';'NH4';'SPHYTO';'LPHYTO';'SZOO';'LZOO';'SDET';'LDET';'DON';'O2';'N2O'};
    unitbiol={'mMol N m-3' ; 'mMol N m-3'  ; 'mMol N m-3' ; 'mMol N m-3' ; 'mMol N m-3' ; 'mMol N m-3'; ...
              'mMol N m-3' ; 'mMol N m-3'  ; 'mMol N m-3' ; 'mMol N m-3' ; 'mMol N m-3' ; 'mMol N m-3'};
    biol=1;
    disp('BioEBUS is on')
    disp('==========')   
else
    pisces=1;
    namepisces={'DIC' ; 'TALK' ; 'O2' ; 'CACO3'  ;  'PO4' ;  'POC' ;
        'Si'  ; 'NANO' ; 'ZOO'  ;  'DOC' ;  'DIA' ; 'MESO' ; 'BSI' ;
        'FER' ; 'BFE' ; 'GOC'; 'SFE' ; 'DFE' ; 'DSI' ; 'NFE' ; ...
        'NCHL' ;  'DCHL';  'NO3' ; 'NH4'};
    unitpisces={'umol C L-1' ; 'umol C L-1' ; 'umol O L-1' ;  'umol C L-1' ;  'umol P L-1' ;  'umol C L-1' ; ...
        'umol Si L-1' ;  'umol C L-1' ; 'umol C L-1'  ; 'umol C L-1' ; 'umol C L-1' ; 'umol C L-1' ; 'umol Si L-1' ; ...
        'umol Fe L-1' ; 'umol Fe L-1' ;  'umol C L-1' ;  'umol Fe L-1' ; 'umol Fe L-1' ; 'umol Si L-1';'umol Fe L-1' ;...
        'mg Chl m-3' ; 'mg Chl m-3' ; 'umol N L-1' ; 'umol N L-1'};
    disp('Pisces is on')
    disp('==========')
end

% if  (biol_NPZD | biol_NPZD_wO2 | biol_N2PZD2 )
%   biol=1;
% end

if extrapmask==1
  disp('Extrapolation under mask is on')
  disp('====================')
end

if vertical_correc==1
  disp('Vertical correction is on')
  disp('====================')
end

if pisces & (biol_NPZD | biol_NPZD_wO2 | biol_N2PZD2)
  error(['Both Biol NPZD type  and Pisces are ON, no possible yet !'])
end

%
% Title
%
title=['restart file for the embedded grid :',child_rst,...
       ' using parent restart file: ',parent_rst];
disp(' ')
disp(title)
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
% Read in the parent restart file
%
disp(' ')
disp(' Read in the parent restart file...')
nc = netcdf(parent_rst);
theta_s=nc{'theta_s'}(:);
vtransform=nc{'Vtransform'}(:);
if isempty(theta_s)
  theta_s=nc.theta_s(:);
  theta_b=nc.theta_b(:);
  hc=nc.hc(:);
else
  theta_b=nc{'theta_b'}(:);
  hc=nc{'hc'}(:);
end
if  ~exist('vtransform') | isempty(vtransform)
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
N=length(nc('s_rho'));
thetime = nc{'scrum_time'}(:);
result=close(nc);
%
% Create the restart file
%
disp(' ')
disp(' Create the restart file...')
ncrst=create_nestedrestart(child_rst,child_grd,parent_rst,title,...
			   'clobber',biol,pisces,namebiol,namepisces,unitbiol,unitpisces,hc,vtransform);
           
%
% Get the parent indices
%
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));
%
% Get the children indices
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
np=netcdf(parent_rst);
for tindex=1:length(thetime)
  disp([' Time index : ',num2str(tindex),' of ',num2str(length(thetime))])                     
  ncrst{'scrum_time'}(tindex)=thetime(tindex);
  ncrst{'time_step'}(tindex,:)= np{'time_step'}(tindex,:);
  %
  disp('zeta...')
  interpvar3d(np,ncrst,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'zeta',mask,tindex)
  disp('ubar...')
  interpvar3d(np,ncrst,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'ubar',mask,tindex)
  disp('vbar...')
  interpvar3d(np,ncrst,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'vbar',mask,tindex)
  disp('u...')
  interpvar4d(np,ncrst,igrd_u,jgrd_u,ichildgrd_u,jchildgrd_u,'u',mask,tindex,N)
  disp('v...')
  interpvar4d(np,ncrst,igrd_v,jgrd_v,ichildgrd_v,jchildgrd_v,'v',mask,tindex,N)
  disp('temp...')
  interpvar4d(np,ncrst,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'temp',mask,tindex,N)
  disp('salt...')
  interpvar4d(np,ncrst,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,'salt',mask,tindex,N)
  %
  if (biol==1)
    for k=1:length(namebiol)
      disp(char(namebiol(k)))
      interpvar4d(np,ncrst,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,char(namebiol(k)),mask,tindex,N)
    end
  end
  %
  if (pisces==1)
    for k=1:length(namepisces)
      disp(['K=',num2str(k)])
      disp(char(namepisces(k)))
      interpvar4d(np,ncrst,igrd_r,jgrd_r,ichildgrd_r,jchildgrd_r,char(namepisces(k)),mask,tindex,N)
    end
  end
end
result=close(np);
result=close(ncrst);
%
%  Vertical corrections
%
if (vertical_correc==1)
  for tindex=1:length(thetime)
    disp([' Time index : ',num2str(tindex),' of ',num2str(length(thetime))])                     
    vert_correc(child_rst,tindex,biol,pisces,namebiol,namepisces)
  end
end

%
% Make a plot
%
if ~isempty(thetime)
  disp(' ')
  disp(' Make a plot...')
  figure(1)
  plot_nestclim(child_rst,child_grd,'temp',1)
else
  disp(' ')
  disp(' Warning : no restart variable to plot...')
end

return
