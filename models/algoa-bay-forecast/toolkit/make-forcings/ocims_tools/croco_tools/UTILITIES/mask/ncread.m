function [f]=ncread(fname,vname,tindex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2002 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [f]=ncread(fname,vname,tindex)                                   %
%                                                                           %
% This function reads in a generic multi-dimensional field from a NetCDF    %
% file.                                                                     %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF file name (character string).                       %
%    vname       NetCDF variable name to read (character string).           %
%    tindex      Optional, time index to read (integer):                    %
%                  *  If argument "tindex" is provided, only the requested  %
%                     time record is read if the variable has unlimitted    %
%                     dimension or the word "time" in any of its dimension  %
%                     names.                                                %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    f           Field (scalar, matrix or array).                           %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Set-up printing information switch.

global IPRINT

if (isempty(IPRINT)),
  IPRINT=1;
end,

%  Activate switch for reading specific record.

time_rec=0;
if (nargin > 2),
  time_rec=1;
end,

% Open NetCDF file.

[ncid]=mexcdf('ncopen',fname,'nc_nowrite');
if (ncid == -1),
  error(['NCREAD: ncopen - unable to open file: ' fname])
  return
end,

% Supress all error messages from NetCDF.

[status]=mexcdf('setopts',0);

%----------------------------------------------------------------------------
% Inquire about requested variable.
%----------------------------------------------------------------------------

% Get variable ID.

[varid]=mexcdf('ncvarid',ncid,vname);
if (varid < 0),
  [status]=mexcdf('ncclose',ncid);
  nc_inq(fname);
  disp('  ');
  error(['NCREAD: ncvarid - cannot find variable: ',vname])
  return
end,

% Inquire about unlimmited dimension.

[ndims,nvars,natts,recdim,status]=mexcdf('ncinquire',ncid);
if (status == -1),
  error(['NCREAD: ncinquire - cannot inquire file: ',fname])
end,

% Get information about requested variable.

[vname,nctype,nvdims,dimids,nvatts,status]=mexcdf('ncvarinq',ncid,varid);
if (status == -1),
  error(['NCREAD: ncvarinq - unable to inquire about variable: ',vname])
end,

% Inquire about dimensions.

index=0;
for n=1:nvdims
  [name,dsize,status]=mexcdf('ncdiminq',ncid,dimids(n));
  if (status == -1),
    error(['NCREAD: ncdiminq - unable to inquire about dimension ID: ',...
          num2str(dimids(n))])
  else
    lstr=length(name);
    dimnam(n,1:lstr)=name(1:lstr);
    dimsiz(n)=dsize;
    start(n)=0;
    count(n)=dsize;
    if ((dimids(n) == recdim) | ~isempty(findstr(name,'time'))),
      index=n;
    end,
  end,
end,

%  It reading specific time record, reset variable bounds.

nvdim=nvdims;
if (time_rec & (index > 0)),
  start(index)=tindex-1;
  count(index)=1;
  nvdims=nvdims-1;
else
  index=0;
end,

%----------------------------------------------------------------------------
% Read in requested variable.
%----------------------------------------------------------------------------

%  Read in scalar.

if (nvdim == 0),
  [f,status]=mexcdf('ncvarget1',ncid,varid,[0]);
  if (status == -1),
    error(['NCREAD: ncvarget1 - error while reading: ',vname])
  end,

%  Read in an element of a vector.

elseif (nvdim == 1),
  [f,status]=mexcdf('ncvarget',ncid,varid,start,count);
  if (status == -1),
    error(['NCREAD: ncvarget - error while reading: ',vname])
  end,

%  Read in a vector or a matrix.

elseif (nvdims == 1 | nvdims == 2),
  [f,status]=mexcdf('ncvarget',ncid,varid,start,count);
  if (status == -1),
    error(['NCREAD: ncvarget - error while reading: ',vname])
  end,

%  Read in a 3D-array.

elseif (nvdims == 3),
  [v,status]=mexcdf('ncvarget',ncid,varid,start,count);
  if (status == -1),
    error(['NCREAD: ncvarget - error while reading: ',vname])
  end,
  if (length(start) == 3),
    f=reshape(v,[count(3),count(2),count(1)]);
  elseif (length(start) == 4),
    f=reshape(v,[count(4),count(3),count(2)]);
  end,

%  Read in a 4D-array.

elseif (nvdims == 4),
  [v,status]=mexcdf('ncvarget',ncid,varid,start,count);
  if (status == -1),
    error(['NCREAD: ncvarget - error while reading: ',vname])
  end,
  if (length(start) == 4),
    f=reshape(v,[count(4),count(3),count(2),count(1)]);
  elseif (length(start) == 5),
    f=reshape(v,[count(5),count(4),count(3),count(2)]);
  end,  
  
end,

% Print information about variable.

if (IPRINT),
  if (nvdims > 0),
    disp('  ')
    disp([vname ' has the following dimensions (input order):']);
    disp('  ')
    for n=1:nvdim,
      s=['           '  int2str(n) ') ' dimnam(n,:) ' = ' int2str(dimsiz(n))];
      disp(s);
    end,
    disp('  ')
    disp([vname ' loaded into an array of size:  [' int2str(size(f)) ']']);
    disp('  ')
  else
    disp('  ')
    disp([vname ' is a scalar and has a value of ',num2str(f)]);
    disp('  ')
  end,
end,
    
%----------------------------------------------------------------------------
% Close NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['NCREAD: ncclose - unable to close NetCDF file.'])
end

return
