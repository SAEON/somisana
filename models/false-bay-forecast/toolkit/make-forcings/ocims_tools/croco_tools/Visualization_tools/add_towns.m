function add_towns(fname,fsize,lonmin,lonmax,latmin,latmax);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function add_towns(fname,fsize,lonmin,lonmax,latmin,latmax)
%
% add the names of some capes on the image
%
% input:
%
%  fname     town ASCII file name - format: -124.40   42.80  C.+Blanco
%                                          (+ is for a white space)
%                                          last line: 9999 9999 END
%  fsize     font size (scalar) 
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=0;
fid = fopen(fname);
while a~=9999
  a = fscanf(fid,'%g',[1]);
  b = fscanf(fid,'%g',[1]);
  c = fscanf(fid,'%s',[1]);
  if (a>lonmin & a<lonmax & b>latmin & b<latmax)
    c(c=='+')=' ';
    m_text(a,b,c,'FontSize',fsize);
  end
end
fclose(fid);
