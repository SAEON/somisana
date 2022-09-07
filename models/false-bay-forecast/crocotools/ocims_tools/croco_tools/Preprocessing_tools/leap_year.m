function L=leap_year(Year)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function L=leap_year(Year)
%
% Finds if Year is a leap year (L=1) or a normal year (L=0)
%
% Marchesiello, IRD, 2005
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in the Gregorian calendar the following rules decides which 
% years are leap years:
%
%  1. Every year divisible by 4 is a leap year.
%  2. But every year divisible by 100 is NOT a leap year
%  3. Unless the year is also divisible by 400, then it is still a leap year.
%
% This means that year 1800, 1900, 2100, 2200, 2300 and 2500 are NOT 
% leap years, while year 2000 and 2400 are leap years.
%
% Note: this actually means year 2000 is kind of special, as it is the first 
% time the third rule is used in many parts of the world.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a=~ceil(Year/4-floor(Year/4));
b=~ceil(Year/100-floor(Year/100));
c=~ceil(Year/400-floor(Year/400));
L=(a & ~b) | (a & c);

