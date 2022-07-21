function dist=general_dist(lon1,lat1,R1,X1,MeanSSH1,Ampl1,...
                           lon2,lat2,R2,X2,MeanSSH2,Ampl2,...
                           L0,R0,X0,Z0,A0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% dist=general_dist(lon1,lat1,R1,X1,MeanSSH1,Ampl1,...
%                   lon2,lat2,R2,X2,MeanSSH2,Ampl2,...
%                   L0,R0,X0,Z0,A0)
%  function dist=spheric_dist(lat1,lat2,lon1,lon2)
%
% Compute distances for a simple spheric earth
%
%   input:
%
%  lat1 : latitude of first point (matrix)
%  lon1 : longitude of first point (matrix)
%  lat2 : latitude of second point (matrix)
%  lon2 : longitude of second point (matrix)
%
% Typical scales (squared)
%
%  L0 typical eddy distances
%  R0 typical eddy radius scale
%  X0 typical eddy vorticity scale
%  Z0 typical eddy mean SSH variations
%  A0 typical eddy ssh amplitudes variations
%
%   output:
%  dist : distance from first point to second point (matrix)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
L=spheric_dist(lat1,lat2,lon1,lon2);
%
% Get the adimensionnal distance in the parameter space
%
d1=(L/L0).^2;
d2=((R2-R1)/R0).^2;
d3=((X2-X1)/X0).^2;
d4=((MeanSSH2-MeanSSH1)/Z0).^2;
d5=((Ampl2-Ampl1)/A0).^2;
%
dist=sqrt(d1+d2+d3+d4+d5);
%
% Prevent a Cyclone to become an anticyclone
%
polar_test=sign(X1).*sign(X2);
dist(polar_test<0)=inf;
%
return
