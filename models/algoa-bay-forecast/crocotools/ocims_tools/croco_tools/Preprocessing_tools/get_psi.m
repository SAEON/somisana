function psi=get_psi(u,v,pm,pn,rmask)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute a stream function from a CROCO vector
%  field (velocity or transport)
%
%  1 - get boundary conditions for psi
%  2 - diffuse these boundary conditions on the land points
%  3 - get Xi the vorticity
%  4 - inverse laplacian(psi)=Xi
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M,L]=size(pm);
pmask=rmask(2:end,2:end).*rmask(2:end,1:end-1).*...
      rmask(1:end-1,2:end).*rmask(1:end-1,1:end-1);
%
% Get lateral boundary conditions for psi
%
psi=zeros(M-1,L-1);
uon=2*u./(pn(:,1:end-1)+pn(:,2:end));
vom=2*v./(pm(1:end-1,:)+pm(2:end,:));
%
% Quick fix for a bug: stepsor cherche bcpsi~=0 pour ne
% pas appliquer de condition aux limites sur les iles.
% or si psi(1,1)=0 et si c'est masque, alors c'est considere
% comme une ile. 
% le fixer a 1e7 devrait prevenir le probleme, mais ce n'est
% pas fiable a 100%.
%
psi(1,1)=1e7;
%
for j=2:M-1
  psi(j,1)=psi(j-1,1)-uon(j,1);
end
for i=2:L-1
  psi(end,i)=psi(end,i-1)+vom(end,i);
end
psiend=psi(end,end);
for i=2:L-1
  psi(1,i)=psi(1,i-1)+vom(1,i);
end
for j=2:M-1
  psi(j,end)=psi(j-1,end)-uon(j,end);
end
if (psiend~=0)
  deltapsi=100*abs((psi(end:end)-psiend)/psiend);
else
  deltapsi=100*abs(psi(end:end));
end
if deltapsi>1e-10
  disp(['Warning : no mass conservation : deltapsi=',num2str(deltapsi)])
end
%
% Diffuse the psi boundaries condition on land to get 
% a constant psi on the mask. 
% WARNING !!! This does not work for islands
%
land=1-pmask;
bcpsi=land.*psi;
mean1=mean(mean(bcpsi));
epsil=1e-6;
delta_mean=epsil+1;
n=1;
nmax=500;
while (delta_mean>epsil)&(n<nmax)
  lmask=0.*bcpsi;
  lmask(bcpsi~=0)=1;
  denom=(land(1:end-2,2:end-1).*lmask(1:end-2,2:end-1)+...
         land(3:end,2:end-1).*lmask(3:end,2:end-1)+...
         land(2:end-1,1:end-2).*lmask(2:end-1,1:end-2)+...
         land(2:end-1,3:end).*lmask(2:end-1,3:end));
  denom(denom==0)=1;
  rhs=(land(1:end-2,2:end-1).*bcpsi(1:end-2,2:end-1)+...
       land(3:end,2:end-1).*bcpsi(3:end,2:end-1)+...
       land(2:end-1,1:end-2).*bcpsi(2:end-1,1:end-2)+...
       land(2:end-1,3:end).*bcpsi(2:end-1,3:end))./denom;
  bcpsi(2:end-1,2:end-1)=land(2:end-1,2:end-1).*rhs;
  mean2=mean(mean(bcpsi));
  delta_mean=abs((mean1-mean2)/mean2);
  mean1=mean2;
  n=n+1;
  if n>=nmax
    disp('Mask: no convergence')
  end
end
disp(['Mask: ',num2str(n),' iterations'])
%
% Prepare for psi integration div(psi)=xi
%
mn=pm.*pn;
mon=pm./pn;
nom=pn./pm;
a1=0.25*(mn(1:end-1,1:end-1)+mn(1:end-1,2:end)...
        +mn(2:end,1:end-1)+mn(2:end,2:end));
a2=0.5*(mon(1:end-1,2:end)+mon(2:end,2:end));
a3=0.5*(mon(1:end-1,1:end-1)+mon(2:end,1:end-1));
a4=0.5*(nom(2:end,1:end-1)+nom(2:end,2:end));
a5=0.5*(nom(1:end-1,1:end-1)+nom(1:end-1,2:end));
b1=-(a2+a3+a4+a5);
b2=-1./a1;
J2=(max(max((cos(pi/L)+nom.^2.*cos(pi/M))./(1+nom.^2)))).^2;
%
% get the vorticity
%
uom=2*u./(pm(:,1:end-1)+pm(:,2:end));
von=2*v./(pn(1:end-1,:)+pn(2:end,:));
xi=pmask.*a1.*(von(:,2:end)-von(:,1:end-1)-uom(2:end,:)+uom(1:end-1,:));                       
%
% Inversion of the elliptic equation (SOR)
%
% Initial value of surrelaxation
%
W=1;
%
% Get a matrix of parity (i.e. i+j = odd or even)
%   
myi=1:L-1;
myj=1:M-1;
[MYI,MYJ]=meshgrid(myi,myj);
ijeven=mod(MYJ+MYI,2);
%
% First step (odd and even)
%
rhs=0.*psi;
parity=1; %(i+j) even
step_sor
parity=0; %(i+j) odd
step_sor
%
% Integration until convergence
%
meanrhs=mean(mean(abs(rhs(pmask==1))));
Norm0=meanrhs;
epsil=1e-4;
n=1;
nmax=M*L;
while meanrhs>epsil*Norm0
  n=n+1;
  parity=1; %(i+j) even
  step_sor
  parity=0; %(i+j) odd
  step_sor
  meanrhs=mean(mean(abs(rhs(pmask==1))));
  if n > nmax
    meanrhs=0;
    disp('PSI: No convergence')
  end
end
disp(['PSI: ',num2str(n),' iterations '])
% 
psi=psi-(mean(mean(psi)));
%
return
