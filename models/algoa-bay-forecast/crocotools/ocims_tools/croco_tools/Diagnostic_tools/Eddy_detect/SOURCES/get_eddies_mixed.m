function [neddy,LONeddy,LATeddy,Seddy,EKEeddy,XIeddy,Reddy,...
          MAXZeddy,MINZeddy,MEANZeddy,AMPeddy,Ueddy,Leddy]=...
            get_eddies_mixed_oct2011(lon,lat,zeta,f,pm,pn,mask,...
	                             dz,Rmax,Omin,Nhanning)
%
% function [neddy,LONeddy,LATeddy,Seddy,EKEeddy,XIeddy,Reddy,...
%          MAXZeddy,MINZeddy,MEANZeddy,AMPeddy,Ueddy,Leddy]=...
%            get_eddies_mixed_oct2011(lon,lat,zeta,f,pm,pn,mask,...
%	                             dz,Rmax,Omin,Nhanning)
%
%  Get the geostrophic eddies in an horizontal field of 
%  SSH (lon,lat,zeta).
%
%  1 - get the local extrema in zeta
%
%  2- for each extremum get a subgrid and extract the
%     corresponding eddy
%
%
% Pierrick Penven 2011
%
[Imax,Jmax,LONmax,LATmax,Zmax]=get_locmax(lon,lat,zeta); [Imin,Jmin,LONmin,LATmin,Zmin]=get_locmin(lon,lat,zeta);
%
% Put mean values at the shore (remove the NaNs in zeta)
%
zeta(isnan(zeta))=mean(zeta(isfinite(zeta)));
%zeta(mask==0)=mean(zeta(mask==1));
%
% Disregard data on the shelves
%
%zeta(mask==0)=NaN;
%
% get the minimum eddy radius detectable
%
[dx,dy]=get_dx(lon,lat);
ds=dx.*dy;
dxmax=max(dx(:)/1000);
dymax=max(dy(:)/1000);
Rmin=max([dxmax dymax]);
DX=mean([mean(dx(:)) mean(dy(:))]);
npts=round(1e3*Rmax/DX);
%
% Get the Okubo-Weiss parameter, Vorticity and Eddy Kinetic Energy
%
[oku,xi]=okubo_aviso(pm,pn,f,zeta);
xi(isnan(xi))=0;
oku(isnan(oku))=0;
eke=ke_aviso(pm,pn,f,zeta);
U=sqrt(2*eke);
%
% Apply Nhanning times a Hanning filter on the Okubo-Weiss parameter
%
for n=1:Nhanning
  oku=hanning(oku);
%  oku(mask0==0)=0;
end
%
oku(mask==0)=NaN;
%
neddy=0;
%
% Anticyclones
%
disp('Anticyclones')
for nmax=1:length(Imax)
  if isfinite(Imax(nmax))
    [Imin,Imax,...
    LONed,LATed,Sed,...
    EKEed,XIed,Red,...
    MAXZed,MINZed,MEANZed,AMPed,Ued,Led]=...
         get_one_eddy(lon,lat,mask,zeta,oku,xi,eke,U,ds,...
                      Omin,npts,...
                      Imin,Jmin,LONmin,LATmin,Zmin,...
                      Imax,Jmax,LONmax,LATmax,Zmax,...
                      nmax,dz,1);
    if isfinite(LONed)	
      neddy=neddy+1;
      LONeddy(neddy)=LONed;
      LATeddy(neddy)=LATed;
      Seddy(neddy)=Sed;
      EKEeddy(neddy)=EKEed;
      XIeddy(neddy)=XIed;
      Reddy(neddy)=Red;
      MAXZeddy(neddy)=MAXZed;
      MINZeddy(neddy)=MINZed;
      MEANZeddy(neddy)=MEANZed;
      AMPeddy(neddy)=AMPed;
      Ueddy(neddy)=Ued;
      Leddy(neddy)=Led;      
    end
  end
end
%
% Cyclones
%
disp('Cyclones')
for nmin=1:length(Imin)
  if isfinite(Imin(nmin))
    [Imin,Imax,...
    LONed,LATed,Sed,...
    EKEed,XIed,Red,...
    MAXZed,MINZed,MEANZed,AMPed,Ued,Led]=...
         get_one_eddy(lon,lat,mask,zeta,oku,xi,eke,U,ds,...
                      Omin,npts,...
                      Imin,Jmin,LONmin,LATmin,Zmin,...
                      Imax,Jmax,LONmax,LATmax,Zmax,...
                      nmin,dz,0);
    if isfinite(LONed)	
      neddy=neddy+1;
      LONeddy(neddy)=LONed;
      LATeddy(neddy)=LATed;
      Seddy(neddy)=Sed;
      EKEeddy(neddy)=EKEed;
      XIeddy(neddy)=XIed;
      Reddy(neddy)=Red;
      MAXZeddy(neddy)=MAXZed;
      MINZeddy(neddy)=MINZed;
      MEANZeddy(neddy)=MEANZed;
      AMPeddy(neddy)=AMPed;
      Ueddy(neddy)=Ued;
      Leddy(neddy)=Led;      
    end
  end
end




return
