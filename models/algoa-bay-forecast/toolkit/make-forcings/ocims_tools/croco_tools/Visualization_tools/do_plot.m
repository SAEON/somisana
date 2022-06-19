function do_plot(lon,lat,var,maxvar,minvar,...
                 pltstyle,colmin,colmax,ncol,...
		 isobath,hisfile,gridfile,tindex,...
                 vlevel,cstep,rempts,cscale)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Do the plot
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
%  Updated 23-Oct-2006 by Pierrick Penven (seawifs colormap)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if maxvar>minvar
  if pltstyle==1
    m_pcolor(lon,lat,var);
    ncol=128;
    shading flat
    colormap(jet)
    caxis([colmin colmax])
  elseif pltstyle==2
    m_contourf(lon,lat,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax]);
%    shading flat
    colormap(jet)
    caxis([colmin colmax])
  elseif pltstyle==3
    [C,h1]=m_contour(lon,lat,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax],'k');
    if ~isempty(h1)
      clabel(C,h1,'LabelSpacing',1000,'Rotation',0)
    end
  elseif pltstyle==4 %gray plot
   dcol=(colmax-colmin)/ncol;
   if minvar <0 
     [C11,h11]=m_contourf(lon,lat,var,[minvar 0]);
      caxis([minvar 0]);
   end
   if colmin < 0
     if minvar < 0 
       hold on
     end
     val=[colmin:dcol:min([colmax -dcol])];
     if length(val)<2
       val=[colmin colmin];
     end  
     [C12,h12]=m_contour(lon,lat,var,val,'k');
     if ~isempty(h12)
       clabel(C12,h12,'LabelSpacing',1000,'Rotation',0)
       set(h12,'LineStyle',':')
     end
     hold off
   end
   if colmax > 0
     if colmin < 0 | minvar < 0
       hold on
     end
     val=[max([dcol colmin]):dcol:colmax];
     if length(val)<2
       val=[colmax colmax];
     end  
     [C13,h13]=m_contour(lon,lat,var,val,'k');
     if ~isempty(h13)
       clabel(C13,h13,'LabelSpacing',1000,'Rotation',0)
     end
     hold off
   end
   hold on
   [C10,h10]=m_contour(lon,lat,var,[0 0],'k');
   if ~isempty(h10)
     clabel(C10,h10,'LabelSpacing',1000,'Rotation',0)
     set(h10,'LineWidth',1.2)
   end
   hold off
   map=0.9+zeros(64,3);
   map2=1+zeros(32,3);
   map(33:64,:)=map2;
   colormap(map)
  elseif pltstyle==5 % Seawifs type plot
    var(var<0.01)=0.01;
    m_pcolor(lon,lat,log10(var));
    shading flat
    caxis([log10(0.01) log10(70)])
    map=zeros(64:3);
    r=0*(1:64);
    r(1:8)=0.5-(1:8)/16;
    r(33:40)=(1:8)/8;
    r(41:60)=1;
    r(57:64)=1-(1:8)/12;
    b=0*(1:64);
    b(1:24)=1;
    b(25:32)=1-(1:8)/8;
    b(1:8)=0.5+(1:8)/16;
    g=0*(1:64);
    g(9:24)=(1:16)/16;
    g(25:40)=1;
    g(41:56)=1-(1:16)/16;
    map(:,1)=r';
    map(:,2)=g';
    map(:,3)=b';
    colormap(map)
  end
end
%
% Add some isobaths
%
if ~isempty(isobath)
  hold on
  eval(['[C2,h2]=draw_topo(gridfile,rempts,['...
  isobath,'],''k--'');']);
  set(h2,'LineWidth',1.5)
  hold off
end
%
% Add the current vectors
%
if cstep~=0;
  hold on
  h3=add_speed_vec(hisfile,gridfile,tindex,...
                   vlevel,cstep,...
		   rempts,cscale);
  set(h3,'Color','k')
  hold off
end
%
% End
%
return
