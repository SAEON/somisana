function coef = oacoef(londata,latdata,lon,lat,ro)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function extrfield = oacoef(londata,latdata,lon,lat,ro)
%
% pierrick 2002 - derived from the fortran programs of 
% Alain Colin de Verdiere (2000)
%
% compute an objective analysis on a scalar field.
%
%   input: 
%  londata   : longitude of data points (vector)
%  latdata   : latitude of data points (vector)
%  lon       : longitude of the estimated points (vector)
%  lat       : latitude of the estimated points (vector)
%  ro        : decorrelation scale
%
%   output:
%  coef : oa matrix
%
%  extrfield=mdata+coef*(data-mdata)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
  error('Not enough input arguments')
elseif nargin < 5
  disp('using default decorrelation scale:  ro = 500 km')
  ro = 5e5;
end
%
i=[1:1:length(londata)];
j=[1:1:length(lon)];
[I,J]=meshgrid(i,i);
r1=spheric_dist(latdata(I),latdata(J),londata(I),londata(J));
%
[I,J]=meshgrid(i,j);
r2=spheric_dist(lat(J),latdata(I),lon(J),londata(I));
%
coef=exp(-r2/ro)/exp(-r1/ro);
%
return
