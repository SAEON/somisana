function z = zlevs(h,zeta,theta_s,theta_b,hc,N,type,vtransform);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function z = zlevs(h,zeta,theta_s,theta_b,hc,N,type,vtransform);
%
%  this function compute the depth of rho or w points for CROCO
%
%  On Input:
%
%    type    'r': rho point 'w': w point 
%    vtransform  1=> old v transform (Song, 1994); 
%                2=> new v transform (Shcheptekin, 2006)
%  On Output:
%
%    z       Depths (m) of RHO- or W-points (3D matrix).
% 
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M,L]=size(h);
if nargin < 8
    disp(['WARNING no vtransform defined'])
    vtransform = 1 ; %old vtranform = 1
    disp(['Default S-coordinate system use : Vtransform=1 (old one)'])
end
%
% Set S-Curves in domain [-1 < sc < 0] at vertical W- and RHO-points.


sc_r=zeros(N,1);
Cs_r=zeros(N,1);
sc_w=zeros(N+1,1);
Cs_w=zeros(N+1,1);

if (vtransform == 2)
    ds=1./N;
    if type=='w'

      sc_w(1) = -1.0;
      sc_w(N+1) =  0;
      Cs_w(1) = -1.0;
      Cs_w(N+1) =  0;
      
      sc_w(2:N) = ds*([1:N-1]-N);
      Cs_w=csf(sc_w, theta_s,theta_b);
      N=N+1;

%    disp(['===================================='])
%    for k=N:-1:1
%        disp(['Niveau S=',num2str(k),' Cs=',num2str( Cs_w(k), '%8.7f')])
%    end
%    disp(['===================================='])

    else

      sc= ds*([1:N]-N-0.5);    
      Cs_r=csf(sc, theta_s,theta_b);
      sc_r=sc;
%    disp(['===================================='])
%    for k=N:-1:1
%        disp(['Niveau S=',num2str(k),' Cs=',num2str( Cs_r(k), '%8.7f')])
%    end
%    disp(['===================================='])
    end

else
    cff1=1./sinh(theta_s);
    cff2=0.5/tanh(0.5*theta_s);
    if type=='w'
        sc=((0:N)-N)/N;
        N=N+1;
    else
        sc=((1:N)-N-0.5)/N;
    end
    Cs=(1.-theta_b)*cff1*sinh(theta_s*sc)...
        +theta_b*(cff2*tanh(theta_s*(sc+0.5))-0.5);
%    disp(['===================================='])
%    for k=N:-1:1
%        disp(['Niveau S=',num2str(k),' Cs=',num2str( Cs(k), '%8.7f')])
%    end
%    disp(['===================================='])
end
%
% Create S-coordinate system: based on model topography h(i,j),
% fast-time-averaged free-surface field and vertical coordinate
% transformation metrics compute evolving depths of of the three-
% dimensional model grid. Also adjust zeta for dry cells.
%  
h(h==0)=1.e-2;
Dcrit=0.01;   % min water depth in dry cells
zeta(zeta<(Dcrit-h))=Dcrit-h(zeta<(Dcrit-h));
%
hinv=1./h;
z=zeros(N,M,L);
if (vtransform == 2)
    if type=='w'
        cff1=Cs_w;
        cff2=sc_w+1;
        sc=sc_w;
    else
        cff1=Cs_r;
        cff2=sc_r+1;
        sc=sc_r;
    end
    h2=(h+hc);
    cff=hc*sc;
    h2inv=1./h2;
    for k=1:N
        z0=cff(k)+cff1(k)*h;
        z(k,:,:)=z0.*h./(h2) + zeta.*(1.+z0.*h2inv);
    end
else
    cff1=Cs;
    cff2=sc+1;
    cff=hc*(sc-Cs);
    cff2=sc+1;
    for k=1:N
        z0=cff(k)+cff1(k)*h;
        z(k,:,:)=z0+zeta.*(1.+z0.*hinv);
    end
end
%if type=='w'
%  hmin=min(min(h));
%  hmax=max(max(h));
%  for k=N:-1:1
%    cff1=sc(k)*hc+(hmin-hc)*Cs(k);
%    cff2=sc(k)*hc+(0.5*(hmin+hmax)-hc)*Cs(k);
%    cff3=sc(k)*hc+(hmax-hc)*Cs(k);
%    disp([num2str(k,6),' | ',num2str(sc(k),6),' | ',num2str(Cs(k)),' | ',...
%         num2str(cff1),' | ',num2str(cff2),' | ',num2str(cff3)])
%  end
%end


return

            
        

