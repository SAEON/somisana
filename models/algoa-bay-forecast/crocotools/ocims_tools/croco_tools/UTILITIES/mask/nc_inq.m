function nc_inq(fname)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 1997 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function nc_inq(fname)                                                    %
%                                                                           %
% This gets and prints the contents of a NetCDF file.  It displays the      %
% dimensions variables.                                                     %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF file name (character string).                       %
%                                                                           %
% Adapted from J.V. Mansbridge (CSIRO) "inqcdf.m" M-file.                   %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check the number of arguments.

if (nargin < 1),
  help nc_inq
  return
end

% Open the NetCDF file.
  
[ncid,rcode]=mexcdf('ncopen',fname,'nowrite');
if (rcode == -1),
  error([ 'NC_INQ: ncopen - unable to open file: ' fname])
end
disp('  ');
disp(['NetCDF file: ',fname]);

% Supress all error messages from NetCDF.

mexcdf('setopts',0);

% Inquire about the contents of NetCDf file. Display information.

[ndims,nvars,ngatts,recdim,rcode]=mexcdf('ncinquire',ncid);
if rcode == -1
  error([ 'mexcdf: ncinquire - error while inquiring file: ' fname])
end

% Get and print out information about the dimensions.

disp(' ')
disp(['Available dimensions and values:']);
disp(' ')
for i=0:ndims-1,
  [dimnam,dimsiz,rcode]=mexcdf('ncdiminq',ncid,i);
  if (i > 8),
    s=[' '  int2str(i+1) ') ' dimnam ' = ' int2str(dimsiz)];
  else
    s=['  ' int2str(i+1) ') ' dimnam ' = ' int2str(dimsiz)];
  end,
  disp(s)
end,

if (recdim <= 0),
  disp(' ')
  disp ('     None of the dimensions is unlimited.')
else
  [dimnam,dimsiz,rcode]=mexcdf('ncdiminq',ncid,recdim);
  s=['     ' dimnam ' is unlimited in length.'];
  disp(' ')
  disp(s)
end,

% Get and print information about the variables.

disp(' ')
disp(['Available Variables:']);
disp(' ')

for i=0:3:nvars-1

  stri=int2str(i+1);

  if (length(stri) == 1)
    stri=[ ' ' stri];
  end
  [varnam,vartyp,nvdims,vdims,nvatts,rcode]=mexcdf('ncvarinq',ncid,i);
  s=[ '  ' stri ') ' varnam ];
  addit=26-length(s);
  for j=1:addit
    s=[ s ' '];
  end
   
  if (i < nvars-1)
    stri=int2str(i+2);
    if (length(stri) == 1)
      stri=[ ' ' stri];
    end
    [varnam,vartyp,nvdims,vdims,nvatts,rcode]=mexcdf('ncvarinq',ncid,i+1);
    s=[ s '  ' stri ') ' varnam ];
    addit=52-length(s);
    for j=1:addit
      s=[ s ' '];
    end
  end 
   
  if (i < nvars - 2)
    stri=int2str(i+3);
    if (length(stri) == 1)
      stri=[ ' ' stri];
    end
    [varnam,vartyp,nvdims,vdims,nvatts,rcode]=mexcdf('ncvarinq',ncid,i+2);
    s=[ s '  ' stri ') ' varnam ];
  end 
  disp(s)
end

[rcode] = mexcdf('ncclose', ncid);
if (rcode == -1),
  error(['** ERROR ** ncclose: rcode = ' num2str(rcode)])
end

return
