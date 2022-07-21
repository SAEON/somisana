%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Track the eddies from an eddy netcdf file
%
%  An eddy which minimize a generalized distance (in space, radius,
%  vorticity) between 1 time step to the second is considered the 
%  same eddy. If this implies an unrealistic velocity, this can
%  not be the same eddy: in this case this is a new eddy.
%
%  Pierrick Penven, IRD, 2011.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
clear all
close all
%
% Dates are defined as days since Yorig/1/1 00:00
%
%
% Typical scales for generalized eddy distance
%
L0=100e3;  % typical eddy distances
R0=100e3;  % typical eddy radius scale
X0=1e-5;   % typical eddy vorticity scale
Z0=0.1;    % typical eddy mean SSH variations
A0=0.1;    % typical eddy ssh amplitudes variations
%
% Maximum speed [m.s-1] possible for an eddy 
% (if an eddy is detected with a higher velocity
%  this is considered impossible - a new eddy is born)
%
Umax=0.3; % mean + 3* std dev (spd for 2010)
%
%fname='eddies_aviso_2014_2014_select.nc';
fname='eddies_croco_10_10_select.nc';
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Clear the file
%
nc=netcdf(fname,'write');
nc{'ID'}(:)=0;
nc{'U'}(:)=0;
nc{'V'}(:)=0;
close(nc)
%
% Open the file
%
nc=netcdf(fname,'write');
time=nc{'time'}(:);
%
tmin=min(time);
tmax=max(time);
tt=sort(time);
dt=inf+0*tt;                               
dt(2:end)=tt(2:end)-tt(1:end-1);
t=tt(dt~=0);
dt=mean(t(2:end)-t(1:end-1))
%
% Read the first time step
%
indx=find(time==t(1));
[ID1,t1,lon1,lat1,Area1,Ener1,Vort1,...
 Rad1,MaxSSH1,MinSSH1,MeanSSH1,Ampl1,U1,V1]=read_eddynetcdf(nc,indx);
%
ID1=indx;
maxID=max(ID1);
nc{'ID'}(indx)=ID1;
%
for tndx=2:1:length(t)
  tt=t(tndx);
%
  disp(' ')
  disp(['Processing day ',num2str(tt-tmin)])  
%
% Read next time step
%
  indx=find(time==tt);
  [ID2,t2,lon2,lat2,Area2,Ener2,Vort2,...
   Rad2,MaxSSH2,MinSSH2,MeanSSH2,Ampl2,U2,V2]=read_eddynetcdf(nc,indx);
%
% Detect eddies in frame #1 and frame #2 which represent the same eddy.
% The new and old eddies as they are the closest in a general parameter space
%
% match1: indices of eddies in the 2nd frame which have a match in the 1st frame
% match2: indices of eddies in the 1st frame which have a match in the 2nd frame
%
  [match1,ismatch1,match2,ismatch2]=...
	    get_neigbours(lon1',lat1',Rad1',Vort1',MeanSSH1',Ampl1',...
	                  lon2',lat2',Rad2',Vort2',MeanSSH2',Ampl2',0,...
                          L0,R0,X0,Z0,A0);
%
% Get the velocities of eddies in frame #2 which have a match in frame #1
%
  [U,V,Dx,Dy]=get_eddyspeeds(dt*24*3600,lon1,lat1,match1,...
                             ismatch1,lon2,lat2);
%
% Eddies with abnormal eddy speeds (i.e. a velocity above a given threshold)
% are considered as a wrong match:
% then the corresponding eddy in frame #1 is considered as dead
%      the corresponding eddy in frame #2 is considered as a new born
%
% (but Eddies with the deplacement is smaller than twice their radius 
%  are also considered a good match)
%
  spd=sqrt(U.^2+V.^2);
  eddydist=sqrt(Dx.^2+Dy.^2);
  iskilled=(spd>Umax) & (eddydist > 2*Rad1);
% 
  match2(match1(iskilled))=NaN;
  ismatch2=isfinite(match2);
  match1(iskilled)=NaN;
  ismatch1=isfinite(match1);
%
% eddies with a match keep their ID
%
  ID2(ismatch2==1)=ID1(match2(ismatch2==1));
  alive=ID2(ismatch2==1)';
%
% Set the velocities for these eddies
%
  U2=0*ID2;
  U2(ismatch2==1)=U(match2(ismatch2==1));
  V2=0*ID2;
  V2(ismatch2==1)=V(match2(ismatch2==1));
%
% new eddies without a match get a new ID
%
  IDnew=ID2(ismatch2==0); 
  Nnew=length(IDnew);
  IDnew=[maxID+1:maxID+Nnew];
  ID2(ismatch2==0)=IDnew;
  new=ID2(ismatch2==0)';
  total=ID2';
  disp(['alive=[',num2str(alive),'] new=[',num2str(new),...
        '] total=[',num2str(total),']'])
%
% Write the ID and speed in the netcdf file
%
  nc{'ID'}(indx)=ID2;
  nc{'U'}(indx)=U2;
  nc{'V'}(indx)=V2;
%
  ID1=ID2;
  lon1=lon2;
  lat1=lat2;
  Area1=Area2;
  Ener1=Ener2;
  Vort1=Vort2;
  Rad1=Rad2;
  MaxSSH1=MaxSSH2;
  MinSSH1=MinSSH2;
  MeanSSH1=MeanSSH2;
  Ampl1=Ampl2;
  U1=U2;
  V1=V2;
  maxID=max([maxID ID1']);
%
end
%
close(nc)
