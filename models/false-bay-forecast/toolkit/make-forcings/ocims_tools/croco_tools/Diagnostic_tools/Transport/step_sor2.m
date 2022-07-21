%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  1 Step of the elliptic solver (SOR) used in get_psi.m
%
%  penven 21-10-2001
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get the rhigh hand side terms of the equations
%
rhs(2:end-1,2:end-1)=...
a2(2:end-1,2:end-1).*psi(2:end-1,3:end)+...
a3(2:end-1,2:end-1).*psi(2:end-1,1:end-2)+...
a4(2:end-1,2:end-1).*psi(3:end,2:end-1)+...
a5(2:end-1,2:end-1).*psi(1:end-2,2:end-1)+...
b1(2:end-1,2:end-1).*psi(2:end-1,2:end-1)+...
b2(2:end-1,2:end-1).*xi(2:end-1,2:end-1);
%
% Step PSI
%
psi(ijeven==parity)=psi(ijeven==parity)-...
                    W.*rhs(ijeven==parity)./...
                    b1(ijeven==parity);
%
% Advance the surrelaxation parameter
%
W=1/(1-J2*W/4);
%
% Apply the mask (not the islands bcpsi~=0)
%
psi(isfinite(bc))=bc(isfinite(bc));
%
%
%
return
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
