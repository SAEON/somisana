function h = smoothgrid(h,maskr,hmin,hmax_coast,hmax,...
                        r_max,n_filter_deep_topo,n_filter_final)
%
%  Smooth the topography to get a maximum r factor = rmax
%
%  n_filter_deep_topo:
%  Number of pass of a selective filter to reduce the isolated
%  seamounts on the deep ocean.
%
%  n_filter_final:
%  Number of pass of a single hanning filter at the end of the
%  procedure to ensure that there is no 2DX noise in the 
%  topography.
%
%  Further Information:  
%  http://www.brest.ird.fr/Roms_tools/
%  
%  This file is part of ROMSTOOLS
%
%  ROMSTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  ROMSTOOLS is distributed in the hope that it will be useful, but
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
%  Contributions of A. Shchepetkin (UCLA), P. Marchesiello (IRD)
%                   and X. Capet (UCLA)
%
%  Updated    Aug-2006 by Pierrick Penven
%  Updated    Dec-2013 by Patrick Marchesiello for wetting-drying
%  Updated    Jun-2017 by Pierrick Penven (update filter)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
[masku,maskv,maskp]=uvp_mask(maskr);
maskr_ext=hann_window(maskr);
maskr_ext(maskr_ext<1)=0;
%
% Cut topography and flood dry cells momentarily
%
h(h<hmin)=hmin;
h(h>hmax)=hmax;
%
%
% 1: Deep Ocean Filter
%
if n_filter_deep_topo>=1
  disp(' Apply a filter on the Deep Ocean to reduce isolated seamounts :')
  disp(['   ',num2str(n_filter_deep_topo),' pass of a selective filter.'])
%
%  Build a smoothing coefficient that is a linear function 
%  of a smooth topography.
%
  coef=h;
  for i=1:8
    coef=hann_window(coef);                  % coef is a smoothed bathy
  end 
  coef=0.125*(coef./max(max(coef)));         % rescale the smoothed bathy
%  
  for i=1:n_filter_deep_topo;
    h=hanning_smoother_coef2d(h,coef);       % smooth with avariable coef
    h(maskr_ext<0.5 &  h>hmax_coast)=hmax_coast;
  end
end
%
%  Apply a selective filter on log(h) to reduce grad(h)/h.
%
disp(' Apply a selective filter on log(h) to reduce grad(h)/h :')
h=log_topo_filter(h,maskr,masku,maskv,maskr_ext,hmin,hmax_coast,r_max);
%
%  Smooth the topography again to prevent 2D noise
%
if n_filter_final>1
  disp(' Smooth the topography a last time to prevent 2DX noise:')
  disp(['   ',num2str(n_filter_final),' pass of a hanning smoother.'])
  for i=1:n_filter_final
    h=hann_window(h);
    h(maskr_ext<0.5 & h>hmax_coast)=hmax_coast;
  end
end
%
h(h<hmin)=hmin;
%
return
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=log_topo_filter(h,maskr,masku,maskv,maskr_ext,hmin,hmax_coast,r_max)
%
% Apply a selective filter on log(h) to reduce grad(h)/h.
% Adapted from Alexander Shchepetkin fortran smooth.F program
% 
% Addition: constraint on maximum depth for the closest point to the mask
% This prevent isobaths to run below the mask, resulting in current detachment. 
% 
OneEights=1/8;
OneThirtyTwo=1/32;
%

r=rfact(h,masku,maskv);
cff=1.4;
r_max=r_max/cff;
i=0;

while r>(r_max*cff)

  i=i+1;

  Lgh=log(h/hmin);
  Lgh(hmin==0)=0;

  lgr_max=log((1.+r_max)./(1.-r_max));  
  lgr1_max=lgr_max*sqrt(2.); 

  grad=(Lgh(:,2:end)-Lgh(:,1:end-1));
  cr=abs(grad);
  FX=grad.*(1.-lgr_max./cr);
  FX(cr<=lgr_max)=0.;

  grad=(Lgh(2:end,2:end)-Lgh(1:end-1,1:end-1));
  cr=abs(grad);
  FX1=grad.*(1.-lgr1_max./cr);
  FX1(cr<=lgr1_max)=0.;

  grad=(Lgh(2:end,:)-Lgh(1:end-1,:));
  cr=abs(grad);
  FE=grad.*(1.-lgr_max./cr);
  FE(cr<=lgr_max)=0.;

  grad=(Lgh(2:end,1:end-1)-Lgh(1:end-1,2:end));
  cr=abs(grad);
  FE1=grad.*(1.-lgr1_max./cr);
  FE1(cr<=lgr1_max)=0.;

  Lgh(2:end-1,2:end-1)=Lgh(2:end-1,2:end-1) + ...
         OneEights*( FX(2:end-1,2:end)-FX(2:end-1,1:end-1)...
                    +FE(2:end,2:end-1)-FE(1:end-1,2:end-1)) +...
         OneThirtyTwo*( FX1(2:end,2:end)-FX1(1:end-1,1:end-1)...
                       +FE1(2:end,1:end-1)-FE1(1:end-1,2:end));

  Lgh(1,:)=Lgh(2,:);
  Lgh(end,:)=Lgh(end-1,:);
  Lgh(:,1)=Lgh(:,2);
  Lgh(:,end)=Lgh(:,end-1);

  h=hmin*exp(Lgh);

  h(maskr_ext<0.5 & h>hmax_coast)=hmax_coast;

  r=rfact(h,masku,maskv);

  if mod(i,20)==0
    disp(['   ',num2str(i),' iterations - r_max = ',num2str(r)]) 
  end
  
end
disp(['   ',num2str(i),' iterations - r_max = ',num2str(r)]) 

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=rfact(h,masku,maskv);

rx=abs(h(:,2:end)-h(:,1:end-1))./(h(:,2:end)+h(:,1:end-1));
ry=abs(h(2:end,:)-h(1:end-1,:))./(h(2:end,:)+h(1:end-1,:));

rx_max=max(rx(masku==1));
ry_max=max(ry(maskv==1));
r=max([rx_max ry_max]);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=hanning_smoother(h);
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;

h(2:Mm,2:Lm)=0.125*(h(1:Mmm,2:Lm)+h(3:M,2:Lm)+...
                       h(2:Mm,1:Lmm)+h(2:Mm,3:L)+...
                       4*h(2:Mm,2:Lm));

h(1,:)=h(2,:);
h(M,:)=h(Mm,:);
h(:,1)=h(:,2);
h(:,L)=h(:,Lm);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=hanning_smoother_coef2d(h,coef);
[M,L]=size(h);
Mm=M-1;
Mmm=M-2;
Lm=L-1;
Lmm=L-2;
h(2:Mm,2:Lm)=coef(2:Mm,2:Lm).*(h(1:Mmm,2:Lm)+h(3:M,2:Lm)+...
                               h(2:Mm,1:Lmm)+h(2:Mm,3:L))...
            +(1-4.*coef(2:Mm,2:Lm)).*h(2:Mm,2:Lm);
h(1,:)=h(2,:);
h(M,:)=h(Mm,:);
h(:,1)=h(:,2);
h(:,L)=h(:,Lm);

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=hann_window(h);
OneFours=1/4;
OneEights=1/8;
OneSixteens=1/16;


h(2:end-1,2:end-1)=OneFours.*h(2:end-1,2:end-1)+...
                   OneEights.*(h(1:end-2,2:end-1)+h(3:end  ,2:end-1)+...
                               h(2:end-1,1:end-2)+h(2:end-1,3:end  ))+...
                 OneSixteens.*(h(1:end-2,1:end-2)+h(3:end  ,3:end  )+...
                               h(1:end-2,3:end  )+h(3:end  ,1:end-2));
h(1,:)=h(2,:);
h(end,:)=h(end-1,:);
h(:,1)=h(:,2);
h(:,end)=h(:,end-1);

return
