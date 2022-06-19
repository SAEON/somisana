function pv = ertel(fname,gname,lambda,tindex);                     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   epv    - The ertel potential vorticity with respect to property 'lambda'
%
%                                       [ curl(u) + f ]
%   -  epv is given by:           EPV = --------------- . del(lambda)
%                                            rho
%
%   -  pvi,pvj,pvk - the x, y, and z components of the potential vorticity.
%
%   -  Ertel PV is calculated on horizontal rho-points, vertical w-points.
%
%   fname - The CROCO NetCDF history file.
%   gname - The CROCO NetCDF grid file.
%   lambda - The property 'lambda' above.  (Must be defined on rho-points.)
%   tindex   - The time index at which to calculate the potential vorticity.
%
% Adapted from rob hetland.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Depths
%
z_r=get_depths(fname,gname,tindex,'r');
%
% Grid parameters
%
[N,M,L]=size(z_r);
nc=netcdf(fname);
pm=tridim(nc{'pm'}(:),N);
pn=tridim(nc{'pn'}(:),N);
f=tridim(nc{'f'}(:),N);
rho0=nc.rho0(:);
%
% 3D variables
%
u(:,:,:)=nc{'u'}(tindex,:,:,:);
v(:,:,:)=nc{'v'}(tindex,:,:,:);
lbd(:,:,:) = nc{lambda}(tindex,:,:,:);
if (lambda == 'rho' & ~isempty(lbd))
  lbd=lbd+1000;
end
if isempty(lbd)
  t(:,:,:)=nc{'temp'}(tindex,:,:,:);
  s(:,:,:)=nc{'salt'}(tindex,:,:,:);
  lbd=rho_eos(t,s,z_r);
%  lbd=rho_eos(t,s,0);
  clear t s
end
close(nc)
%
% Derivatives.
%
dz_r = z_r(2:end,:,:)-z_r(1:end-1,:,:);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Ertel potential vorticity, term 1: [f + (dv/dx - du/dy)]*dlambda/dz
%
% Compute d(v)/d(xi) at PSI-points.
%
dvdxi=(v(:,1:end,2:end)-v(:,1:end,1:end-1)).*...
             0.25.*(pm(:,1:end-1,2:end)+pm(:,2:end,2:end)...
                   +pm(:,1:end-1,1:end-1)+pm(:,2:end,1:end-1));
%
%  Compute d(u)/d(eta) at PSI-points.
%
dudeta=(u(:,2:end,1:end)-u(:,1:end-1,1:end)).*...
             0.25.*(pn(:,1:end-1,2:end)+pn(:,2:end,2:end)...
                   +pn(:,1:end-1,1:end-1)+pn(:,2:end,1:end-1));
%
%  Compute Ertel potential vorticity <k hat> at horizontal RHO-points and
%  vertical W-points.
%
omega = dvdxi - dudeta;
pvk = ( f(2:end,2:end-1,2:end-1)+... 
          0.125.*( omega(1:end-1,2:end,1:end-1)...
                  +omega(1:end-1,2:end,2:end)...
                  +omega(1:end-1,1:end-1,1:end-1)...
                  +omega(1:end-1,1:end-1,2:end)...
		  +omega(2:end,2:end,1:end-1)...
                  +omega(2:end,2:end,2:end)...
                  +omega(2:end,1:end-1,1:end-1)...
                  +omega(2:end,1:end-1,2:end))).*...
           (lbd(2:end,2:end-1,2:end-1)...
           -lbd(1:end-1,2:end-1,2:end-1))./...
          dz_r(:,2:end-1,2:end-1);
clear dvdxi dudeta omega 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Ertel potential vorticity, term 2: (dv/dz)*(drho/dx)
%
%  Compute d(v)/d(z) at horizontal V-points and vertical W-points
%
dvdz=(v(2:end,:,:)-v(1:end-1,:,:))./...
           (0.5.*(dz_r(:,1:end-1,:)+dz_r(:,2:end,:)));
%
%  Compute d(lambda)/d(xi) at horizontal U-points and vertical RHO-points
%
dldxi = (lbd(:,:,2:end)-lbd(:,:,1:end-1)).*...
          0.5.*(pm(:,:,2:end)+pm(:,:,1:end-1));
%
%  Add in term 2 contribution to Ertel potential vorticity <i hat>.
%
pvi =  0.5 .*(dvdz(:,2:end,2:end-1)+dvdz(:,1:end-1,2:end-1))...
     .*0.25.*( dldxi(2:end,2:end-1,1:end-1)+dldxi(2:end,2:end-1,2:end)...
              +dldxi(1:end-1,2:end-1,1:end-1)+dldxi(1:end-1,2:end-1,2:end));
clear dvdz dldxi
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Ertel potential vorticity, term 3: (du/dz)*(drho/dy)
%
%  Compute d(u)/d(z) at horizontal U-points and vertical W-points
%
dudz=(u(2:end,:,:)-u(1:end-1,:,:))./...
           (0.5.*(dz_r(:,:,1:end-1)+dz_r(:,:,2:end)));
%
%  Compute d(rho)/d(eta) at horizontal V-points and vertical RHO-points
%
dldeta = (lbd(:,2:end,:)-lbd(:,1:end-1,:)).*...
          0.5.*(pn(:,2:end,:)+pn(:,1:end-1,:));
%
%  Add in term 3 contribution to Ertel potential vorticity <j hat>.
%
pvj =  0.5 .*(dudz(:,2:end-1,2:end)+dudz(:,2:end-1,1:end-1))...
     .*0.25.*( dldeta(2:end,1:end-1,2:end-1)+dldeta(2:end,2:end,2:end-1)...
              +dldeta(1:end-1,1:end-1,2:end-1)+dldeta(1:end-1,2:end,2:end-1));
clear dudz dldeta
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sum potential vorticity components, and divide by rho0
%
pvi = -pvi./rho0;
pvj =  pvj./rho0;
pvk =  pvk./rho0;
%
pv=NaN*zeros(N+1,M,L);
pv(2:N,2:M-1,2:L-1) = pvi + pvj + pvk;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
