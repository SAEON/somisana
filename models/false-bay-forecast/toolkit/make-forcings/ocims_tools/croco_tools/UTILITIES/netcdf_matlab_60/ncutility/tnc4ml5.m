function tnc4ml5

% tnc4ml5 -- Test nc4ml5 installation.
%  tnc4ml5 (no argument) exercizes some of the
%   components of "NetCDF for Matlab-5".
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-Apr-1997 09:50:05.

v = version;
if v(1) == '6'
   fcn = 'mexcdf60';   % Matlab-6 only.
elseif v(1) == '5'
   fcn = 'mexcdf53';   % Matlab-5 only.
  elseif v(1) == '4'
   fcn = 'mexcdf4';    % Matlab-4 only.
end

if isempty(which(fcn)) | (exist(fcn) ~= 3)
   disp(' ## Unable to find "mexcdfxx" Mex-file gateway.')
   disp(' ## Please check your Matlab path:')
   path
   return
end

clear(fcn)
clear mexcdf ncmex
clear tmexcdf tncmex tnetcdf

feval(fcn)
mexcdf, ncmex
tmexcdf, tncmex, tnetcdf

disp('## Testing done.')

help netcdf
