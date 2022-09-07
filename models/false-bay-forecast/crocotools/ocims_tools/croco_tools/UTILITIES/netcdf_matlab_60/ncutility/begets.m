function msg = begets(fcn,nin,a,b,c,d,e,f,g,h,i,j,k,l,m, ...
								n,o,p,q,r,s,t,u,v,w,x,y,z)

% begets -- Message showing the result of a function.
%  begets('fcn',nin,a,b,...) creates a message that
%   shows the function 'fcn' with its input and
%   output values.  The number of input arguments
%   is nin.  The argument list a,b,... is organized
%   into nin input values, followed immediately by
%   the output values.  Thus, begets('sqrt', 1, 4, 2)
%   results in the message "sqrt(4) ==> 2".

% Uses: mat2str.

% Copyright (C) 1991 Charles R. Denham, ZYDECO.
% All Rights Reserved.
 
% Updated    01-Feb-2001 13:06:00.

if nargin < 1
   help(mfilename)
   disp(' Some examples:')
   xx = (1:4).';
   begets('mean', 1, xx, mean(xx));
   xx = (2:4).^2;
   begets('sqrt', 1, xx, sqrt(xx));
   x = [1 2; 3 4]; [mm, nn] = size(xx);
   begets('size', 1, xx, [mm nn]);
   begets('size', 1, xx, mm, nn);
   xx = [1 2; 2 1]; [vv, dd] = eig(x);
   begets('eig', 1, xx, vv, dd)
   begets('1/0', 0, inf)
   begets('inf.*0', 0, inf.*0)
   xx = abs('hello');
   begets('setstr', 1, xx, setstr(xx))
   xx = 'hello';
   begets('abs', 1, xx, abs(xx))
   return
end

% FCN(...) Input argument list.

ss = '';
ss = [fcn];
if nin > 0, ss = [ss '(']; end
arg = 'a';
for ii = 1:nin;
   str = mat2str(eval(arg));
   if isstr(eval(arg))
      str = ['''' str ''''];
   end
   ss = [ss str];
   if ii < nin, ss = [ss ', ']; end
   arg = setstr(arg + 1);
end
if nin > 0, ss = [ss ')']; end

% [...] Output argument list.

tt = '';
nout = nargin - nin - 2;
if nout > 1, tt = ['[']; end
for ii = 1:nout
   str = mat2str(eval(arg));
   if isstr(eval(arg))
      str = ['''' str ''''];
   end
   tt = [tt str];
   if ii < nout, tt = [tt ', ']; end
   arg = setstr(arg + 1);
end
if nout > 1, tt = [tt ']']; end

% Message.

uu = [ss ' ==> ' tt];

if nargout > 0, msg = uu; else, disp([' ' uu]); end
