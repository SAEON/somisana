function test_forcing(frcname,grdname,thefield,thetime,skip,coastfileplot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot a variable from the forcing file 
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
%  Updated    31-Aug-2006 by Pierrick Penven
%  Updated    25-Oct-2006 by Pierrick Penven (uwnd and vwnd)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
isoctave=exist('octave_config_info');
niceplot=1;
i=0;
for time=thetime
  i=i+1;
  
  subplot(2,length(thetime)/2,i)

  nc=netcdf(frcname,'r');
  stime=nc{'sms_time'}(time);
  if isempty(stime)
    stime=nc{'bulk_time'}(time);
    if isempty(stime)
      error('TEST_FORCING: Is it a forcing or a bulk file ?')
    end
    u=nc{'uwnd'}(time,:,:);
    v=nc{'vwnd'}(time,:,:);
    if thefield(1:3)=='spd'
      field=sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
      fieldname='wind speed';
    else
      field=nc{thefield}(time,:,:);
      fieldname=nc{thefield}.long_name(:);
    end
  else  
    u=nc{'sustr'}(time,:,:);
    v=nc{'svstr'}(time,:,:);
    if thefield(1:3)=='spd'
      field=sqrt((u2rho_2d(u)).^2+(v2rho_2d(v)).^2);
      fieldname='wind stress';
    else
      field=nc{thefield}(time,:,:);
      fieldname=nc{thefield}.long_name(:);
    end
  end
  close(nc);
%
% Read the grid
%
nc=netcdf(grdname,'r');
  if strcmp(thefield,'sustr') | strcmp(thefield,'uwnd')
    lon=nc{'lon_u'}(:);
    lat=nc{'lat_u'}(:);
    mask=nc{'mask_u'}(:);
  elseif strcmp(thefield,'svstr') | strcmp(thefield,'vwnd')
    lon=nc{'lon_v'}(:);
    lat=nc{'lat_v'}(:);
    mask=nc{'mask_v'}(:);
  else
    lon=nc{'lon_rho'}(:);
    lat=nc{'lat_rho'}(:);
    mask=nc{'mask_rho'}(:);
  end
  angle=nc{'angle'}(:);
  close(nc);
  mask(mask==0)=NaN;
%
% compute the vectors
% 
  [ured,vred,lonred,latred,speed]=uv_vec2rho(u,v,lon,lat,angle,...
                                             mask,skip,[0 0 0 0]);
%
% Make the plot
%  
if (isoctave == 0);
  if niceplot==1
    domaxis=[min(min(lon)) max(max(lon)) min(min(lat)) max(max(lat))];
    m_proj('mercator',...
       'lon',[domaxis(1) domaxis(2)],...
       'lat',[domaxis(3) domaxis(4)]);

    m_pcolor(lon,lat,mask.*field);
    shading flat
    drawnow
    colorbar
    hold on
    m_quiver(lonred,latred,ured,vred,'k');
    if ~isempty(coastfileplot)
      m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
    end
    hold off
    title([fieldname,' - day: ',num2str(stime)])
    m_grid('box','fancy',...
           'xtick',5,'ytick',5,'tickdir','out',...
           'fontsize',7);
  else
    imagesc(mask.*field)
    title([fieldname,' - day: ',num2str(stime)])
  end
end
end

