function dqdsst=get_dqdsst(sst,sat,rho_atm,U,qsea)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Compute the kinematic surface net heat flux sensitivity to the
%  the sea surface temperature: dQdSST.
%  Q_model ~ Q + dQdSST * (T_model - SST)
%  dQdSST = - 4 * eps * stef * T^3  - rho_atm * Cp * CH * U
%           - rho_atm * CE * L * U * 2353 * ln (10) * q_s / T^2
% 
% B. Barnier, L. Siefridt, P. Marchesiello,
% Thermal forcing for a global ocean circulation model using 
% a three-year climatology of ECMWF analyses,
% J. Marine Sys., 2005, 6, 363-380
%
% Input parameters:
%
%  sst     : sea surface temperature (Celsius)
%  sat     : sea surface atmospheric temperature (Celsius)
%  rho_atm : atmospheric density (kilogram meter-3) 
%  U       : wind speed (meter s-1)
%  qsea    : sea level specific humidity
%
% 
% Ouput:
%
%  dqdsst  : kinematic surface net heat flux sensitivity to the
%            the sea surface temperature (Watts meter-2 Celsius-1)
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Specific heat of atmosphere.
%
Cp = 1004.8;
%
%  Sensible heat transfert coefficient (stable condition)
%
Ch = 0.66e-3;
%
%  Latent heat transfert coefficient (stable condition)
%
Ce = 1.15e-3;
%
%  Emissivity coefficient
%
eps = 0.98;
%
%  Stefan constant
%
stef = 5.6697e-8;
%
%  SST (Kelvin)
%
SST = sst + 273.15;
%
%  Latent heat of vaporisation (J.kg-1)
%
L = 2.5008e6 - 2.3e3 * sat;
%
%  Infrared contribution
%
q1 = -4.d0 .* stef .* (SST.^3);
%
%  Sensible heat contribution
%
q2 = -rho_atm .* Cp .* Ch .* U;
%
%  Latent heat contribution
%
dqsdt = 2353.d0 .* log(10.d0) .* qsea ./ (SST.^2);
q3 = -rho_atm .* Ce .* L .* U .* dqsdt;
%
%  dQdSST
%
dqdsst = q1 + q2 + q3 ;

