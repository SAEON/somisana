function [psi0,psi1,island]=get_psi0(u,v,pm,pn,rmask)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute a stream function from a CROCO vector
%  field (velocity or transport)
%
%  1 - get boundary conditions for psi
%  2 - diffuse these boundary conditions on the land points
%  3 - get Xi the vorticity
%  4 - inverse laplacian(psi)=Xi
%
%  penven 21-10-2001
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M,L]=size(pm);
pmask=rmask(2:end,2:end).*rmask(2:end,1:end-1).*...
      rmask(1:end-1,2:end).*rmask(1:end-1,1:end-1);
%
% Get lateral boundary conditions for psi
%
% psi: initial and  dirichlet boundary conditions, 2D matrix
% bcpsi: dirichlet boundary conditions for the mask, 2D matrix 
%
[psi,bcpsi]=get_bcpsi(u,v,pm,pn,pmask);
island=(pmask==0 & bcpsi==0);
if sum(sum(island))==0
  disp('No island')
  bc0=bcpsi;
  bc0(bcpsi==0)=NaN;
else
  disp('Island')
  bc0=bcpsi;
  bc0(bcpsi==0 & pmask~=0)=NaN;
  bc1=0*bc0;
  bc1(island==1)=1;
end
%
% get the vorticity
%
xi=vorticity(u,v,pm,pn);
%
% get psi0
%
epsil=1e-8;
psi0=inv_elliptic(psi,bc0,xi,pm,pn,pmask,epsil);
%
% get psi1
%
if sum(sum(island))==0
  psi1=0*psi0;
else
  psi1=inv_elliptic(0*psi,bc1,0*xi,pm,pn,pmask,epsil);
end
%
return
