function [status]=nc_write(fname,vname,f,tindex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [status]=nc_write(fname,vname,f,tindex)                          %
%                                                                           %
% This routine writes in a generic multi-dimensional field into a NetCDF    %
% file.                                                                     %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF file name (character string).                       %
%    vname       NetCDF variable name to read (character string).           %
%    f           Field (scalar, matrix or array).                           %
%    tindex      Optional, time index to write (integer):                   %
%                  *  If tindex is not provided as an argument during       %
%                     function call, it is assumed that entire variable     %
%                     is to be written.                                     %
%                  *  If variable has an unlimitted record dimension,       %
%                     tindex can be used to increase that dimension or      %
%                     replace an already existing record.                   %
%                  *  If variable has the word "time" in its dimension      %
%                     name, tindex can be use to write at the specified     %
%                     the time record.                                      %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    status      Error flag.                                                %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Activate switch for writing specific record.

time_rec=0;
if (nargin > 3),
  time_rec=1;
end,

%  Open NetCDF file.

[ncid]=mexcdf('ncopen',fname,'nc_write');
if (ncid == -1),
  error(['NC_WRITE: ncopen - unable to open file: ', fname])
  return
end

%  Supress all error messages from NetCDF.

[ncopts]=mexcdf('setopts',0);

%----------------------------------------------------------------------------
% Inquire about requested variable.
%----------------------------------------------------------------------------

% Get variable ID.

[varid]=mexcdf('ncvarid',ncid,vname);
if (varid < 0),
  [status]=mexcdf('ncclose',ncid);
  nc_inq(fname);
  disp('  ');
  error(['NC_WRITE: ncvarid - cannot find variable: ',vname])
  return
end,

% Inquire about unlimmited dimension.

[ndims,nvars,natts,recdim,status]=mexcdf('ncinquire',ncid);
if (status == -1),
  error(['NC_WRITE: ncinquire - cannot inquire file: ',fname])
end,

% Get information about requested variable.

[vname,nctype,nvdims,dimids,nvatts,status]=mexcdf('ncvarinq',ncid,varid);
if (status == -1),
  error(['NC_WRITE: ncvarinq - unable to inquire about variable: ',vname])
end,

% Inquire about dimensions.

index=0;
unlimited=0;
for n=1:nvdims,
  [name,size,status]=mexcdf('ncdiminq',ncid,dimids(n));
  if (status == -1),
    error(['NC_WRITE: ncdiminq - unable to inquire about dimension ID: ',...
          num2str(dimids(n))])
  else
    lstr=length(name);
    dimnam(n,1:lstr)=name(1:lstr);
    dimsiz(n)=size;
    start(n)=0;
    count(n)=size;
    if ((dimids(n) == recdim) | ~isempty(findstr(name,'time'))),
      unlimited=1;
      index=n;
    end,
  end,
end,


%  It writing specific time record, reset variable bounds.  Check
%  for for files having the more than one datum in the unlimited
%  dimension (like variational data assimilation files).

datum=0;
if (unlimited & (nvdims == 1)),
  if (length(f) > 1)
    datum=1;
    if (time_rec),
      start(index)=tindex-1;
    else,
      start(index)=0;
    end,
    count(index)=length(f);
  end,
end,

if (~datum & time_rec & (index > 0)),
  start(index)=tindex-1;
  count(index)=1;
end,


%   Compute the minimum and maximum of the data to write.

if (time_rec),
  if (nvdims == 2),
    fmin=min(f);
    fmax=max(f);
  elseif (nvdims == 3),
    fmin=min(min(f));
    fmax=max(max(f));
  elseif (nvdims == 4),
    fmin=min(min(min(f)));
    fmax=max(max(max(f)));
  elseif (nvdims == 5),
    fmin=min(min(min(min(f))));
    fmax=max(max(max(max(f))));
  end,
else,
  if (nvdims == 1),
    fmin=min(f);
    fmax=max(f);
  elseif (nvdims == 2),
    fmin=min(min(f));
    fmax=max(max(f));
  elseif (nvdims == 3),
    fmin=min(min(min(f)));
    fmax=max(max(max(f)));
  elseif (nvdims == 4),
    fmin=min(min(min(min(f))));
    fmax=max(max(max(max(f))));
  end,
end,

%----------------------------------------------------------------------------
%  Write out variable into NetCDF file.
%----------------------------------------------------------------------------

if (nvdims > 0),
  [status]=mexcdf('ncvarput',ncid,varid,start,count,f);
else,
  [status]=mexcdf('ncvarput1',ncid,varid,0,f);
end,
if (status ~= -1 & nvdims > 1),
  text(1:19)=' ';
  text(1:length(vname))=vname;
  if (nargin > 3),
    disp(['Wrote ',sprintf('%19s',text), ...
          ' into record: ',num2str(tindex,'%4.4i'), ...
          ', Min=',sprintf('%12.5e',fmin),...
          ' Max=',sprintf('%12.5e',fmax)]);
  else
    disp(['Wrote ',sprintf('%19s',text), ...
          ' Min=',sprintf('%12.5e',fmin),...
          ' Max=',sprintf('%12.5e',fmax)]);
  end,
end,

if (status == -1),
  error(['NC_WRITE: ncvarput - error while writting variable: ', vname])
end


%----------------------------------------------------------------------------
%  Close NetCDF file.
%----------------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['NC_WRITE: ncclose - unable to close NetCDF file: ', fname])
end

return
