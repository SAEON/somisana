function data = readdap(url,varname,query)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Reproduce the old readdap behavior when using loaddap library
%  But uses Built-in Support for OPeNDAP from Matlab >= 2012a 
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
%  Copyright (c) 2015 by Serena ILLIG
%  e-mail: serena.illig@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
nmax=100;
data=[];
ntry=0;
%
if nargin <2
    disp(['not engough input argments']);
elseif nargin <3 || isempty(query)
    disp(['READDAP_New: Extract : ', varname])
    while isempty(data)
        if ntry>nmax
            error(['READDAP_New: repeated failures after ',num2str(nmax),' queries'])
        end
        ntry=ntry+1;
        try
            ncid = netcdf.open ( url,'NOWRITE' );
            varid = netcdf.inqVarID(ncid,varname);
            data = netcdf.getVar(ncid,varid,'double');
            netcdf.close (ncid);
        catch
            data=[];
            disp(['READDAP_New: did not work at ',num2str(ntry),' try: lets try again.'])
        end
    end
    
else
    disp(['READDAP_New: Extract : ', varname, query])
    ind1 = strfind(query,'[');
    ind2 = strfind(query,']');
    nb_dims=length(ind1);
    start2=zeros(1,nb_dims);
    count2=ones(1,nb_dims);
    for ii=1:nb_dims
        str_tmp=query(ind1(ii)+1:ind2(ii)-1);
        if isempty(strfind(str_tmp,':'))
            start2(ii)=str2num(str_tmp);
        else
            start2(ii)=str2num(str_tmp(1:strfind(str_tmp,':')-1));
            count2(ii)=str2num(str_tmp(strfind(str_tmp,':')+1:length(str_tmp)))-start2(ii)+1;
        end
    end
    start=fliplr(start2);
    count=fliplr(count2);
    %[start;count]
    
    while isempty(data)
        if ntry>nmax
            error(['READDAP_New: repeated failures after ',num2str(nmax),' queries'])
        end
        ntry=ntry+1;
        try
            ncid = netcdf.open ( url,'NOWRITE' );
            varid = netcdf.inqVarID(ncid,varname);
            data = netcdf.getVar(ncid,varid,start,count,'double');
            netcdf.close (ncid);
            if length(size(data))==2
                data=permute(data,[2 1]);
            elseif length(size(data))==3
                data=permute(data,[3 2 1]);               
            elseif length(size(data))==4
                data=permute(data,[4 3 2 1]);                 
            end
        catch
            data=[];
            disp(['READDAP_New: did not work at ',num2str(ntry),' try: lets try again.'])
        end
    end
end

%
return
