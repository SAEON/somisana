function [type,vlevout]=get_type(fname,vname,vlevin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the "type" of the CROCO variable rho,u or v point.
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

vlevout=vlevin;
type='r';
nc=netcdf(fname,'nowrite');
if isempty(nc)
  type='';
  return
end
var=nc{vname};
if isempty(var)
  type='';
  return
end
names=ncnames(dim(var));
ndim=length(names);
close(nc)
if ndim==1 
  type='';
  return
end

i=1;
name=char(names(i));
lname=length(name);

if name(lname-3:lname)~='time' & name(1:4)~='time'
    disp('warning no time dependent')
else
  i=i+1;
end
name=char(names(i));
if name(1)=='s'
  l=length(name);
  if name(l)=='w'
    type='w';
    return
  else    
    i=i+1;
  end
else
  vlevout=0;
end

name=char(names(i));
if name(1)~='e' &  name(1)~='y'
    type='';
  return
else
  l=length(name);
  if name(l)=='v'
    type='v';
    return
  end
  if name(l)=='u'
    type='u';
    return
  end
end
name=char(names(i+1));
if name(1)~='x'
  type='';
  return
else
  l=length(name);
  if name(l)=='u'
    type='u';
    return
  end
  if name(l)=='v'
    type='v';
    return
  end
end
return
