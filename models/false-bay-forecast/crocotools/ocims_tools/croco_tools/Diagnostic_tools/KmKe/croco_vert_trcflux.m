function [Tvadv]=croco_vert_trcflux(maskr,trc,W);

%%% THIS FUNCTION COMPUTES V ADVECTION TERMS IN THE SAME WAY 
%%% THAT THE CODE IS DOING IT (key AKIMA_V) 
%%%
%%% [Tvadv]=croco_vert_advection(grd,trc,W);
%%%    grd   : grid structure as loaded from grd=rnt_gridload(model);
%%%    trc   : tracer array of size Lp x Mp x N
%%%    W     : sigma vertical velocity - This is a flux at this stage. 
%%%            To be decided if it has 
%%%            to be recomputed from u and v or if stored is better
%%%            This should bow down to zeta issue. 
%%%    Tvadv : tracer flux in vertical direction

maskr=perm(maskr);
trc=perm(trc);
W=perm(W);

epsil=1e-16;
[Lp,Mp,N]=size(trc);
FC=zeros(Lp,Mp,N+1);

FC(:,:,2:N)=trc(:,:,2:N)-trc(:,:,1:N-1);
FC(:,:,1)=FC(:,:,2);
FC(:,:,N+1)=FC(:,:,N);

cff=2.*(FC(:,:,2:N+1).*FC(:,:,1:N));
CF=cff./(FC(:,:,2:N+1)+FC(:,:,1:N));
CF(cff<epsil)=0;  

FC(:,:,2:N)=0.5*(trc(:,:,2:N)+trc(:,:,1:N-1)-0.333333*...
         (CF(:,:,2:N)-CF(:,:,1:N-1))).*W(:,:,2:N);
FC(:,:,1)=0;
FC(:,:,N+1)=0;

Tvadv=-(FC(:,:,2:N+1)-FC(:,:,1:N)).*repmat(maskr,[1 1 N]);

Tvadv=perm(Tvadv);

return
