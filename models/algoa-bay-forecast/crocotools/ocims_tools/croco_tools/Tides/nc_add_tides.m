function nc_add_tides(fname,Ntides,start_tide_mjd,components)
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
%  Copyright (c) 2001-2006 by Patrick Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc=netcdf(fname,'write');
%%redef(nc);		% for Octave compatibility
%
%  Add dimension
%
nc('tide_period')=Ntides;
%
%  Add variables and attributes
%
nc{'tide_period'} = ncdouble('tide_period');
nc{'tide_period'}.long_name = ncchar('Tide angular period');
nc{'tide_period'}.long_name = 'Tide angular period';
nc{'tide_period'}.units = ncchar('Hours');
nc{'tide_period'}.units = 'Hours';

nc{'tide_Ephase'} = ncdouble('tide_period', 'eta_rho', 'xi_rho');
nc{'tide_Ephase'}.long_name = ncchar('Tidal elevation phase angle');
nc{'tide_Ephase'}.long_name = 'Tidal elevation phase angle';
nc{'tide_Ephase'}.units = ncchar('Degrees');
nc{'tide_Ephase'}.units = 'Degrees';

nc{'tide_Eamp'} = ncdouble('tide_period', 'eta_rho', 'xi_rho');
nc{'tide_Eamp'}.long_name = ncchar('Tidal elevation amplitude');
nc{'tide_Eamp'}.long_name = 'Tidal elevation amplitude';
nc{'tide_Eamp'}.units = ncchar('Meter');
nc{'tide_Eamp'}.units = 'Meter';

nc{'tide_Cmin'} = ncdouble('tide_period', 'eta_rho', 'xi_rho');
nc{'tide_Cmin'}.long_name = ncchar('Tidal current ellipse semi-minor axis');
nc{'tide_Cmin'}.long_name = 'Tidal current ellipse semi-minor axis';
nc{'tide_Cmin'}.units = ncchar('Meter second-1');
nc{'tide_Cmin'}.units = 'Meter second-1';

nc{'tide_Cmax'} = ncdouble('tide_period', 'eta_rho', 'xi_rho');
nc{'tide_Cmax'}.long_name = ncchar('Tidal current, ellipse semi-major axis');
nc{'tide_Cmax'}.long_name = 'Tidal current, ellipse semi-major axis';
nc{'tide_Cmax'}.units = ncchar('Meter second-1');
nc{'tide_Cmax'}.units = 'Meter second-1';

nc{'tide_Cangle'} = ncdouble('tide_period', 'eta_rho', 'xi_rho');
nc{'tide_Cangle'}.long_name = ncchar('Tidal current inclination angle');
nc{'tide_Cangle'}.long_name = 'Tidal current inclination angle';
nc{'tide_Cangle'}.units = ncchar('Degrees between semi-major axis and East');
nc{'tide_Cangle'}.units = 'Degrees between semi-major axis and East';

nc{'tide_Cphase'} = ncdouble('tide_period', 'eta_rho', 'xi_rho');
nc{'tide_Cphase'}.long_name = ncchar('Tidal current phase angle');
nc{'tide_Cphase'}.long_name = 'Tidal current phase angle';
nc{'tide_Cphase'}.units = ncchar('Degrees');
nc{'tide_Cphase'}.units = 'Degrees';

nc{'tide_Pamp'} = ncdouble('tide_period', 'eta_rho', 'xi_rho');
nc{'tide_Pamp'}.long_name = ncchar('Tidal potential amplitude');
nc{'tide_Pamp'}.long_name = 'Tidal potential amplitude';
nc{'tide_Pamp'}.units = ncchar('Meter');
nc{'tide_Pamp'}.units = 'Meter';

nc{'tide_Pphase'} = ncdouble('tide_period', 'eta_rho', 'xi_rho');
nc{'tide_Pphase'}.long_name = ncchar('Tidal potential phase angle');
nc{'tide_Pphase'}.long_name = 'Tidal potential phase angle';
nc{'tide_Pphase'}.units = ncchar('Degrees');
nc{'tide_Pphase'}.units = 'Degrees';

nc.date = ncchar(date);
nc.date = date;
nc.start_tide_mjd=start_tide_mjd;
nc.components = ncchar(components);
nc.components = components;

close(nc)
