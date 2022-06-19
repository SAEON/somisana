function x=readattribute(url)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Reproduce the old readattribute behavior when using loaddap library
%  But uses Built-in Support for OPeNDAP from Matlab >= 2012a 
%
%  Get the attribute of an OPENDAP dataset
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
%  e-mail:Serena.Illig@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
nmax=100;
%
%
x=[];
ntry=0;
while isempty(x) 
  if ntry>nmax
    error(['READATTRIBUTE_New: repeated failures after ',num2str(nmax),' queries'])
  end
  ntry=ntry+1;
  try
    ncid = netcdf.open ( url,'NOWRITE' );
    [ndim, nvar, natt, unlim] = netcdf.inq(ncid);
    for ii=1:nvar
       varid=ii-1;
       [varname, xtype, dimid, nattvar] = netcdf.inqVar(ncid, varid);
       varname2=strrep(varname, '-', '_2d');
       for jj= 1:nattvar
             attid=jj-1;
             attname = netcdf.inqAttName(ncid,varid,attid);
             if ~isempty(strfind(attname,'missing_value')) || ~isempty(strfind(attname,'FillValue'));
                attval = netcdf.getAtt(ncid,varid,attname);
                eval(['x.',varname2,'.missing_value','=',num2str(attval),';']);
                eval(['x.',varname2,'.ml__FillValue','=',num2str(attval),';']);
             end
             if ~isempty(strfind(attname,'scale_factor'))
                attval = netcdf.getAtt(ncid,varid,attname);
                eval(['x.',varname2,'.scale_factor','=',num2str(attval),';']);
             end
             if ~isempty(strfind(attname,'add_offset'))
                attval = netcdf.getAtt(ncid,varid,attname);
                eval(['x.',varname2,'.add_offset','=',num2str(attval),';']);
             end
             if ~isempty(strfind(attname,'units'))
                attval = netcdf.getAtt(ncid,varid,attname);
                eval(['x.',varname2,'.units','=''',attval,''';']);
             end

       end
    end
    netcdf.close (ncid);
  catch
    x=[];
    disp(['READATTRIBUTE_New: did not work at ',num2str(ntry),' try: lets try again.'])
  end
end
%
return
