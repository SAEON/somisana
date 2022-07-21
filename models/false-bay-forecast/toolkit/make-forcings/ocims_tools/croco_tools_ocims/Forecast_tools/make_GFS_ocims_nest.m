function make_GFS_nest_ocims(NY,NM,ND)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script was edited by Matt Carr (SAEON) in order to create a 
% bulk child file without the nestgui. This was done so that the 
% nesting can be automated and applied to forecast systems. The 
% script sets the variables for the function 'nested_bulk.m' which 
% is called by nestgui and does the %proccessing required. Before the 
% script can be excuted a parent grid, parent bulk and childgrid 
% file must exist. For now the script creates blk files for one child 
% but can be adapted in the future for more nests 
% md.carr@saeon.nrf.ac.za
%   
% Get everything in order to compute the child bulk file
%
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param;
%
% Setting nest level (maybe shouldn't be hardcoded in the future) 
nest_level=1;
nc_suffix='.nc';
nc_suffix_nest=['.nc.',num2str(nest_level)];
%
% Setting the blk prefix name
blk_prefix=[blk_prefix,'_GFS_'];
%  
% Get the child grid
%
childgrid = [grdname,'.',num2str(nest_level)]
%
% time (in matlab time)
%
today=datenum(NY,NM,ND,0,0,0);
%
% Check if child grid exists
if  exist(childgrid)
	disp(['Using childgrid'])
	disp(childgrid)
else 
	disp (['No child grid found - script not run'])
%	
	return
end
%
parentblk=[blk_prefix,num2str(NY),num2str(NM,'%02.f'),num2str(ND,'%02.f'),nc_suffix];
%
if  exist(parentblk)
	disp(['Using parent bulk file ...'])
	disp(parentblk)
else 
	disp (['No blk file found - script not run'])
%	
%	return
end
%
childblk=[blk_prefix,num2str(NY),num2str(NM,'%02.f'),num2str(ND,'%02.f'),nc_suffix_nest];
%
disp(['Writing blk file',childblk])
%
% Making the blk for child grid
nested_bulk(childgrid,parentblk,childblk)
%
%
%     
