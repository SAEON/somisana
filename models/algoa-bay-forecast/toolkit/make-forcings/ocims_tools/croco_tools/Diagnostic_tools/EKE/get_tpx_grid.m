function [lon,lat,f,pm,pn]=get_tpx_grid(x,y);
%
%
%
[lon,lat]=meshgrid(x,y);
f=4*pi*sin(pi*lat/180)*366.25/(24*3600*365.25);
%
% Get the metrics
%
lonu=0.5*(lon(1:end,1:end-1)+lon(1:end,2:end));
latu=0.5*(lat(1:end,1:end-1)+lat(1:end,2:end));
lonv=0.5*(lon(1:end-1,1:end)+lon(2:end,1:end));
latv=0.5*(lat(1:end-1,1:end)+lat(2:end,1:end));
[Mp,L]=size(latu);
[M,Lp]=size(latv);
Lm=L-1;
Mm=M-1;
%
% pm and pn
%
dx=zeros(Mp,Lp);
dy=zeros(Mp,Lp);
dx(:,2:L)=spheric_dist(latu(:,1:Lm),latu(:,2:L),...
                       lonu(:,1:Lm),lonu(:,2:L));
dx(:,1)=dx(:,2);
dx(:,Lp)=dx(:,L);
dy(2:M,:)=spheric_dist(latv(1:Mm,:),latv(2:M,:),...
                       lonv(1:Mm,:),lonv(2:M,:));
dy(1,:)=dy(2,:);
dy(Mp,:)=dy(M,:);
pm=1./dx;
pn=1./dy;
return
