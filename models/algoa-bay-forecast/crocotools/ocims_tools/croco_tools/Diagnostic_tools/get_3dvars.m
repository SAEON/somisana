function [n3dvars,varcell,L,M,N]=get_3dvars(nc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  get_3dvars: Get the all prognostic variable names (u,v,zeta,..)
%  and sizes from a netcdf file
% 
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

Vars = var(nc);
Varnames = [ncnames(Vars)];
nvar=length(Vars);
ndims=0*(1:nvar);
ligne='                    ';
varstr=repmat(ligne,nvar,1);
n3dvars=0;
for i=1:nvar
  vname=char(Varnames(i));
  myvar=nc{vname};
  ndims(i)=length(dim(myvar));
  if ndims(i)>=3 
    n3dvars=n3dvars+1;
    varstr(n3dvars,1:length(vname))=vname;
    a=size(myvar);
    if ndims(i)==4
      L(n3dvars)=a(4);
      M(n3dvars)=a(3);
      N(n3dvars)=a(2);
    else
      L(n3dvars)=a(3);
      M(n3dvars)=a(2);
      N(n3dvars)=1;
    end
  end
end
varstr=varstr(1:n3dvars,:);
varcell=cellstr(varstr);
