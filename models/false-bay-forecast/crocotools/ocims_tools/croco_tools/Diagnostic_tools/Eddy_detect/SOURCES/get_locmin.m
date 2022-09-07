function [i,j,lon,lat,v]=get_locmin(x,y,v);
%
u=0.*v;
%
u1=u(2:end-1,2:end-1);
%
u1(v(1:end-2,1:end-2)>=v(2:end-1,2:end-1)&...
   v(2:end-1,1:end-2)>=v(2:end-1,2:end-1)&...
   v(3:end  ,1:end-2)>=v(2:end-1,2:end-1)&...
   v(1:end-2,2:end-1)>=v(2:end-1,2:end-1)&...
   v(3:end  ,2:end-1)>=v(2:end-1,2:end-1)&...
   v(1:end-2,3:end  )>=v(2:end-1,2:end-1)&...
   v(2:end-1,3:end  )>=v(2:end-1,2:end-1)&...
   v(3:end  ,3:end  )>=v(2:end-1,2:end-1))=1;
%
u(2:end-1,2:end-1)=u1;
nmins=sum(sum(u));
%
%disp([num2str(nmins),' local minimums'])
%
[j,i]=find(u==1);
lon=x(u==1);
lat=y(u==1);
v=v(u==1);
%
return
