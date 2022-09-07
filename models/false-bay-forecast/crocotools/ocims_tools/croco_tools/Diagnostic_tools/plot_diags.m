function plot_diags
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Plot the averaged quantities from a CROCO simulation.
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    10-Sep-2006 by Pierrick Penven
%  Updated    24-Oct-2006 by Pierrick Penven (Generalization to all tracers)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all

load('croco.mat')

z0=nan;  % compute average above z0 
         % (if z0=nan get the volume averaged)
         % (if z0=0   get the surface averaged)

figure('Units','centimeters',...
       'Position',[1 1 17 29],...
       'PaperPosition',[1 1 17 29],...
       'PaperUnits','centimeters')

time=time/(24*3600*360);
tmin=round(min(time))
tmax=round(max(time))
tndx=max(find(time<=(tmax+tmin)/2))
n=nvars+3;
bottom=0.04;
left=0.08;
width=1-2*left;
height=(1-(n+1)*bottom)/n;
bot=bottom;
cff=0.15;

%
% Loop on tracers
%
for i=1:nvars
  subplot('position',[left bot width height])
  if z0==0
    eval(['plot_var(time,surf',char(varnames(i)),',tndx,cff)'])
    title(['Surface averaged ',char(varnames(i))])
  elseif isfinite(z0)
    eval(['plot_var(time,avgz0',char(varnames(i)),',tndx,cff)'])
    title(['Volume averaged ',char(varnames(i)),' above z0=',num2str(z0)])
  else
    eval(['plot_var(time,avg',char(varnames(i)),',tndx,cff)'])
    title(['Volume averaged ',char(varnames(i))])
  end
  bot=bot+bottom+height;
end
%
% Plot the other time series
%
subplot('position',[left bot width height])
plot_var(time,avgke*1e4,tndx,cff)
axis([tmin tmax  0 max(avgke*1e4)*(1+2*cff)])
title('Volume averaged kinetic energy [cm^2.s^{-2}]')

bot=bot+bottom+height;

subplot('position',[left bot width height])
plot_var(time,surfke*1e4,tndx,cff)
axis([tmin tmax  0 max(surfke*1e4)*(1+2*cff)])
title('Surface averaged kinetic energy [cm^2.s^{-2}]')

bot=bot+bottom+height;

subplot('position',[left bot width height])
plot_var(time,V-mean(V)*1e-9,tndx,cff)
title('Volume anomaly [km^3]')

return

function plot_var(time,var,tndx,cff)
plot(time,var,'k')
hold on
plot(time,0*time+mean(var(tndx:end)),'r');
hold off
varmin=min(var);
varmax=max(var);
dvar=varmax-varmin;
axis([round(min(time)) round(max(time))  varmin-cff*dvar varmax+cff*dvar])
return
