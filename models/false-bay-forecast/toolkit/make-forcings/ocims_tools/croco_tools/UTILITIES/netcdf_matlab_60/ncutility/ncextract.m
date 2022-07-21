function theResult = ncextract(theNCObject, theOutputName)

% ncextract -- GUI for NetCDF data extraction.
%  ncextract(theNCObject, 'theOutputName') presents a dialog
%   for guiding the extraction of the values associated with
%   theNCObject, a NetCDF variable or attribute object.  The
%   optional output-name defaults to "ans" in the "base"
%   workspace, unless an actual output argument is provided.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 27-Jul-2000 09:28:06.
% Updated    27-Jul-2000 14:54:35.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theOutputName = 'ans'; end

result = [];

if ~isa(theNCObject, 'ncvar') & ~isa(theNCObject, 'ncatt')
	disp([' ## ' mfilename ' -- The item must be a NetCDF variable or attribute.'])
	if nargout > 0, theResult = result; end
	return
end

theName = name(theNCObject);
theSize = ncsize(theNCObject);

Extract.Output = theOutputName;
for i = 1:length(theSize)
	label = ['Dim_' int2str(i)];
	indices = ['1:1:' int2str(theSize(i))];
	Extract = setfield(Extract, label, indices);
end

theTitle = ['NCExtract -- ' theName];
x = guido(Extract, theTitle);

try
	if ~isempty(x)
		theOutputName = getinfo(x, 'Output');
		s = 'theNCObject(';
		for i = 1:length(theSize)
			label = ['Dim_' int2str(i)];
			indices = getinfo(x, label);
			if i > 1, s = [s ', ']; end
			s = [s indices];
		end
		s = [s ')'];
		result = eval(s);
		if nargout < 1
			assignin('base', theOutputName, result)
		end
	end
catch
	disp([' ## ' mfilename ' -- error; try again.'])
end

if nargout > 0, theResult = result, end
