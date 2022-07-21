function var = extract_ECMWF(ifile,fname,year,month,...
                      tndx,...
                      i1min,i1max,i2min,i2max,i3min,i3max,...
                      jmin,jmax)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subset from ECMWF
% 
% From extract_NCEP
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get the variable name
%
disp(['Get ',fname,' for year ',num2str(year),...
      ' - month ',num2str(month)])
%
% Get the variable 2D subset (take care of greenwitch)
%
nc=netcdf(ifile);
numdimvar0=ncsize(nc{fname});
numdimvar=length(numdimvar0);
if ~isempty(i1min)
    if ( numdimvar > 3 )
      var1=squeeze(nc{fname}(tndx,1,jmin:jmax,i1min:i1max));
    else
      var1=squeeze(nc{fname}(tndx,jmin:jmax,i1min:i1max));
    end
else
    var1=[];
end
%
if ~isempty(i2min)
    if ( numdimvar > 3 )
      var2=squeeze(nc{fname}(tndx,1,jmin:jmax,i2min:i2max));
    else
      var2=squeeze(nc{fname}(tndx,jmin:jmax,i2min:i2max));
    end
else
    var2=[];
end
%  
if ~isempty(i3min)
    if ( numdimvar > 3 )
      var3=squeeze(nc{fname}(tndx,1,jmin:jmax,i3min:i3max));  
    else
      var3=squeeze(nc{fname}(tndx,jmin:jmax,i3min:i3max));    
    end
else
    var3=[];
end
%
var=cat(3,var1,var2,var3);
%
% North-South inversion
%
if (length(size(var))==2)
    var=flipdim(var,1);
elseif (length(size(var))==3)
    var=flipdim(var,2);
end
%
add_offset=nc{fname}.add_offset(:);
if isempty(add_offset)
    add_offset=0;    
end
scale_factor=nc{fname}.scale_factor(:);
if isempty(scale_factor)
    scale_factor=1;
end
missing_value=nc{fname}.missing_value(:);
if isempty(missing_value)
    missing_value=-99999;
end
close(nc)
%
% Correct the variable
%
var(var==missing_value)=NaN;
var=add_offset+var.*scale_factor;


return

