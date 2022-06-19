function theEvalString = vargstr(fcn, nvarargin, nvarargout)

% vargstr -- Eval-string for varargin and varargout.
%  vargstr('fcn', nvarargin, nvarargout) returns a string
%   that calls the 'fcn' function when eval-ed.  The input
%   and output arguments are expressed as vargargin{...}
%   and varargout{...}, respectively.  If nvarargin or
%   nvarargout is a cell-object, its length is used.
%   The argument-counts default to zero.

% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-Sep-2000 14:18:57.
% Updated    05-Sep-2000 14:18:57.

if nargin < 1, help vargstr, return, end

if nargin < 2, nvarargin = 0; end
if nargin < 3, nvarargout = 0; end

if isa(nvarargin, 'cell')
   nvarargin = length(nvarargin);
end

if isa(nvarargout, 'cell')
   nvarargout = length(nvarargout);
end

s = '';

if nvarargout > 0
   s = [s '['];
   for i = 1:nvarargout
      if i > 1, s = [s ',']; end
      s = [s 'varargout{' int2str(i) '}'];
   end
   s = [s ']'];
end

if ~isempty(fcn)
   if nvarargout > 0, s = [s '=']; end
   s = [s fcn];
end

if nvarargin > 0
   s = [s '('];
   for i = 1:nvarargin
      if i > 1, s = [s ',']; end
      s = [s 'varargin{' int2str(i) '}'];
   end
   s = [s ')'];
end

if ~isempty(fcn), s = [s ';']; end

if nargout > 0
   theEvalString = s;
  else
   disp(s)
end
