function hh = add_streamarrows(cs,x,y,u,v)
if nargin < 5
    error('Not enough input arguments.')
end
if min(size(cs)) > 2
    error('First input must be a valid contour description matrix.')
end
h = plus_labels(cs,x,y,u,v);
if nargout>0, hh = h; end
if ~ishold, 
  view(2)
end
%-------------------------------------------------------
function h = plus_labels(cs,x,y,u,v);
scale=3e-2;
cax = gca;
[mcs, ncs] = size(cs);
% Find range of levels.
k = 1; i = 1;
while k <= ncs
   levels(i) = cs(1,k);
   i = i + 1;
   k = k + cs(2,k) + 1;
end
cmin = min(levels);
cmax = max(levels);
crange = max(abs(levels));
cdelta = abs(diff(levels)); 
cdelta = min(cdelta(cdelta > eps))/max(eps,crange); % Minimum significant change
if isempty(cdelta), cdelta = 0; end

k = 0; n = 0; flip = 0; h = [];

while (1)
% Select a labeling point randomly if not manual.

      k = k + n + 1; if k > ncs, break, end
      c = cs(1, k); n = cs(2, k);
      r = rands(1);
      j = fix(r.* (n - 1)) + 1;
      if flip, j = n - j; end
      flip = ~flip;
      if n == 1    % if there is only one point
        xx = cs(1, j+k); 
	yy = cs(2, j+k);
      else
        x1 = cs(1, j+k); y1 = cs(2, j+k);
        x2 = cs(1, j+k+1); y2 = cs(2, j+k+1);
        xx = (x1 + x2) ./ 2; 
	yy = (y1 + y2) ./ 2;  
      end

% Label the point.

      % Set tiny labels to zero.
      if abs(c) <= 10*eps*crange, c = 0; end
      % Determine format string number of digits
      if cdelta > 0, 
        ndigits = max(3,ceil(-log10(cdelta)));
      else
        ndigits = 3;
      end
      s = num2str(c,ndigits);
      u1=interp2(x,y,u,xx,yy);
      v1=interp2(x,y,v,xx,yy);
      spd=sqrt(u1.^2+v1.^2);
      u1=scale*u1./spd;
      v1=scale*v1./spd;
      hold on
      ht=fleches(xx,yy,u1,v1,0);
      hold off
      h = [h;ht];
end
%----------------------------------------
function r = rands(n)
%RANDS Stateless rand
%   R = RANDS(N) is the same as calling RAND(INP) except
%   that the state of the random number generator is unaffected.

Currstate=rand('state');
rand('state',sum(100*clock));
r = rand(n);
rand('state',Currstate); % resets to original state.
%----------------------------------------
function hh = fleches(varargin)
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1; % Plot arrows
sym = '';

filled = 1;
ls = '-';
ms = '';
col = '';

nin = nargin;
% Parse the string inputs
while isstr(varargin{nin}),
  vv = varargin{nin};
  if ~isempty(vv) & strcmp(lower(vv(1)),'f')
    filled = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(vv);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',vv));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; plotarrows = 0; end
    if isequal(m,'.'), ms = ''; end % Don't plot '.'
    nin = nin-1;
  end
end

error(nargchk(2,5,nin));

% Check numeric input arguments
if nin<4, % quiver(u,v) or quiver(u,v,s)
  [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
  [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

if nin==3 | nin==5, % quiver(u,v,s) or quiver(x,y,u,v,s)
  autoscale = varargin{nin};
end

% Scalar expand u,v
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end

if autoscale,
  % Base autoscale value on average spacing in the x and y
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if x and y are vectors.
  if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
  delx = diff([min(x(:)) max(x(:))])/n;
  dely = diff([min(y(:)) max(y(:))])/m;
  del = delx.^2 + dely.^2;
  if del>0
    len = sqrt((u.^2 + v.^2)/del);
    maxlen = max(len(:));
  else
    maxlen = 0;
  end
  
  if maxlen>0
    autoscale = autoscale*0.9 / maxlen;
  else
    autoscale = autoscale*0.9;
  end
  u = u*autoscale; v = v*autoscale;
end

ax = newplot;
next = lower(get(ax,'NextPlot'));
hold_state = ishold;

% Make velocity vectors
x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];

%h1 = plot(uu(:),vv(:),[col ls]);
h1=[];

if plotarrows,
  % Make arrow heads and plot them
  hu = [x-alpha*(u+beta*(v+eps));x; ...
        x-alpha*(u-beta*(v+eps));x-alpha*(u+beta*(v+eps))];
  hv = [y-alpha*(v-beta*(u+eps));y; ...
        y-alpha*(v+beta*(u+eps));y-alpha*(v-beta*(u+eps))];
  hold on
%  h2 = plot(hu(:),hv(:),[col ls]);
  h2 = patch(hu(:),hv(:),1+0*hu,[0 0 0]);
else
  h2 = [];
end

if ~isempty(ms), % Plot marker on base
  hu = x; hv = y;
  hold on
  h3 = plot(hu(:),hv(:),[col ms]);
  if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
  h3 = [];
end

if ~hold_state, hold off, view(2); set(ax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end
