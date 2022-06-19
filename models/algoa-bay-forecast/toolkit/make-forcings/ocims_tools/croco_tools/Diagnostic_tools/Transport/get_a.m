function A=get_a(u,v,psi0,psi1,island,pm,pn)
%
% calcul de A : psi=psi0+A*psi1
%
pm_u=rho2u_2d(pm);
pm_v=rho2v_2d(pm);
pn_u=rho2u_2d(pn);
pn_v=rho2v_2d(pn);
%
% Get the circulation around the island due to psi0
%
psi_r=psi2rho(psi0);
u_v=-pn_v.*(psi_r(2:end,:)-psi_r(1:end-1,:));
v_u= pm_u.*(psi_r(:,2:end)-psi_r(:,1:end-1));
%
circ=(v_u(2:end-1,1:end-1)./pn_u(2:end-1,1:end-1)) + ...
     (u_v(2:end,2:end-1)./pm_v(2:end,2:end-1)) - ...
     (v_u(2:end-1,2:end)./pn_u(2:end-1,2:end)) - ...
     (u_v(1:end-1,2:end-1)./pm_v(1:end-1,2:end-1));
A0=sum(circ(island==1));     
%
% Get the circulation around the island due to psi1
%
psi_r=psi2rho(psi1);
u_v=-pn_v.*(psi_r(2:end,:)-psi_r(1:end-1,:));
v_u= pm_u.*(psi_r(:,2:end)-psi_r(:,1:end-1));
%
circ=(v_u(2:end-1,1:end-1)./pn_u(2:end-1,1:end-1)) + ...
     (u_v(2:end,2:end-1)./pm_v(2:end,2:end-1)) - ...
     (v_u(2:end-1,2:end)./pn_u(2:end-1,2:end)) - ...
     (u_v(1:end-1,2:end-1)./pm_v(1:end-1,2:end-1));
A1=sum(circ(island==1));     
%
% Get the total circulation around the island
%
v_u=v2u(v);
u_v=u2v(u);
circ=(v_u(2:end-1,1:end-1)./pn_u(2:end-1,1:end-1)) + ...
     (u_v(2:end,2:end-1)./pm_v(2:end,2:end-1)) - ...
     (v_u(2:end-1,2:end)./pn_u(2:end-1,2:end)) - ...
     (u_v(1:end-1,2:end-1)./pm_v(1:end-1,2:end-1));
Atotal=sum(circ(island==1));     
%
% Get A
%
A=(Atotal-A0)/A1;
%
return
