function ke=ke_aviso(pm,pn,f,zeta);
%
[Mp,Lp]=size(zeta);
M=Mp-1;
Mm=M-1;
L=Lp-1;
Lm=L-1;
%
gof=9.81./f;
%
mask=isfinite(zeta);
[umask,vmask,pmask]=uvp_mask(mask);
%
u=-gof.*v2rho_2d(vmask.*(zeta(2:end,1:end)-zeta(1:end-1,1:end))...
              .*0.5.*(pn(2:end,1:end)+pn(1:end-1,1:end)));
v=gof.*u2rho_2d(umask.*(zeta(1:end,2:end)-zeta(1:end,1:end-1))...
              .*0.5.*(pm(1:end,2:end)+pm(1:end,1:end-1)));
%
ke=0.5.*(u.^2+v.^2);
return

