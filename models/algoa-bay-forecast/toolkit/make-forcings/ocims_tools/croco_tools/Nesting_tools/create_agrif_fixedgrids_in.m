function create_agrif_fixedgrids_in(imin,imax,jmin,jmax,rcoeff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Create an Agrif_FixedGrids.in file
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Create an AGRIF_FixedGrids.in file'])
fname='AGRIF_FixedGrids.in';
fid=fopen(fname,'w');
fprintf(fid,'%s\n','    1');
fprintf(fid,'%s\n',['    ',num2str(imin),...
                     '    ',num2str(imax),...
                     '    ',num2str(jmin),...
                     '    ',num2str(jmax),...
                     '    ',num2str(rcoeff),...
                     '    ',num2str(rcoeff),...
                     '    ',num2str(rcoeff),...
                     '    ',num2str(rcoeff)]);
fprintf(fid,'%s\n','    0');
fprintf(fid,'%s\n','# number of children per parent');
fprintf(fid,'%s\n','# imin imax jmin jmax spacerefx spacerefy timerefx timerefy');
fprintf(fid,'%s\n','# [all coordinates are relative to each parent grid!]');
fprintf(fid,'%s\n','~');
fclose(fid);
