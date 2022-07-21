function x=loaddap(query,url)
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
%
%
x=[];
%
try
    ncid = netcdf.open ( url,'NOWRITE' );
    [ndim, nvar, natt, unlim] = netcdf.inq(ncid);
    for ii=1:nvar
        varid=ii-1;
        [varname, xtype, dimid, nattvar] = netcdf.inqVar(ncid, varid);
        varname2=varname;
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
            if ~isempty(strfind(attname,'DODS_ML_Size'))
                attval = netcdf.getAtt(ncid,varid,attname);
                eval(['x.',varname2,'.DODS_ML_Size','=''',attval,''';']);
            end            
        end
    end
    netcdf.close (ncid);
catch
    disp('PB with loaddap')
    x=[];
end

%
return
