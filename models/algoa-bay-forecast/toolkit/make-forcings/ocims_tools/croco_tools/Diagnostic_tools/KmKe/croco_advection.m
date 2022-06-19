function Tadv=croco_advection(masku,maskv,maskr,Hz,dn_uXu,dm_vXv,omegaXomn_w,temp)
%
% Compute Uflx
%
FlxU=0.5*(Hz(:,:,2:end)+Hz(:,:,1:end-1)).*dn_uXu;
%
% Compute Vflx
%
FlxV=0.5*(Hz(:,2:end,:)+Hz(:,1:end-1,:)).*dm_vXv;
%
% Compute Flux term and "diffusion" in xi direction
%
[Xadv,trun]=croco_horiz_trcflux(masku,maskr,temp,FlxU,1);
%
% Compute Flux term and "diffusion" in eta direction
%
[Yadv,trun]=croco_horiz_trcflux(maskv,maskr,temp,FlxV,2);
%
% compute Flux term in z direction
%
Vadv=croco_vert_trcflux(maskr,temp,omegaXomn_w);
%
Tadv=-Xadv-Yadv-Vadv;
%
return
