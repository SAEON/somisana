function rmavgssh(bryname,grdname,obc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  Remove the averaged SSH in the boundary (bry) files.
% 
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ');
disp('Remove averaged SSH ...');

ng=netcdf(grdname,'r');
L=length(ng('xi_rho'));
M=length(ng('eta_rho'));

nc=netcdf(bryname,'write');
time=nc{'bry_time'}(:);
tlen=length(time);


for l=1:tlen
%for l=1:1
  tssh=0;
  S=0;
  for obcndx=1:4
    if obc(obcndx)==1
      if obcndx==1
        pm=ng{'pm'}(1,:);
        pn=ng{'pn'}(1,:);
        rmask=ng{'mask_rho'}(1,:);
        suffix='_south';
      elseif obcndx==2
        pm=(ng{'pm'}(:,L))';
        pn=(ng{'pn'}(:,L))';
        rmask=(ng{'mask_rho'}(:,L))';
        suffix='_east';
      elseif obcndx==3
        pm=ng{'pm'}(M,:);
        pn=ng{'pn'}(M,:);
        rmask=ng{'mask_rho'}(M,:);
        suffix='_north';
      elseif obcndx==4
        pm=(ng{'pm'}(:,1))';
        pn=(ng{'pn'}(:,1))';
        rmask=(ng{'mask_rho'}(:,1))';
        suffix='_west';
      end
      Nx=length(pm);
      ssh=nc{['zeta',suffix]}(l,:);
      tssh=tssh+sum(rmask.*ssh./(pm.*pn));
      S=S+sum(rmask./(pm.*pn)); 
    end
  end
  avgssh=tssh./S;
  for obcndx=1:4
    if obc(obcndx)==1
      if obcndx==1
        suffix='_south';
      elseif obcndx==2
        suffix='_east';
      elseif obcndx==3
        suffix='_north';
      elseif obcndx==4
        suffix='_west';
      end
      ssh=nc{['zeta',suffix]}(l,:);
      nc{['zeta',suffix]}(l,:)=ssh-avgssh;
    end
  end
end
close(ng)
close(nc)
