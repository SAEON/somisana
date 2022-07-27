function test_forcing(bioname,grdname,thefield,thetime,skip,coastfileplot)
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
niceplot=1;
i=0;
for time=thetime
  i=i+1;
  
  subplot(2,length(thetime)/2,i)

  nc=netcdf(bioname,'r');
  stime=nc{'dust_time'}(time);
  if isempty(stime)
    error('TEST_BIOFORCING: dust_time missing ?')
  end
  field=nc{thefield}(time,:,:);
  fieldname=nc{thefield}.long_name(:);
  close(nc);
%
% Read the grid
%
nc=netcdf(grdname,'r');
  lon=nc{'lon_rho'}(:);
  lat=nc{'lat_rho'}(:);
  mask=nc{'mask_rho'}(:);
  angle=nc{'angle'}(:);
  close(nc);
  mask(mask==0)=NaN;
%
% Make the plot
%  
  if niceplot==1
    domaxis=[min(min(lon)) max(max(lon)) min(min(lat)) max(max(lat))];
    m_proj('mercator',...
       'lon',[domaxis(1) domaxis(2)],...
       'lat',[domaxis(3) domaxis(4)]);

    m_pcolor(lon,lat,mask.*field)
    shading flat
    colorbar
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


