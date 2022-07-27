function [sc_r,Cs_r,sc_w,Cs_w] = scoordinate(theta_s,theta_b,N,hc,vtransform);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin <4
    vtransform = 1;  %Old vtransform
    hc=[];
elseif nargin <5
    vtransform = 1;  %Old vtransform
end
% Set S-Curves in domain [-1 < sc < 0] at vertical W- and RHO-points.
sc_r=zeros(N,1);
Cs_r=zeros(N,1);
sc_w=zeros(N+1,1);
Cs_w=zeros(N+1,1);

if (vtransform == 2)
    ds=1./N;
    sc_r= ds*([1:N]-N-0.5);
    Cs_r=csf(sc_r, theta_s,theta_b);
    %
    sc_w(1) = -1.0;
    sc_w(N+1) =  0;
    Cs_w(1) = -1.0;
    Cs_w(N+1) =  0;
    sc_w(2:N) = ds*([1:N-1]-N);
    Cs_w=csf(sc_w, theta_s,theta_b);
else
    cff1=1./sinh(theta_s);
    cff2=0.5/tanh(0.5*theta_s);
    sc_w=((0:N)-N)/N;
    Cs_w=(1.-theta_b)*cff1*sinh(theta_s*sc_w)...
        +theta_b*(cff2*tanh(theta_s*(sc_w+0.5))-0.5);
    %
    sc_r=((1:N)-N-0.5)/N;
    Cs_r=(1.-theta_b)*cff1*sinh(theta_s*sc_r)...
        +theta_b*(cff2*tanh(theta_s*(sc_r+0.5))-0.5);
end
return
