function var=readdap(url,vname,query)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Reproduce the loaddods behavior (i.e. gives a variable, 
%  not a structure)
%
%  Retry (100 times) in case of network failure.
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
%
%argdods='-e +v';
argdods='-e -v';
%
nmax=100;
%
%
var=[];
ntry=0;
dods_err=0;
while isempty(var) 
  if ntry>nmax
    error(['READDAP: repeated failures after ',num2str(nmax),' queries'])
  end
  ntry=ntry+1;
  try
    var=loaddap(argdods,[url,'?',vname,query]);
  catch
    var=[];
    disp(['READDAP: did not work at ',num2str(ntry),' try: lets try again.'])
  end
  if dods_err~=0
    var=[];
    disp(['READDAP: did not work at ',num2str(ntry),' try: lets try again.'])
  end  
end
%
fname=fieldnames(var);
fname=char(cellstr(fname(1)));
%
disp(['READDAP: reading ',fname])
%
while isstruct(var)
  eval(['var=var.',fname,';']);
end
%
return
