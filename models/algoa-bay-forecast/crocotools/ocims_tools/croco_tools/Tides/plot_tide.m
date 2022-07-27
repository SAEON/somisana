function plot_tide(grdname,frcname,k,cff,skp,coastfileplot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Plot tidal ellipses 
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
%  Copyright (c) 2003-2006 by Patrick Marchesiello
%
%  Updated   5-Oct-2006 by Pierrick Penven
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rad=pi/180.0;
deg=180.0/pi;

niceplot=1;

nc=netcdf(grdname,'r');
rlon=nc{'lon_rho'}(:);
rlat=nc{'lat_rho'}(:);
rmask=nc{'mask_rho'}(:);
rangle=nc{'angle'}(:);
close(nc)
[M,L]=size(rlat);

nc=netcdf(frcname,'r');
tide_Eamp(:,:)=nc{'tide_Eamp'}(k,:,:);
tide_Cmax(:,:)=nc{'tide_Cmax'}(k,1:skp:M,1:skp:L);
tide_Cmin(:,:)=nc{'tide_Cmin'}(k,1:skp:M,1:skp:L);
tide_Cangle(:,:)=rad*nc{'tide_Cangle'}(k,1:skp:M,1:skp:L);
cmpt=nc.components(:);
disp(['Plot tidal component : ',cmpt(3*k-2:3*k)])
close(nc)
slon=rlon(1:skp:M,1:skp:L);
slat=rlat(1:skp:M,1:skp:L);
smask=rmask(1:skp:M,1:skp:L);
rmask(rmask==0)=NaN;

disp(['Max currents: ',num2str(max(max(tide_Cmax)),2),' m/s'])

if niceplot==1

  domaxis=[min(min(rlon)) max(max(rlon)) min(min(rlat)) max(max(rlat))];
  m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)],...
         'lat',[domaxis(3) domaxis(4)]);
  m_pcolor(rlon,rlat,rmask.*tide_Eamp)
  shading flat
  colorbar
  hold on
  m_ellipse(cff*smask.*tide_Cmax,cff*smask.*tide_Cmin,...
           smask.*tide_Cangle,slon,slat,'k');
  if ~isempty(coastfileplot)
    m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
  end
  hold off
  title(['Amplitude [m] of tide : ',cmpt(3*k-2:3*k)])
  m_grid('box','fancy',...
         'xtick',5,'ytick',5,'tickdir','out',...
         'fontsize',7);

else

  pcolor(rlon,rlat,rmask.*tide_Eamp)
  shading flat
  colorbar
  hold on
  ellipse(cff*smask.*tide_Cmax,cff*smask.*tide_Cmin,smask.*tide_Cangle,slon,slat,'k');
  axis([min(min(rlon)) max(max(rlon)) min(min(rlat)) max(max(rlat))])
  title(['Amplitude [m] of tide : ',cmpt(3*k-2:3*k)])
  hold off

end

