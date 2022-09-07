function [Imin,Imax,...
          LONeddy,LATeddy,Seddy,...
          EKEeddy,XIeddy,Reddy,...
          MAXZeddy,MINZeddy,MEANZeddy,AMPeddy,Ueddy,Leddy]=...
         get_one_eddy(lon,lat,mask,zeta,oku,xi,eke,U,ds,...
                      Omin,npts,...
                      Imin,Jmin,LONmin,LATmin,Zmin,...
                      Imax,Jmax,LONmax,LATmax,Zmax,...
                      nmax,dz,ismax)

%
% Select the extremum position
%
if ismax==1
  ieddy=Imax(nmax);
  jeddy=Jmax(nmax);
else
  ieddy=Imin(nmax);
  jeddy=Jmin(nmax);
end
%
xeddy=lon(jeddy,ieddy);
yeddy=lat(jeddy,ieddy);
%
% Get a subgrid around the extremum
%
[M,L]=size(zeta);
imin=max([1 ieddy-npts]);
imax=min([L ieddy+npts]);
jmin=max([1 jeddy-npts]);
jmax=min([M jeddy+npts]);
%
lon=lon(jmin:jmax,imin:imax);
lat=lat(jmin:jmax,imin:imax);
mask=mask(jmin:jmax,imin:imax);
zeta=zeta(jmin:jmax,imin:imax);
oku=oku(jmin:jmax,imin:imax);
xi=xi(jmin:jmax,imin:imax);
eke=eke(jmin:jmax,imin:imax);
U=U(jmin:jmax,imin:imax);
ds=ds(jmin:jmax,imin:imax);
%
% Get the closed loops around the extremum
%
x=[];
y=[];
if ismax==1
%
% In a case of a maximum: go from the maximum zeta
% to the minimum
%
  zstart=Zmax(nmax);
  dz=-dz;
  zend=min(zeta(mask==1));
else
%
% In a case of a minimum: go from the minimum zeta
% to the maximum
%
  zstart=Zmin(nmax);
  zend=max(zeta(mask==1));
end
%
for zz=zstart:dz:zend
  C1=contours(lon,lat,zeta,[zz zz]);
  [M L]=size(C1);
  i=1;
  while i<L
    pairs=C1(2,i);
    level=C1(1,i);
    segment=C1(:,i+1:i+pairs);
    if segment(:,1)==segment(:,end) 
      if inpolygon(xeddy,yeddy,segment(1,:),segment(2,:))
        x=segment(1,:);
        y=segment(2,:);
      end
    end
    i=i+pairs+1;
  end
end
%
% Get away if there is no closed loop
%
if isempty(x)
  %disp(['No closed contour ',num2str(nmax)])
  LONeddy=[];
  LATeddy=[];
  Seddy=[];
  EKEeddy=[];
  XIeddy=[];
  Reddy=[];
  MAXZeddy=[];
  MINZeddy=[];
  MEANZeddy=[];
  AMPeddy=[];
  Ueddy=[];
  Leddy=[]; 
  return
end
%
% Get a subgrid around the loop
%
imin=max(find(lon(1,:)<min(x)));
imax=min(find(lon(1,:)>max(x)));
jmin=max(find(lat(:,1)<min(y)));
jmax=min(find(lat(:,1)>max(y)));
%
lon=lon(jmin:jmax,imin:imax);
lat=lat(jmin:jmax,imin:imax);
mask=mask(jmin:jmax,imin:imax);
zeta=zeta(jmin:jmax,imin:imax);
oku=oku(jmin:jmax,imin:imax);
xi=xi(jmin:jmax,imin:imax);
eke=eke(jmin:jmax,imin:imax);
U=U(jmin:jmax,imin:imax);
ds=ds(jmin:jmax,imin:imax);
%
% Get the points inside the eddy (in a closed loop & okuboweiss>0)
%
ineddy=inpolygon(lon,lat,x,y).*(oku<=Omin);
%
x=[];
y=[];
C1=contours(lon,lat,ineddy,[0.5 0.5]);
[M L]=size(C1);
i=1;
while i<L
  pairs=C1(2,i);
  level=C1(1,i);
  segment=C1(:,i+1:i+pairs);
  if segment(:,1)==segment(:,end) 
    if inpolygon(xeddy,yeddy,segment(1,:),segment(2,:))
        x=segment(1,:);
        y=segment(2,:);
    end
  end
  i=i+pairs+1;
end
%
% Get away if got nothing
%
if isempty(x)
  %disp(['No loop containing oku>0 ',num2str(nmax)])
  LONeddy=[];
  LATeddy=[];
  Seddy=[];
  EKEeddy=[];
  XIeddy=[];
  Reddy=[];
  MAXZeddy=[];
  MINZeddy=[];
  MEANZeddy=[];
  AMPeddy=[];
  Ueddy=[];
  Leddy=[]; 
  return
end
%
% Get the number of grid points in the eddy
%
ineddy=inpolygon(lon,lat,x,y);
nieddy=sum(ineddy(:));
%
% Get away not enough grid points (Chelton, 2011 took 8)
%
if nieddy<4
  %disp(['Eddy too small ',num2str(nmax)])
  LONeddy=[];
  LATeddy=[];
  Seddy=[];
  EKEeddy=[];
  XIeddy=[];
  Reddy=[];
  MAXZeddy=[];
  MINZeddy=[];
  MEANZeddy=[];
  AMPeddy=[];
  Ueddy=[];
  Leddy=[]; 
  return
end
%
% Check if there are other extremum in this eddy
%
ismax=inpolygon(LONmax,LATmax,x,y);
ndouble=sum(ismax);
Imax(ismax==1)=NaN;
ismax=inpolygon(LONmin,LATmin,x,y);
ndouble=ndouble+sum(ismax);
Imin(ismax==1)=NaN;
if ndouble>1
  %disp('Double found')
end
%  
% Get eddy properties
%  
LONeddy=mean(x);
LATeddy=mean(y);
%  
ds=ds.*mask;
Seddy=sum(ds(ineddy==1));
%
a=eke.*ds;
EKEeddy=sum(a(ineddy==1));
%
a=xi.*ds;
XIeddy=sum(a(ineddy==1))./Seddy;
%
Reddy=sqrt(Seddy/pi);
%
zeddy=ineddy.*zeta;
a=zeddy(ineddy==1);  
MAXZeddy=max(a);
%  
MINZeddy=min(a);
%  
MEANZeddy=sum(a.*ds(ineddy==1))./Seddy;
%  
AMPeddy=MAXZeddy-MINZeddy;
%
% Compute an eddy maximum velocity and related eddy scale defined 
% as in chelton et al. (2011):
% the eddy rotational speed is the maximum averaged speed for a range in ssh
% the eddy scale is the distance between the center and this range
%
disteddy=spheric_dist(LATeddy,lat,LONeddy,lon);
dz=abs(dz);
if AMPeddy>dz
  Ueddy=0;
  Leddy=0;
  for SSH=MINZeddy:dz:MAXZeddy-dz
    inssh=(zeddy>=SSH & zeddy<=(SSH+dz) & ineddy==1);
    if sum(inssh(:))>=1
      spd=mean(U(inssh==1));
      if spd>=Ueddy
	Ueddy=spd;
	Leddy=mean(disteddy(inssh==1));
      end
    end
  end
else
  Ueddy=mean(U(ineddy==1));
  Leddy=mean(disteddy(ineddy==1));
end  
%
% Test for bugs..
%
if Leddy==0      
  MINZ=MINZeddy
  MAXZ=MAXZeddy
  AMP=AMPeddy
  dz
end
%
if 1==2
  figure
  pcolor2(lon,lat,ineddy)
  shading flat
  hold on
  contour(lon,lat,zeta,20,'k')
  plot(x,y,'g')
  end
%
return
