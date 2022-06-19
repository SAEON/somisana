function indx=write_eddynetcdf(nc,indx,ID,time,lon,lat,...
                               Area,Energy,Vorticity,...
                               Radius,MaxSSH,MinSSH,MeanSSH,Amplitude,...
                               Ueddy,Leddy,U,V)
%
% function indx=write_eddynetcdf(nc,indx,ID,time,lon,lat,...
%                               Area,Energy,Vorticity,...
%                               Radius,MaxSSH,MinSSH,MeanSSH,Amplitude,...
%                               Ueddy,Leddy,U,V)
%
%
% wrtie an eddy netcdf file
%
% Pierrick Penven 2011
%
nc{'time'}(indx) = time; 
nc{'ID'}(indx) = ID; 
nc{'lon'}(indx) =  lon;
nc{'lat'}(indx) =  lat;
nc{'Area'}(indx) =  Area;
nc{'Energy'}(indx) =  Energy;
nc{'Vorticity'}(indx) =  Vorticity;
nc{'Radius'}(indx) =  Radius;
nc{'MaxSSH'}(indx) =  MaxSSH;
nc{'MinSSH'}(indx) =  MinSSH;
nc{'MeanSSH'}(indx) =  MeanSSH;
nc{'Amplitude'}(indx) =  Amplitude;
nc{'Ueddy'}(indx) =  Ueddy;
nc{'Leddy'}(indx) =  Leddy;
nc{'U'}(indx) =  U;
nc{'V'}(indx) =  V;
indx=indx+1;

return
