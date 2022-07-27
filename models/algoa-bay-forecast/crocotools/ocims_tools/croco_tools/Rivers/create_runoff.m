function  create_runoff(runoffname,grdname,title,...
    qbart,qbarc,rivername,rivernumber,...
    runoffname_StrLen,dir,psource_ts,biol)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf runoff file
%       runoffname: name of the runoff file
%       grdname: name of the grid file
%       title: title in the netcdf file
%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nw=netcdf(runoffname,'clobber');
result = redef(nw);


%
%  Create dimensions
%

nw('qbar_time') = length(qbart);
nw('n_qbar') = rivernumber;
nw('runoffname_StrLen') = runoffname_StrLen;
nw('one') = 1;
nw('two') = 2;
%
%  Create variables and attributes
%
nw{'qbar_time'} = ncdouble('qbar_time');
nw{'qbar_time'}.long_name = ncchar('runoff time');
nw{'qbar_time'}.units = ncchar('days');
nw{'qbar_time'}.cycle_length = qbarc;

if psource_ts
    nw{'temp_src_time'} = ncdouble('qbar_time');
    nw{'temp_src_time'}.long_name = ncchar('runoff time');
    nw{'temp_src_time'}.units = ncchar('days');
    nw{'temp_src_time'}.cycle_length = qbarc;
    
    nw{'salt_src_time'} = ncdouble('qbar_time');
    nw{'salt_src_time'}.long_name = ncchar('runoff time');
    nw{'salt_src_time'}.units = ncchar('days');
    nw{'salt_src_time'}.cycle_length = qbarc;
end
nw{'runoff_name'} = ncchar('n_qbar','runoffname_StrLen');
nw{'runoff_name'}.long_name = ncchar('runoff time');

nw{'runoff_position'} = ncdouble('n_qbar','two');
nw{'runoff_position'}.long_name = ncchar('position of the runoff (by line) in the CROCO grid');

nw{'runoff_direction'} = ncdouble('n_qbar','two');
nw{'runoff_direction'}.long_name = ncchar('direction/sense of the runoff (by line) in the CROCO grid');

nw{'Qbar'} = ncdouble('n_qbar','qbar_time');
nw{'Qbar'}.long_name = ncchar('runoff discharge');
nw{'Qbar'}.units = ncchar('m3.s-1');

if psource_ts
    nw{'temp_src'} = ncdouble('n_qbar','qbar_time');
    nw{'temp_src'}.long_name = ncchar('runoff temp conc.');
    nw{'temp_src'}.units = ncchar('deg.celsius');
    
    nw{'salt_src'} = ncdouble('n_qbar','qbar_time');
    nw{'salt_src'}.long_name = ncchar('runoff salt conc.');
    nw{'salt_src'}.units = ncchar('psu');
    
    if biol
        nw{'no3_src_time'} = ncdouble('qbar_time');
        nw{'no3_src_time'}.long_name = ncchar('runoff time');
        nw{'no3_src_time'}.units = ncchar('days');
        nw{'no3_src_time'}.cycle_length = 360;
        
        nw{'NO3_src'} = ncdouble('n_qbar','qbar_time');
        nw{'NO3_src'}.long_name = ncchar('runoff no3 conc.');
        nw{'NO3_src'}.units = ncchar('mmol.s-1');
    end
end
result = endef(nw);

%
% Create global attributes
%
nw.title = ncchar(title);
nw.title = title;
nw.date = ncchar(date);
nw.date = date;
nw.grd_file = ncchar(grdname);
nw.grd_file = grdname;
nw.type = ncchar('CROCO runoff file');
nw.type = 'CROCO runoff file';

%
% Write time variables
nw{'qbar_time'} (:) = qbart;
if psource_ts
    nw{'temp_src_time'} (:) = qbart;
    nw{'salt_src_time'} (:) = qbart;
    if biol
        % nw{'no3_src_time'} (:) = no3t;
    end
end
for k=1:rivernumber
    nw{'runoff_name'}(k,:) = rivername(k,:);
end
%
close (nw)