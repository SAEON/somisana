function n=daysinmonth(Y,M)
%
%  n=daysinmonth(Y,M)
% Get the number of days per month
%
% Pierrick Penven 2011
%
if nargin ~= 2
 error('usage n=daysinmonth(Y,M)')
end
if leap_year(Y)==1
%   ja  fe ma ap ma ju ju au se oc no de
  n=[31 29 31 30 31 30 31 31 30 31 30 31];
else
  n=[31 28 31 30 31 30 31 31 30 31 30 31];
end
%
n=n(M);
%
return
