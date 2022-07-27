function [psi,bcpsi]=get_bcpsi(u,v,pm,pn,pmask)
%
% Get lateral boundary conditions for psi
%
[M,L]=size(pm);
psi=0*pmask;;
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
epsil=1e-8;
nmax=500;
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
delta_mean=epsil+1;
n=1;
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
