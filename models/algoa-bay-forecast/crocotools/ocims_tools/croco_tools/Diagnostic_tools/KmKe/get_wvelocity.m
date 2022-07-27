function [Wvlc,Wrk]=get_wvelocity(zeta,u,v,h,pm,pn,theta_s,theta_b,hc,N,vtransform)
%
% Get the vertical physical velocity from the horizontal flow.
% Adapted from  wvlcty.F
%
% Outputs: 
%
%   Wwrk=omega (at w points)
%   Wvlc=w (at rho points)
%
% Pierrick Penven 2010
%

%
% Vertical grid
%
zr=zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
zw=zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
Hz=zw(2:end,:,:)-zw(1:end-1,:,:);
%
on_u=tridim(2./(pn(:,2:end)+pn(:,1:end-1)),N);
Huon=0.5.*(Hz(:,:,2:end)+Hz(:,:,1:end-1))...
           .*on_u.*u;
om_v=tridim(2./(pm(2:end,:)+pm(1:end-1,:)),N);
Hvom=0.5.*(Hz(:,2:end,:)+Hz(:,1:end-1,:))...
        .*om_v.*v;
%
% Compute omega
%
Wrk=0*zw;
for k=1:N
  Wrk(k+1,2:end-1,2:end-1)=squeeze(Wrk(k,2:end-1,2:end-1))...
                          -pm(2:end-1,2:end-1).*pn(2:end-1,2:end-1).*...
			   squeeze(...
                            Huon(k,2:end-1,2:end)-Huon(k,2:end-1,1:end-1)...
                           +Hvom(k,2:end,2:end-1)-Hvom(k,1:end-1,2:end-1));
end
%
% Compute w
%
Wvlc=0*zr;
Wvlc(N,:,:)=+0.375*Wrk(N+1,:,:) +0.75*Wrk(N,:,:)-0.125*Wrk(N-1,:,:);
Wvlc(2:N-1,:,:)=+0.5625*(Wrk(3:N,:,:)+Wrk(2:N-1,:,:))...
                -0.0625*(Wrk(4:N+1,:,:)+Wrk(1:N-2,:,:));
Wvlc(1,:,:)=-0.125*Wrk(3,:,:)+0.75*Wrk(2,:,:)+0.375*Wrk(1,:,:);
%
Wxi =u.*tridim(pm(:,2:end)+pm(:,1:end-1),N).*(zr(:,:,2:end)-zr(:,:,1:end-1));
Weta=v.*tridim(pn(2:end,:)+pn(1:end-1,:),N).*(zr(:,2:end,:)-zr(:,1:end-1,:));
%
Wvlc(:,2:end-1,2:end-1)=Wvlc(:,2:end-1,2:end-1)+...
                       0.25.*(Wxi(:,2:end-1,1:end-1)+Wxi(:,2:end-1,2:end)+...
		              Weta(:,1:end-1,2:end-1)+Weta(:,2:end,2:end-1));
Wvlc(:,1,:)=Wvlc(:,2,:);
Wvlc(:,end,:)=Wvlc(:,end-1,:);
Wvlc(:,:,1)=Wvlc(:,:,2);
Wvlc(:,:,end)=Wvlc(:,:,end-1);
%
