function [dx,dy]=get_dx(lon,lat);

lonu=0.5*(lon(1:end,1:end-1)+lon(1:end,2:end));
latu=0.5*(lat(1:end,1:end-1)+lat(1:end,2:end));
lonv=0.5*(lon(1:end-1,1:end)+lon(2:end,1:end));
latv=0.5*(lat(1:end-1,1:end)+lat(2:end,1:end));
[Mp,L]=size(latu);
[M,Lp]=size(latv);
Lm=L-1;
Mm=M-1;
%
% dx and dy
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


return
