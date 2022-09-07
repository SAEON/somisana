function chlo=extr_chlo(Cpd,z);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function chlo=extr_chlo(Cpd,z);
%
%  vertical extrapolation of chlorophyll from the surface values
%  using Morel and Berthon (1989) parameterization
%  ref:  Morel and Berthon, Surface pigments, algal biomass
%        profiles, and potential production of the euphotic layer:
%        Relationships reinvestigated in view of remote-sensing 
%        applications. Limnol. Oceanogr., 34, 1989, 1545-1562.
%
%    input:
%
%  Cpd : mean pigment concentration within the surface layer (micro mole/l),
%        2D horizontal matrix.
%  z   : vertical positions (m, negative) 3D matrix
%
%    output:
%
%  chlo: chlorophyll concentration (mgC.m-3) 3D matrix
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
%
[N,M,L]=size(z);
Cpd=reshape(Cpd,1,M,L);
Cpd=repmat(Cpd,[N 1 1]);
%
% mass balance for chla molecule, 893.5/660. [mg Chla (mg C)-1]
%
chla_C  = 1.3538;
%
% molecular mass of chlorophyll
%
Mchla=893.5;
Cpd=Mchla*Cpd/1000; %mg/m3
%
% total pigment content within the euphotic layer (Ctot)
% expressed as the mean pigment concentration within 
% the surface layer (Cpd) (stratified waters)
%
Ctot=38*Cpd.^0.425;
Ctot(Cpd>1)=40.2*Cpd(Cpd>1).^0.507;
%
% depth of the euphotic layer
%
Ze=-568.2*Ctot.^(-0.746);
Ze(Ze<=-102)=-200*Ctot(Ze<=-102).^(-0.293);
zeta=z./Ze;
%
% mean pigment concentration within 
% the euphotic layer (Cze)
% expressed as the mean pigment concentration within 
% the surface layer (Cpd) (stratified waters)
%
Cze=1.12*Cpd.^0.803;
%
% vertical chlorophyll profile 
%
warning off
lc=log10(Cpd);
warning on
lc2=lc.^2;
lc3=lc.^3;
%
Cb=0.768+0.087*lc-0.179*lc2-0.025*lc3;
Cmax=0.299-0.289*lc+0.579*lc2;
zetamax=0.600-0.640*lc+0.021*lc2+0.115*lc3;
dzeta=0.710+0.159*lc+0.021*lc2;
%
% recompute iteratively the euphotic layer depth
%
eps=1000;
while eps>0.1
  Zeold=Ze;
  Ctot=-Ze.*(Cze.*Cb+Cze.*Cmax.*0.5.*sqrt(pi).*dzeta.*...
           (erf((1-zetamax)./dzeta)-erf(-zetamax./dzeta)));
  Ze=-568.2*Ctot.^(-0.746);
  Ze(Ze<=-102)=-200*Ctot(Ze<=-102).^(-0.293);
  Ze=0.5*(Ze+Zeold);
  zeta=z./Ze;
  eps=max(max(abs(Zeold-Ze)));
end
%
C=0.5.*(1+tanh(2.*(2.*Ze-z)./Ze)).*...
  Cze.*(Cb+Cmax.*exp(-((zeta-zetamax)./dzeta).^2));
C(C<0)=0;
%
% compute chlo in mgC
%
chlo=C/chla_C;
chlo(Cpd<0.01)=0;
%
