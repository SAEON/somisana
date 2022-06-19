function test_bry(bry_file,grid_file,tracer,l,obc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Test the bry (boundary) files.
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
%  Updated    1-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Get the grid
%
nc=netcdf(grid_file,'r');
pm=nc{'pm'}(:);
pn=nc{'pn'}(:);
h=nc{'h'}(:);
if strcmp(tracer,'u')
    lat=nc{'lat_u'}(:);
    lon=nc{'lon_u'}(:);
    mask=nc{'mask_u'}(:);
    pm=rho2u_2d(pm);
    pn=rho2u_2d(pn);
    h=rho2u_2d(h);
elseif strcmp(tracer,'v')
    lat=nc{'lat_v'}(:);
    lon=nc{'lon_v'}(:);
    mask=nc{'mask_v'}(:);
    pm=rho2v_2d(pm);
    pn=rho2v_2d(pn);
    h=rho2v_2d(h);
else
    lat=nc{'lat_rho'}(:);
    lon=nc{'lon_rho'}(:);
    mask=nc{'mask_rho'}(:);
end
[M L]=size(lon);
mask=nc{'mask_rho'}(:);
mask(mask==0)=NaN;
close(nc)
%
nc=netcdf(bry_file,'r');
theta_s=nc{'theta_s'}(:);
if isempty(theta_s)
    theta_s=nc.theta_s(:);
    theta_b=nc.theta_b(:);
    hc=nc.hc(:);
else
    theta_b=nc{'theta_b'}(:);
    hc=nc{'hc'}(:);
    vtransform=nc{'Vtransform'}(:);
    if  ~exist('vtransform')
        vtransform=1; %Old Vtransform
        disp([' NO VTRANSFORM parameter found'])
        disp([' USE TRANSFORM default value vtransform = 1'])
    end
end
%
for obcndx=1:4
    if obc(obcndx)==1
        if obcndx==1
            disp(' Plot southern boundary...')
            suffix='south';
            icroco=(1:L);
            jcroco=1;
        elseif obcndx==2
            disp(' Plot eastern boundary...')
            suffix='east';
            icroco=L;
            jcroco=(1:M);
        elseif obcndx==3
            disp(' Plot northern boundary...')
            suffix='north';
            icroco=(1:L);
            jcroco=M;
        elseif obcndx==4
            disp(' Plot western boundary...')
            suffix='west';
            icroco=1;
            jcroco=(1:M);
        end
        subplot(2,2,obcndx)
        topo=squeeze(h(jcroco,icroco));
        mask_vert=squeeze(mask(jcroco,icroco));
        if (obcndx==1 | obcndx==3)
            dx=1./squeeze(pm(jcroco,icroco));
        else
            dx=1./squeeze(pn(jcroco,icroco));
        end
        temp=squeeze(nc{[tracer,'_',suffix]}(l,:,:));
        [Nz,Nx]=size(temp);
        z=squeeze(zlevs(topo,0*topo,theta_s,theta_b,hc,Nz,'r',vtransform));
        x1=0*topo;
        for i=2:Nx
            x1(i)=x1(i-1)+0.5*(dx(i)+dx(i-1));
        end
        x=zeros(Nz,Nx);
        masksection=zeros(Nz,Nx);
        for i=1:Nx
            for k=1:Nz
                x(k,i)=x1(i);
                masksection(k,i)=mask_vert(i);
            end
        end
        x1=x1/1000;
        x=x/1000;
        temp=masksection.*temp;
        % $$$     disp(['Size x =   ',num2str(size(x))])
        % $$$     disp(['Size z =   ',num2str(size(z))])
        % $$$     disp(['Size temp =',num2str(size(temp))])
        pcolor(x,z,temp)
        colorbar
        shading interp
        hold on
        plot(x1,-topo,'k')
        hold off
        title([tracer,' ',suffix,' - time index=',num2str(l)])
    end
end
close(nc)

return


