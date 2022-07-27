function h=button(r,txt,cb);

% BUTTON Creates a GUI button.
%    h=BUTTON(R,TXT,CB) defines a button with the position R, text TXT,
%    and callback CB.  It uses UICONTROL function.
%
% ashcherbina@ucsd.edu, 11/20/2001

h=uicontrol('units','normalized', ...
            'position',r, ...
	    'string',txt, ...
	    'callback',cb, ...
	    'interruptible','on');

if (nargout==0),
  clear;
end,

return


