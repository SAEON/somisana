function [vname,nvars]=nc_vname(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [vname,nvars]=nc_vname(fname);                                   %
%                                                                           %
% This function get name of variables in requested NetCDF file.             %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname      NetCDF file name (character string).                        %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    vname      Variable names.                                             %
%    nvars      Number of variables.                                        %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Open NetCDF file.
 
[ncid]=mexcdf('ncopen',fname,'nc_nowrite');
if (ncid == -1),
  error(['NC_VNAME: ncopen - unable to open file: ', fname]);
  return
end
 
%  Supress all error messages from NetCDF.
 
[ncopts]=mexcdf('setopts',0);

% Inquire about the contents of NetCDf file. Display information.

[ndims,nvars,ngatts,recdim,status]=mexcdf('ncinquire',ncid);
if (status == -1),
  error([ 'NC_VNAME: ncinquire - error while inquiring file: ' fname]);
end,

% Get and print information about the variables.

n=0;
for i=0:nvars-1,
  [name,vartyp,nvdims,vdims,nvatts,status]=mexcdf('ncvarinq',ncid,i);
  if (status == -1),
    error(['NC_VNAME: ncvarinq - unable to inquire about variable ID: ',...
          num2str(i)]);
  else,
    n=n+1;
    lstr=length(name);
    vname(n,1:lstr)=name(1:lstr);
  end,
end,

% Close NetCDF file.

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['NC_VNAME: ncclose - unable to close NetCDF file.']);
end

return
