function [TXadv,Ttrun]=croco_horiz_trcflux(mask,maskr,trc,FlxU,dim);

%%% THIS FUNCTION COMPUTES ADVECTION TERMS IN THE SAME WAY THAT 
%%% THE CODE IS DOING IT- This is coded for Txadv. If Tyadv needs 
%%% to be computed, permute is done at entrance and exit of the 
%%% function and the code remains unchanged in the middle. The 
%%% truncation error is also computed here. 
%%%
%%% [Txadv,Ttrun]=croco_horiz_advection(grd,trc,Flxu,dim);
%%%    grd   : grid structure as loaded by  grd=rnt_gridload(model);
%%%    trc   : tracer array of size Lp x Mp x N
%%%    Flxu  : flux through cell array as computed from 
%%%               croco_volflux
%%%    dim   : 1 for Txadv and 2 for Tyadv
%%%    Txadv : tracer flux in xsi direction
%%%    Ttrun : 4th order term ie diffusion estimate

mask=perm(mask);
maskr=perm(maskr);
trc=perm(trc);
FlxU=perm(FlxU);

if dim==2
  trc=permute(trc,[2 1 3]);
  FlxU=permute(FlxU,[2 1 3]);
  mask=permute(mask,[2 1 3]);
end

[Lp,Mp,N]=size(trc);

FX=zeros(Lp+1,Mp,N);
TXadv=zeros(Lp,Mp,N);
Ttrun=zeros(Lp,Mp,N);

FX(2:Lp,:,:)=(trc(2:Lp,:,:)-trc(1:Lp-1,:,:)).*repmat(mask,[1 1 N]);
FX(1,:,:)=FX(2,:,:);
FX(Lp+1,:,:)=FX(Lp,:,:);

curv=FX(2:Lp+1,:,:)-FX(1:Lp,:,:);
FX(1:Lp-1,:,:)=0.5*(trc(2:Lp,:,:)+trc(1:Lp-1,:,:)).*FlxU-0.166666666666 ...
                    *( curv(1:Lp-1,:,:).*max(FlxU,0.) ...
                      +curv(2:Lp  ,:,:).*min(FlxU,0.));

TXadv(2:Lp-1,:,:)=-(FX(2:Lp-1,:,:)-FX(1:Lp-2,:,:));
TXadv(1,:,:)=TXadv(2,:,:);
TXadv(Lp,:,:)=TXadv(Lp-1,:,:);

FX(1:Lp-1,:,:)=0.041666667*(curv(2:Lp,:,:)-curv(1:Lp-1,:,:)).*abs(FlxU);
Ttrun(2:Lp-1,:,:)=-(FX(2:Lp-1,:,:)-FX(1:Lp-2,:,:));
Ttrun(1,:,:)=Ttrun(2,:,:);
Ttrun(Lp,:,:)=Ttrun(Lp-1,:,:);

if dim==2
  TXadv=permute(TXadv,[2 1 3]);
  Ttrun=permute(Ttrun,[2 1 3]);
end

maskr=repmat(maskr,[1 1 N]);
TXadv=TXadv.*maskr;
Ttrun=Ttrun.*maskr;

TXadv=perm(TXadv);
Ttrun=perm(Ttrun);

return
