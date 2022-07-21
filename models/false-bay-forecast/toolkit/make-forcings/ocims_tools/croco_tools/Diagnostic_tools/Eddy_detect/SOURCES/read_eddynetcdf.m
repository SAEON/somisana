function [ID,time,lon,lat,Area,Energy,Vorticity,...
          Radius,MaxSSH,MinSSH,MeanSSH,Amplitude,U,V]=read_eddynetcdf(nc,indx)
%
% Read eddies properties from a netcdf file
%
time=nc{'time'}(indx);
ID=nc{'ID'}(indx);
lon=nc{'lon'}(indx);
lat=nc{'lat'}(indx);
Area=nc{'Area'}(indx);
Energy=nc{'Energy'}(indx);
Vorticity=nc{'Vorticity'}(indx);
Radius=nc{'Radius'}(indx);
MaxSSH=nc{'MaxSSH'}(indx);
MinSSH=nc{'MinSSH'}(indx);
MeanSSH=nc{'MeanSSH'}(indx);
Amplitude=nc{'Amplitude'}(indx);
U=nc{'U'}(indx);
V=nc{'V'}(indx);

return
