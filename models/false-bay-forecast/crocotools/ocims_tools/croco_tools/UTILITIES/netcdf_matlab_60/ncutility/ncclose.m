function theResult = ncclose(theNCid)

% ncclose(theNCid) closes the netcdf files whose
%  identifiers are the given theNCid.  The default
%  is 'all', which uses theNCid = [0:15]; end
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, theNCid = 'all'; end

if isequal(theNCid, 'all')
	theNCid = 0:15;
end

theNCid = -sort(-theNCid);

v = version;
if v(1) == '6'
   fcn = 'mexcdf60';   % Matlab-6 only.
elseif v(1) == '5'
   fcn = 'mexcdf53';   % Matlab-5 only.
  elseif v(1) == '4'
   fcn = 'mexcdf4';    % Matlab-4 only.
end

for i = 1:length(theNCid)
   status(i) = feval(fcn,'close', theNCid(i));
end

if nargout > 0
   theResult = status;
  else
   for i = 1:length(theNCid)
      if status(i) >= 0
         disp([' ## closed: ncid = ' int2str(theNCid(i)) '.'])
      end
   end
end
