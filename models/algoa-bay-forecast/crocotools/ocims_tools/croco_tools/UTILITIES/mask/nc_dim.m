function [dnames,dsizes]=nc_dim(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1998 Rutgers University.                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
% function [dnames,dsizes]=nc_dim(fname)                               %
%                                                                      %
% This function get dimensions information about requested NetCDF      %
% file.                                                                %
%                                                                      %
% On Input:                                                            %
%                                                                      %
%    fname      NetCDF file name (string).                             %
%                                                                      %
% On Output:                                                           %
%                                                                      %
%    dnames     Dimension names.                                       %
%    dsizes     Dimension sizes.                                       %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------------------------------------------------------
%  Open NetCDF file.
%-----------------------------------------------------------------------
 
[ncid]=mexcdf('ncopen',fname,'nc_nowrite');
if (ncid == -1),
  error(['NC_DIM: ncopen - unable to open file: ', fname]);
  return
end
 
%-----------------------------------------------------------------------
%  Supress all error messages from NetCDF.
%-----------------------------------------------------------------------
 
[ncopts]=mexcdf('setopts',0);

%-----------------------------------------------------------------------
% Inquire about contents.
%-----------------------------------------------------------------------

[ndims,nvars,natts,recdim,status]=mexcdf('ncinquire',ncid);
if (status == -1),
  error(['NC_DIM: ncinquire - cannot inquire file: ',fname]);
end,

%-----------------------------------------------------------------------
% Inquire about dimensions
%-----------------------------------------------------------------------

for n=1:ndims;
  [name,size,status]=mexcdf('ncdiminq',ncid,n-1);
  if (status == -1),
    error(['NC_DIM: ncdiminq - unable to inquire about dimension ID: ',...
          num2str(n)]);
  else,
    lstr=length(name);
    dnames(n,1:lstr)=name(1:lstr);
    dsizes(n)=size;
  end,
end,

%-----------------------------------------------------------------------
% Close NetCDF file.
%-----------------------------------------------------------------------

[status]=mexcdf('ncclose',ncid);
if (status == -1),
  error(['NC_DIM: ncclose - unable to close file: ', fname]);
  return
end,

return