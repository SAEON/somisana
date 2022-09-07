function make_OGCM_ocims_nest(NY,NM,ND,RSTY,RSTM,RSTD,makeini,rst_filename)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script was edited by Matt Carr (SAEON) in order to create a 
% inital/restart child file without the nestgui. This was done so that 
%the nesting can be automated and applied to forecast systems. The 
% script sets the variables for the function 'nested_initial.m' which 
% is called by nestgui and does the proccessing required. Before the 
% script can be excuted a parent grid, parent intial/restart and 
% childgrid file must exist. The script creates a inital 
% file depending on the vaiable makeini which is defined within the 
% forecast system. The restart file is create at the end of the previous
% run there make_restart is not needed. For now the script creates 
%inital files for one child but can be adapted in the future for more nests 
% md.carr@saeon.nrf.ac.za

%  Compute the initial file of the embedded grid
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
% Common parameters
%
crocotools_param;
%
% Setting nest level (maybe shouldn't be hardcoded in the future) 
nest_level=1;
nc_suffix='.nc';
nc_suffix_nest=['.nc.',num2str(nest_level)];
%
% Get the child grid
%
childgrid = [grdname,'.',num2str(nest_level)]
parent_grd = [grdname]
%
% Check if child grid exists
if  exist(childgrid)
	disp(['Using childgrid'])
	disp(childgrid)
else 
	disp (['No child grid found - script not run'])
%	
%	return
end
%
% Setting options for nesting (by default vertical correction and extrapolations are selected)
%
vertical_correc=1;
extrapmask=1;
biol=0;
bioebus=0;
pisces=0;
%
% Making inital or restart depending on makeini 
if makeini==1
	% Gettting the name of the parent intial file
	parent_ini=[ini_prefix,num2str(NY),num2str(NM,'%02.f'),num2str(ND,'%02.f'),nc_suffix];
	%
	if  exist(parent_ini)
		disp(['Using parent ini file ...'])
		disp(parent_ini)
	else 
		disp (['No ini file found - script not run'])
	%	return
	end
	% Getting the name of the child intial file  
	child_ini=[ini_prefix,num2str(NY),num2str(NM,'%02.f'),num2str(ND,'%02.f'),nc_suffix_nest];
	disp(['Writing child ini file',child_ini])
	%Created child inital using nested_inital function 
	nested_initial(childgrid,parent_grd,parent_ini,child_ini,...
		vertical_correc,extrapmask,biol,bioebus,pisces)
else
	% Gettting the name of the parent restart file		
	parent_rst = rst_filename
	child_rst=[rst_filename,'.1']
	%Run the function nested restart
	nested_restart(childgrid,parent_grd,parent_rst,child_rst,vertical_correc,extrapmask)
end
