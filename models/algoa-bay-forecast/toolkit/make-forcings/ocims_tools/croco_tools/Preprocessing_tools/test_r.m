clear all
close all

grdname='scoast_his.nc';
theta_s=5.7;
theta_b=0.;
hc=7.;
N=40;
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
nc=netcdf(grdname,'r');
Lp=length(nc('xi_rho'));
Mp=length(nc('eta_rho'));
h=nc{'h'}(:);
close(nc);




z_w=zlevs(h,0.*h,theta_s,theta_b,hc,N,'w',vtransform);

my_rx0=max(max(max(abs((z_w(1,:,2:end)-z_w(1,:,1:end-1))./...
                       (z_w(1,:,2:end)+z_w(1,:,1:end-1))))));
my_rx1=max(max(max(abs((z_w(2:end,:,2:end)-z_w(1:end-1,:,2:end)+...
                        z_w(2:end,:,1:end-1)-z_w(1:end-1,:,1:end-1))./...
                       (z_w(2:end,:,2:end)+z_w(1:end-1,:,2:end)-...
		        z_w(2:end,:,1:end-1)-z_w(1:end-1,:,1:end-1))))));
my_ry0=max(max(max(abs((z_w(:,2:end,1)-z_w(:,1:end-1,1))./...
                       (z_w(:,2:end,1)+z_w(:,1:end-1,1))))));
my_ry1=max(max(max(abs((z_w(:,2:end,2:end)-z_w(:,1:end-1,2:end)+...
                        z_w(:,2:end,1:end-1)-z_w(:,1:end-1,1:end-1))./...
		       (z_w(:,2:end,2:end)+z_w(:,1:end-1,2:end)-...
		        z_w(:,2:end,1:end-1)-z_w(:,1:end-1,1:end-1))))));
my_rx0=max(max(max(abs((h(:,2:end)-h(:,1:end-1))./...
                       (h(:,2:end)+h(:,1:end-1))))));
