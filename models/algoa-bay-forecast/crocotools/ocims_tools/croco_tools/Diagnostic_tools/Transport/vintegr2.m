function [V,h0]=vintegr2(var,zw,zr,z01,z02)
%
% Vertically integrate a CROCO variable (var) from a constant depth 
% z01 (ex z01=-4000 m) to a constant depth z02 (ex z02=-2000m).
%
% If z01 = NaN : perform the integration from the bottom to z02.
% If z02 = NaN : perform the integration from z01 to the surface.
% If they are both NaNs perform the integration from the bottom
% to the surface.
%
% Input :
%
% var : CROCO variable at RHO-points (3D matrix)
% zw  : Depth of the W-points (3D matrix)
% zr  : Depth of the RHO-points (3D matrix)
% z01 : lower limit of integration (scalar)
% z02 : upper limit of integration (scalar)
%
% Output :
%
% V   : intgrated value (2D matrix)
% h0  : layer thickness (2D matrix)
%
% Pierrick Penven 2005
%
if z02 <= z01
 error('vintegr2:  z02 <= z01')
end
[Np,Mp,Lp]=size(zw);
N=Np-1;
ibad=2;
%
% Get the matrix of the variables above of z01 and below z02
%
if isfinite(z01) &  isfinite(z02) 
  isgood=(zw(1:end-1,:,:)>z01 & zw(2:end,:,:)<z02);
elseif isfinite(z01)
  isgood=zw(1:end-1,:,:)>z01;
elseif isfinite(z02)
  isgood=zw(2:end,:,:)<z02;
else
  isgood=(var==var);
end
%
if isfinite(z01)
%
% Find the bottom limit of the corresponding grid cells
%
  a=zw<z01;
  levs=squeeze(sum(a,1));
  levs(levs==Np)=N;
  warning off
  mask=levs./levs;
  warning on
  [imat,jmat]=meshgrid((1:Lp),(1:Mp));
  posw=Np*Mp*(imat-1)+Np*(jmat-1)+levs;
  posw(isnan(mask))=ibad;
  z1=zw(posw+1);
  z1(z1==zw(ibad+1))=NaN;
%
% Compute the vertical size of the partial step to add at the bottom
%
  dzbot=z1-z01;
  dzbot(isnan(dzbot))=0.;
%
% Get the value of the variable in the partial step to add at the bottom
%
  posr=N*Mp*(imat-1)+N*(jmat-1)+levs;
  Vbot=var(posr);
else
  dzbot=0; 
  Vbot=0;
end
%
if isfinite(z02)
%
% Find the top positions
%
  a=zw<z02;
  levs=squeeze(sum(a,1));
  levs(levs==Np)=N;
  warning off
  mask=levs./levs;
  warning on
  [imat,jmat]=meshgrid((1:Lp),(1:Mp));
  posw=Np*Mp*(imat-1)+Np*(jmat-1)+levs;
  posw(isnan(mask))=ibad;
  z2=zw(posw);
  z2(z2==zw(ibad))=NaN;
%
% Compute the vertical size of the partial step to add at the top
%
  dztop=z02-z2;
  dztop(isnan(dztop))=0;
%
% Get the value of the variable in the partial step to add at the bottom
%
  posr=N*Mp*(imat-1)+N*(jmat-1)+levs;
  Vtop=var(posr);
else
  dztop=0; 
  Vtop=0;
end
%
% Perform the vertical integration
%
dz=zw(2:end,:,:)-zw(1:end-1,:,:);
V=squeeze(sum(dz.*isgood.*var))+dzbot.*Vbot+dztop.*Vtop;
%
% Get the depth
%
h0=squeeze(sum(dz.*isgood))+dzbot+dztop;
%
V(h0==0)=0;
h0(h0==0)=0;
%
return

