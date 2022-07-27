function [lat,lon,mask,var]=get_var(hisfile,gridfile,vname,tindex,...
                                    vlevel,coef,rempts)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get a CROCO variable...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['--',vname,'--'])
if isempty(gridfile)
  gridfile=hisfile;
end
%
if strcmp(vname,'h') | strcmp(vname,'pm') | strcmp(vname,'pn')
  [lat,lon,mask]=read_latlonmask(gridfile,'r');
  nc=netcdf(gridfile);
  var=nc{vname}(:);
  close(nc)
  mask(mask==0)=NaN;
  var=mask.*var;
elseif vname(1)=='*'
  if strcmp(vname,'*Ke')
    [lat,lon,mask,var]=get_ke(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Pot_vort')
    [lat,lon,mask,var]=get_pv(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Rho')
    [lat,lon,mask,var]=get_rho(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Vort')
    [lat,lon,mask,var]=get_vort(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Psi')
    [lat,lon,mask,var]=get_streamfunc(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Speed')
    [lat,lon,mask,var]=get_speed(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Transport')
    [lat,lon,mask,var]=get_transfunc(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*Okubo')
    [lat,lon,mask,var]=get_okubo(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Rho_pot')
    [lat,lon,mask,var]=get_pot(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Bvf')
    [lat,lon,mask,var]=get_bvf(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*Chla')
    [lat,lon,mask,var]=get_chla(hisfile,gridfile,tindex,vlevel,coef);
  elseif strcmp(vname,'*z_SST-1C')
    [lat,lon,mask,var]=get_z_SST1(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*z_rho-1.25')
    [lat,lon,mask,var]=get_z_rho125(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*z_max_bvf')
    [lat,lon,mask,var]=get_z_max_bvf(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*z_max_dTdZ')
    [lat,lon,mask,var]=get_z_max_dtdz(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*z_20C')
    [lat,lon,mask,var]=get_z_20C(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*z_15C')
    [lat,lon,mask,var]=get_z_15C(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*z_sig27')
    [lat,lon,mask,var]=get_z_sig27(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*z_sig26')
    [lat,lon,mask,var]=get_z_sig26(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*Lorbacher_MLD')
    [lat,lon,mask,var]=get_Lorbacher_MLD(hisfile,gridfile,tindex,coef);
  elseif strcmp(vname,'*rfactor')
    [lat,lon,mask,var]=get_rfac(hisfile,gridfile,tindex,coef);
  else 
    error('bad luck !')
  end 
else
  [type,vlev]=get_type(hisfile,vname,vlevel);
  [lat,lon,mask]=read_latlonmask(gridfile,type);
  var=coef*mask.*get_hslice(hisfile,gridfile,vname,...
  tindex,vlev,type);
end
%
% Remove boundary values
%
lat=rempoints(lat,rempts);
lon=rempoints(lon,rempts);
mask=rempoints(mask,rempts);
var=rempoints(var,rempts);
%
% End
%
return
