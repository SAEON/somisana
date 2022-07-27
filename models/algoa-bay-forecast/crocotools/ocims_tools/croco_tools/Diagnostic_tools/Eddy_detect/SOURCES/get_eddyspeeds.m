function [U,V,Dx,Dy]=get_eddyspeeds(dt,lon1,lat1,match1,ismatch1,lon2,lat2)
%
% Loop on eddies that have a match
%
deg2rad=pi/180;
Re=6367442.76;
%Redt=Re/dt;
%
lon1=deg2rad.*lon1;
lat1=deg2rad.*lat1;
lon2=deg2rad.*lon2;
lat2=deg2rad.*lat2;
U=0*lon1;
V=U;
Dx=U;
Dy=U;
%
for i1 = find(ismatch1==1)
  Dx(i1)=Re*(lon2(match1(i1))-lon1(i1)).*cos(0.5*(lat1(i1)+lat2(match1(i1))));
  Dy(i1)=Re*(lat2(match1(i1))-lat1(i1));
end
U=Dx/dt;
V=Dy/dt;

return
