function [fname]=make_coast(bounds,res)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function make_coast(lonmin,lonmax,latmin,latmax,res,prename)
%
%  Get GSHH smaller data files (see m_map toolbox for details)
%  
%  Grid dimensions:
%   lonmin : Minimum longitude [degree east]
%   lonmax : Maximum longitude [degree east]
%   latmin : Minimum latitude [degree north]
%   latmax : Maximum latitude [degree north]
%
%   res : resolution indice (ex: 'i' for intermediate)
%  gshhs_f.b    Full resolution data
%  gshhs_h.b    High resolution data
%  gshhs_i.b    Intermediate resolution data
%  gshhs_l.b    Low resolution data
%  gshhs_c.b    Crude resolution data
%
%  prename:
%   GSHH coastline name prefix (ex biscay for biscay_i.mat)
%
%  Pierrick Penven, IRD, 2002.
%
%  Version of 13 Sep 2004 - updates from P. Marchesiello
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin<2,
 res='i';
end;
prename='coastline';
%
% Determine domain size
%
lonmin=bounds(1); lonmax=bounds(2);
latmin=bounds(3); latmax=bounds(4);
%
% Extract the coastlines
%
m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
	 
fname=[prename,'_',res,'.mat'];
disp(['Processing ',fname,' ...'])
  
if res=='c',
  m_gshhs_c('save',fname);
end;

if res=='l',
  m_gshhs_l('save',fname);
end;

if res=='i',
  m_gshhs_i('save',fname);
end;

if res=='h',
  m_gshhs_h('save',fname);
end;

if res=='f',
  m_gshhs_f('save',fname);
end;

%m_usercoast(fname,'patch',[.9 .9 .9]);
%m_grid('box','fancy','tickdir','in');

