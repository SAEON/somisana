function rho1=rho_pot(Tt,Ts)
%
% function rho1=rho_pot(Tt,Ts)
%
% Computes density via Equation Of State (EOS) for seawater.
% If so prescribed, non-linear EOS of Jackett and McDougall (1995)
% is used.
%
% Tt potential temperature [deg Celsius].
% Ts salinity [PSU].
%
% rho1 is sea-water density [kg/m^3] at standard pressure
% of 1 Atm
%
%  Reference:
%
%  Jackett, D. R. and T. J. McDougall, 1995, Minimal Adjustment of
%  Hydrostatic Profiles to Achieve Static Stability, Journ of Atmos.
%  and Oceanic Techn., vol. 12, pp. 381-389.
%
% << This equation of state formulation has been derived by Jackett
%    and McDougall (1992), unpublished manuscript, CSIRO, Australia.
%    It computes in-situ density anomaly as a function of potential
%    temperature (Celsius) relative to the surface, salinity (PSU),
%    and depth (meters).  It assumes  no  pressure  variation along
%    geopotential  surfaces,  that  is,  depth  and  pressure  are
%    interchangeable. >>
%                                          John Wilkin, 29 July 92
%
% Check Values: T=3 C S=35.5 PSU Z=-5000 m rho=1050.3639165364 
%

QR=+999.842594;Q01=+6.793952e-2;Q02=-9.095290e-3;
Q03=+1.001685e-4;Q04=-1.120083e-6;Q05=+6.536332e-9;Q10=+0.824493;
Q11=-4.08990e-3;Q12=+7.64380e-5;Q13=-8.24670e-7;Q14=+5.38750e-9;
QS0=-5.72466e-3;QS1=+1.02270e-4;QS2=-1.65460e-6;Q20=+4.8314e-4;

sqrtTs=sqrt(Ts);

rho1=QR+Tt.*(Q01+Tt.*(Q02+Tt.*(Q03+Tt.*(Q04+Tt.*Q05))))...
     +Ts.*(Q10+Tt.*(Q11+Tt.*(Q12+Tt.*(Q13+Tt.*Q14)))...
     +sqrtTs.*(QS0+Tt.*(QS1+Tt.*QS2))+Ts.*Q20);

return
 
