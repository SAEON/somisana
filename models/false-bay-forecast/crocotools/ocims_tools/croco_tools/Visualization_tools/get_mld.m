% function [mld, qe, imf] = get_mld(z,t)
% input:
% z= depth in meter is negative and decreasing with depth.
% z(1) = level closest to the surface
% t= temperature in Celsius or Kelvin
%
% To apply the routine to salinity or potential density profiles
% we recommend to give the input in 10PSU and 4kg/m^3, respectively,
% since the ratio of the standard deviation of salinity/potential density
% to the one of temperature tend to correspond to 0.1/0.25 (in the upper 500m).
% output:
% mld = mixed layer depth (negative) (our $h_{mix/c}$)
% qe = quality index QI_mix; a measure of the stratification
% imf = logical; imf=1: mld found within the profile
% imf=0: mld not found in the profile
% Authors: Katja Lorbacher & Dietmar Dommenget

function [mld, qe, imf] = get_mld(z,t)

% gradients; resolution; 30m variance
[gt res sig30]=gradients(z,t);
% hit bottom if no significant variability is in the profile
if (max(sig30)<0.02)
  mld=min(z); qe=0; imf=0; return
end
% check the range in which the mld can be found
imld0=first_guess(z,t,abs(gt),sig30);
% find level closest to mld
[imld,ct,ipo]=mld_0level(z,t,imld0,gt,res,sig30);
% interpolation between levels
mld=interpol(z,t,gt,imld,ipo);
% Q-skill estimate
qe=qskill(z,t,mld); imf=1;
%
% ################ FUNCTION gradients #######################
%
function [gt, res, sig30] = gradients(z,t)
smoo=5.; % gradients are calculated over at least 5m for a smoother estimate
ldim=length(z); gt(ldim)=0.0; sig30(ldim)=0.0;
for i=1:ldim-1;
% find level smoo meter below current level for gradients
  i2=min(ldim,i+1);
  while ( i2<ldim & z(i)-z(i2)<=smoo )
    i2=i2+1;
  end
% gradients
  gt(i)=max(-.6,min(.6,(t(i)-t(i2))/(z(i)-z(i2))));
% resolution
  res(i)=max(0.1,z(i)-z(min(ldim,i+1)));
% find level 30m below current level for sig30
  if (z(i)-z(ldim)> 30.0)
    i2=min(find(z(i)-z(i+1:ldim)>30.0))+i;
  end
  if (z(i)-z(ldim)<=30.0)
    i2=ldim;
  end
% standard deviation over 30m below current level, sig30
  sig30(i)=std(t(i:i2));
  if (z(i)-z(ldim)<30.0)
    sig30(i)=0.0;
  end
end
res(ldim)=res(ldim-1);
%
% ################ FUNCTION first_guess #######################
%
function imld = first_guess(z,t,gt,sig30)
% find first level that exceeds a significant gradient & sig30
imld=min( find( gt>0.25*max(gt) & sig30>0.02 ));
if (length(imld)==0); 
  imld=length(z); 
end
imld=max([imld,3]);
%
% ################ FUNCTION mld_0level #######################
%
function [imld, ct, ipo, ipara ] = mld_0level(z,t,imld0,gt,res,sig30)
% find local extreme in curvature with some boundary conditions
% and decide how to interpolate
% gradient threshold
sgtl=max([0.002,min(0.005,std(gt(1:imld0)))]); % low resolution
sgth=max([0.004,min(0.01,std(gt(1:imld0)))]); % high resolution
% curvature
ct(1)=0.; 
for i=2:length(gt); 
  ct(i)=(gt(i)-gt(i-1))./(z(i-1)-z(i)); 
end
% find local extreme in ct
i=1; 
imld=0;
while(imld==0 & i<imld0-1); 
  i=i+1;
  if((( gt(i)>=0 & ct(i)>0. & ct(i)>max( ct([max(1,i-1),i+1]))) ... % local maxima
     |(-gt(i)>0 &-ct(i)>0. &-ct(i)>max(-ct([max(1,i-1),i+1])))) ... % local minima
      & sig30(i)>0.02 ... % signifcant t-cline
      & ( (res(i)<6. & abs(gt(i))>sgth) ... % signifcant gradient
     |(res(i)>=6. & abs(gt(i))>sgtl)) ) ... % signifcant gradient
    imld=i; % local extreme found
  end
end
% no local extreme in gradient change => take first level > 0.7 maxvg
if (imld==0) ;
  imld=min(find(abs(gt(1:imld0))>0.7*max(abs(gt(1:imld0))))); 
end
% check for interpolation
ipo=0; 
ldim=length(z);
resi=max(res(max(1,imld-1):min(ldim,imld+2)));
% linear interpolation possible in the interval [z(imld-1) z(imld)]
if ( imld~=1 & imld<ldim )
  ipo=2;
  if ( resi < 6 )
% high resolution always linear interpolation
    ipo=2;
  else
% low resolution check if exponential interpolation possible
  if ( imld+3 <= ldim )
    ipo=1;
    if (gt(imld+1)/gt(imld)>=1.0); 
      ipo=2; 
    end % NO, not convex
    if (ipo==2 & abs(gt(imld+2)/gt(imld+1)-0.5)<0.5 ...
     & gt(imld-1)/gt(imld)<0.1 ); 
      imld=imld+1; ipo=1;
    end % but convex for imld+1
    if (abs(gt(imld+1)/gt(imld)-0.875)<0.125 ...
       & gt(imld-1)/gt(imld)>0.1);
      ipo=2;
    end % doubtful gradients
    if (gt(imld+1)/gt(imld)<=0.0); 
      ipo=2;
    end % change of sign
  end
end
if (resi <6); 
  sgt=sgth;
end
if (resi>=6);
  sgt=sgtl; 
end
if (ipo==2 & ( abs(gt(imld-1)/gt(imld)-.05)<.05 | abs(gt(imld-1))<sgt ) ); 
  imld=imld+1;
end
end
%
% ################ FUNCTION interpol #######################
%
function mld = interpol(z,t,gt,imld,ipo)
% interpolation in the interval [z(imld-1) z(imld)]
mld=z(imld); ldim=length(z);
% interpolation by exponential fit f(z) = C+A*exp(B*z)
if (ipo==1)
  for i=1:2
    x(i)=(abs(z(imld+i-1))+abs(z(imld+i)))./2.;
    dy(i)=log(sign(t(imld)-t(imld+1))*gt(imld+i-1));
  end
  s1=sum(x(1:2).*dy(1:2)); s2=sum(x(1:2)).*sum(dy(1:2))./2;
  if (s1-s2==0.); 
    return;
  end
  s3=sum(x(1:2).^2.); 
  s4=sum(x(1:2)).*sum(x(1:2))./2;
  if (s3-s4==0.); 
    return;
  end
  b=(s1-s2)./(s3-s4); 
  a=sum(dy(1:2))./2-b.*sum(x(1:2))./2; 
  B=-b;
  if (a<=0.); 
    return;
  end
  A=exp(a)./B;
  C=1./(2+1).*(sum(t(imld:imld+2))-sum(A*exp(-abs(z(imld:imld+2)).*B)) );
  x1(1:3)=t(imld:imld+2); 
  x2(1:3)=C+A.*exp(-B.*abs(z(imld:imld+2)));
  corrcoef(x1,x2); 
  r=ans(1,2);
  tref=mean(t(1:max(1,imld-1)));
  tx=mean(x2)+std(x2)./std(x1).*r.*(tref-mean(x1));
  mld=-abs(log((tx-C)./A)/(-B));
% empirical correction based on observational errors
% it shifts the mld further up from the level-imld
% it reflects the fact that the exponential profile below the mld does
% break down near the mld, it continues with a smaller gradient
% (a smooth transition zone)
  if ( mld-z(imld) <= 0.4*(z(imld-1)-z(imld)) )
    mld=z(imld)+2.5*(mld-z(imld))-0.1*(z(imld-1)-z(imld));
  end
% interpo overshoot -> empirical correction based on observational errors
% (better than setting mld onto a level)
  if (mld>=z(imld-1))
    if( gt(imld-1)<0.01*(z(imld-1)-z(imld)) )
      dd=0.5*(1-min(1,gt(imld+2)/gt(imld)))-0.25;
    else
      dd=10*gt(imld-1);
    end
    if(gt(imld+2)/gt(imld)>1.0)
      mld=z(imld-1)-0.25*(z(imld-1)-z(imld));
    else
      mld=z(imld-1)+dd*(z(imld-1)-z(imld));
    end
  end
end
% linear interpolation
if (ipo==2);
  if ( gt(imld)/gt(imld-1) > 1.0 )
    dx=(t(imld-1)-t(imld))/((gt(imld)+gt(imld-1))/2);
  else
% linear interpolation would overshoot: find a dT to go down from imld-1
    dt=max( [0.01 abs( diff(t(1:imld-1))' ) ] );
    dx=sign(t(imld)-t(imld-1))*dt/gt(imld-1)-(z(imld)-z(imld-1));
  end
% empirical correction based on observational errors
  if (1/4*(z(imld-1)-z(imld))<dx & dx<3/4*(z(imld-1)-z(imld)))
    dx=dx+(z(imld-1)-z(imld))/5;
  end
  mld=z(imld)+dx;
end
% interpolation must be within [z(imld-1), z(imld+1)]
if (mld > z(max(1,imld-1))); 
  mld=z(max(1,imld-1)); 
end
if (mld < z(min(ldim,imld+1))); 
  mld=z(min(ldim,imld+1)); 
end
%
% ################ FUNCTION Q-skill #######################
%
function qe = qskill(z,t,mld)
ldim=length(z); qe=0.0;
r=1.5; % range below mld
imld=max(find(z>mld));
i2=max(find(z(imld+1:ldim)>r*mld));
if (imld > 1 & length(i2) > 0 )
  v1=std(t(1:imld)); 
  v2=std(t(1:imld+i2));
  if (v2 ~= 0.0); 
    qe=1-v1/v2;
  end
end
