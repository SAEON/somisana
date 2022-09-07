function angle=get_angle(latu,lonu,argu1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute the grid orientation: angle [radians] 
% between XI-axis and the direction to the EAST 
% at RHO-points.
%
% lonu longitude of u points
% latu latitude of u points
% argu1: spheroid 
%         'clarke66'  Clarke 1866
%         'iau73'     IAU 1973
%         'wgs84'     WGS 1984 (default)
%         'sphere'    Sphere of radius 6371.0 km
%
% copied from dist.m of the Oceans toolbox
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spheroid='wgs84';
if (nargin >= 3),
  spheroid=argu1;
end;

if (spheroid(1:3)=='sph'),
      A = 6371000.0;
      B = A;
      E = sqrt(A*A-B*B)/A;
      EPS= E*E/(1-E*E);
elseif (spheroid(1:3)=='cla'), 
      A = 6378206.4E0;
      B = 6356583.8E0;
      E= sqrt(A*A-B*B)/A;
      EPS = E*E/(1.-E*E);
elseif(spheroid(1:3)=='iau'),
      A = 6378160.e0;
      B = 6356774.516E0;
      E = sqrt(A*A-B*B)/A; 
      EPS = E*E/(1.-E*E);
elseif(spheroid(1:3)=='wgs'),
      A = 6378137.;
      E = 0.081819191;
      B = sqrt(A.^2 - (A*E).^2);
      EPS= E*E/(1.-E*E);
else
   error('dist: Unknown spheroid specified!');
end;

latu=latu*pi/180;     % convert to radians
lonu=lonu*pi/180;

latu(latu==0)=eps;  % Fixes some nasty 0/0 cases in the
                    % geodesics stuff
[M,L]=size(latu);

PHI1=latu(1:M,1:L-1);    % endpoints of each segment
XLAM1=lonu(1:M,1:L-1);
PHI2=latu(1:M,2:L);
XLAM2=lonu(1:M,2:L);

                    % wiggle lines of constant lat to prevent numerical probs.
PHI2(PHI1==PHI2)=PHI2(PHI1==PHI2)+ 1e-14;
                     % wiggle lines of constant lon to prevent numerical probs.
XLAM2(XLAM1==XLAM2)=XLAM2(XLAM1==XLAM2)+ 1e-14;


% COMPUTE THE RADIUS OF CURVATURE IN THE PRIME VERTICAL FOR
% EACH POINT

xnu1=A./sqrt(1.0-(E*sin(PHI1)).^2);
xnu2=A./sqrt(1.0-(E*sin(PHI2)).^2);

% COMPUTE THE AZIMUTHS.  azim  IS THE AZIMUTH AT POINT 1
% OF THE NORMAL SECTION CONTAINING THE POINT 2

TPSI2=(1.-E*E)*tan(PHI2) + E*E*xnu1.*sin(PHI1)./(xnu2.*cos(PHI2));

% SOME FORM OF ANGLE DIFFERENCE COMPUTED HERE??

DLAM=XLAM2-XLAM1;
CTA12=(cos(PHI1).*TPSI2 - sin(PHI1).*cos(DLAM))./sin(DLAM);
azim=atan(1./CTA12);

%  GET THE QUADRANT RIGHT

DLAM2=(abs(DLAM)<pi).*DLAM + (DLAM>=pi).*(-2*pi+DLAM) + ...
        (DLAM<=-pi).*(2*pi+DLAM);
azim=azim+(azim<-pi)*2*pi-(azim>=pi)*2*pi;
azim=azim+pi*sign(-azim).*( sign(azim) ~= sign(DLAM2) );
angle(:,2:L)=(pi/2)-azim(:,1:L-1);
angle(:,1)=angle(:,2);
angle(:,L+1)=angle(:,L);

return

