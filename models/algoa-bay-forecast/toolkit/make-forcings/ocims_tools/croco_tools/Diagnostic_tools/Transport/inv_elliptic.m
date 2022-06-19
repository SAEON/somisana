function psi=inv_elliptic(psi,bc,xi,pm,pn,pmask,epsil)
%
% Inversion of the elliptic equation (SOR)
%

%
% Prepare for psi integration div(psi)=xi
%
[M,L]=size(pm);
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
step_sor2
parity=0; %(i+j) odd
step_sor2
%
% Integration until convergence
%
meanrhs=mean(mean(abs(rhs(pmask==1))));
Norm0=meanrhs;
n=1;
nmax=M*L;
while meanrhs>epsil*Norm0
  n=n+1;
  parity=1; %(i+j) even
  step_sor2
  parity=0; %(i+j) odd
  step_sor2
  meanrhs=mean(mean(abs(rhs(pmask==1))));
  if n > nmax
    meanrhs=0;
    disp('PSI: No convergence')
  end
end
disp(['PSI: ',num2str(n),' iterations '])
%
