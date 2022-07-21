function [varargout] = size(self, index)

% ncitem/size -- Sizes (dimensions) of an "ncitem" object.
%  size(self) returns the size of self, an object derived
%   from the "ncitem" class.  Depending on the class of self,
%   this will be either its dimension-length, variable-size,
%   or attribute-length.  *** NOTE: Starting January 1, 1999,
%   the size-vector will contain at least two elements, in
%   keeping with the Matlab convention.  Use "ncsize" to get
%   the old form of the size-vector. ***
%   If self is a "netcdf" object, the returned value is
%   [ndims nvars ngatts recdimid]. Optionally, four separate
%   output variables can be requested.
%  size(self, index) returns the size-component at the
%   given index.  The result is 1 if the index exceeds
%   the length of the conventional size-vector.
%
% Also see: ncitem/ncsize, ncitem/name, ncitem/datatype.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 10:00:59.
% Updated    27-May-1999 14:32:43.

if nargin < 1, help(mfilename), return, end

vout = cell(1, max(nargout, 1));

[vout{:}] = ncsize(self);

switch class(self)
case 'netcdf'
	if nargin > 1 & nargout < 2
		result = vout{1};
		if index > 0 & index <= length(result)
			result = result(index);
		else
			result = [];
		end
		vout{1} = result;
	end
otherwise
	result = vout{1};
	while length(result) < 2, result = [result 1]; end
	if nargin > 1
		if length(result) < index
			result = 1;
		elseif index > 0
			result = result(index);
		else
			result = [];
		end
	end
	vout{1} = result;
end

if nargout > 0
	varargout = vout;
else
	disp(vout{1})
end
