% 
% Compute the kinetic energy transfer:
% 
% KmKe= -[ <up up> dubar/dx + <up vp>  dubar/dy  + <up Wp>  dubar/dz + ....
%          <vp up> dvbar/dx + <vp vp>  dvbar/dy  + <vp Wp>  dvbar/dz ]
%
% KmKe= -[ <up up> dubar/dx + <up vp>  dubar/dy + <up Wp>  dubar/dz + ....
%          <vp up> dvbar/dx + <vp vp>  dvbar/dy   + <vp Wp>  dvbar/dz ]
%     =  -[ <up up  dubar/dx > + <up vp  dubar/dy >+ <up Wp dubar/dz >+ ....
%           <vp up dvbar/dx >+ <vp vp  dvbar/dy >  + <vp Wp  dvbar/dz >]
%     =  - <up up  dubar/dx  + up vp  dubar/dy + up Wp dubar/dz + ....
%           vp up dvbar/dx +   vp vp  dvbar/dy + vp Wp  dvbar/dz >
%     =  - < up(up  dubar/dx  + vp  dubar/dy + Wp dubar/dz) + 
%            vp(up dvbar/dx + vp dvbar/dy  + Wp  dvbar/dz) >
%
%     =  -<up(up.grad(ubar))+vp(up.grad(vbar))>
%
% Advection operators are used. Much easier in sigma coordinates.
%
% This is the method used in
% Djakouré, S., P. Penven, B. Bourlès, J. Veitch and V. Koné, 
% Coastally trapped eddies in the north of the Gulf of Guinea, 2014, J. Geophys. Res,
% DOI: 10.1002/2014JC010243
%
% For comparison, a simple KmKe2 is computed:
% 
%  KmKe2= -[ <up up> dubar/dx|s=cst + <up vp>  dubar/dy|s=cst + ....
%            <vp up> dvbar/dx|s=cst + <vp vp>  dvbar/dy|s=cst ]
%
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
%  Pierrick Penven, 2014
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
warning off
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Directory and file names
%
directory='SCRATCH/';
model='croco';
filetype='avg';  % 'his' or 'avg'
outfile='kmke.mat';
Ymin=5;
Ymax=10;
Yorig=nan;
endf='.nc';
vtransform=1;  %!!!! warning !!!
offomega=0; % 1: compute W from u and v
H0=-100; % depth of integration
%
% possiblity to compute KmKe for a given season (1 to 4)
% or for the annual mean (season=5).
% 
season=5;
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
Mmin=1+((season-1)*3);
Mmax=Mmin+2;
if season==5
 Mmin=1;
 Mmax=12;
end
%
% Read the grid
%
fname=[directory,model,'_',filetype,'_Y',num2str(Ymin),'M',num2str(Mmin),endf];
nc=netcdf(fname);
theta_s=nc.theta_s(:);
theta_b=nc.theta_b(:);
hc=nc.hc(:);
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
h=nc{'h'}(:);
maskr=nc{'mask_rho'}(:);
lon=nc{'lon_rho'}(:);
lat=nc{'lat_rho'}(:);
close(nc)
%
[M,L]=size(pm);
[masku,maskv,maskp]=uvp_mask(maskr);

%
% get the seasonal (or annual) mean
%

Sname=[directory,model,'_Smean',endf]
nc=netcdf(Sname);
N=length(nc('s_rho'));
zetab=squeeze(nc{'zeta'}(season,:,:));
ub=squeeze(nc{'u'}(season,:,:,:));
vb=squeeze(nc{'v'}(season,:,:,:));
if offomega==0 
  Wb=squeeze(nc{'omega'}(season,:,:,:));
else
  [Wvlc,Wb]=get_wvelocity(zetab,ub,vb,h,pm,pn,theta_s,theta_b,hc,N,vtransform);
end
close(nc)

%
% gradients of ubar and vbar
%

dudx=zeros(N,M,L);
dudx(:,:,2:end-1)=tridim(pm(:,2:end-1),N).*(ub(:,:,2:end)-ub(:,:,1:end-1));
dudy=zeros(N,M,L);
cff=ub(:,2:end,:)-ub(:,1:end-1,:);
dudy(:,2:end-1,2:end-1)=tridim(pn(2:end-1,2:end-1),N).*0.25.*...
             (cff(:,2:end,2:end)  +cff(:,1:end-1,2:end)+...
              cff(:,2:end,1:end-1)+cff(:,1:end-1,1:end-1));
dvdx=zeros(N,M,L);
cff=vb(:,:,2:end)-vb(:,:,1:end-1);
dvdx(:,2:end-1,2:end-1)=tridim(pm(2:end-1,2:end-1),N).*0.25.*...
             (cff(:,2:end,2:end)  +cff(:,1:end-1,2:end)+...
              cff(:,2:end,1:end-1)+cff(:,1:end-1,1:end-1));
dvdy=zeros(N,M,L);
dvdy(:,2:end-1,:)=tridim(pn(2:end-1,:),N).*(vb(:,2:end,:)-vb(:,1:end-1,:));
%
dn_u=tridim(2./(pn(:,1:end-1)+pn(:,2:end)),N);
dm_v=tridim(2./(pm(1:end-1,:)+pm(2:end,:)),N);
omn_w=tridim(1./(pm.*pn),N+1);

%
% Time loop
%

KmKe=zeros(N,M,L);
uu=zeros(N,M,L);
uv=zeros(N,M,L);
vu=zeros(N,M,L);
vv=zeros(N,M,L);
%
nindex=0;
%
for Y=Ymin:Ymax 
  for M=Mmin:Mmax
    fname=[directory,model,'_',filetype,'_Y',num2str(Y),'M',num2str(M),endf];
    disp(['Opening : ',fname])
    nc=netcdf(fname);
    ntime=length(nc('time'));
%
    for tindex=1:ntime
      disp([' index : ',num2str(tindex),' of ',num2str(ntime)])
      zeta=squeeze(nc{'zeta'}(tindex,:,:));
      u=squeeze(nc{'u'}(tindex,:,:,:));
      v=squeeze(nc{'v'}(tindex,:,:,:));
      if offomega==0 
        Wp=squeeze(nc{'omega'}(season,:,:,:))-Wb;
      else
        [Wvlc,Wrk]=get_wvelocity(zeta,u,v,h,pm,pn,theta_s,theta_b,hc,N,vtransform);
        Wp=Wrk-Wb;
      end
      up=u-ub;
      vp=v-vb;
%
% Compute Hz
% 
      zw=zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
      Hz=zw(2:N+1,:,:)-zw(1:N,:,:); 
      mnoHz=tridim(pm.*pn,N)./Hz;

%
% Compute the advection terms
%

      upXgradub=mnoHz.*croco_advection(masku,maskv,maskr,Hz,dn_u.*up,dm_v.*vp,omn_w.*Wp,u2rho_3d(ub));
      upXgradvb=mnoHz.*croco_advection(masku,maskv,maskr,Hz,dn_u.*up,dm_v.*vp,omn_w.*Wp,v2rho_3d(vb));
%
      up=u2rho_3d(up);
      vp=v2rho_3d(vp);
%
      KmKe=KmKe - up.*upXgradub - vp.*upXgradvb;
      nindex=nindex+1;
%
      uu=uu+up.*up;
      uv=uv+up.*vp;
      vu=vu+vp.*up;
      vv=vv+vp.*vp;
%
    end
%
    close(nc)
  end
end

%
% Compute KmKe
%

KmKe=KmKe/nindex;

%
% Compute KmKe2
%

uu=uu/nindex;
uv=uv/nindex;
vu=vu/nindex;
vv=vv/nindex;
KmKe2=-(uu.*dudx+uv.*dudy+vu.*dvdx+vv.*dvdy);

%
% Verticaly integrate
%

zr=zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
zw=zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
mask=maskr;
mask(mask==0)=NaN;
[KmKe2D,h0]=vintegr2(KmKe,zw,zr,H0,0);
[KmKe2D2,h0]=vintegr2(KmKe2,zw,zr,H0,0);

%
% Save
%

save(outfile,'lon','lat','mask','KmKe','KmKe2',...
     'zr','zw','H0','KmKe2D','KmKe2D2')

%
% Figures
%

figure(1)
pcolor(lon,lat,mask.*1e6.*KmKe2D)
axis image
shading flat
caxis([-4 4])
colorbar
title('KmKe')

figure(2)
pcolor(lon,lat,mask.*1e6.*KmKe2D2)
axis image
shading flat
caxis([-4 4])
colorbar
title('KmKe2')
