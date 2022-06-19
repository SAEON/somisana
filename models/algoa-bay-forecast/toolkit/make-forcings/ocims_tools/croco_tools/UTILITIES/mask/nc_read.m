function [f]=nc_read(fname,vname,tindex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2002 Rutgers University.                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                           %
% function [f]=nc_read(fname,vname,tindex)                                  %
%                                                                           %
% This function reads in a generic multi-dimensional field from a NetCDF    %
% file.  If only water points are available, this function fill the land    %
% areas with zero and returns full fields.                                  %
%                                                                           %
% On Input:                                                                 %
%                                                                           %
%    fname       NetCDF file name (character string).                       %
%    vname       NetCDF variable name to read (character string).           %
%    tindex      Optional, time index to read (integer):                    %
%                  *  If argument "tindex" is provided, only the requested  %
%                     time record is read when the variable has unlimitted  %
%                     dimension or the word "time" in any of its dimension  %
%                     names.                                                %
%                                                                           %
% On Output:                                                                %
%                                                                           %
%    f           Field (scalar, matrix or array).                           %
%    status      Error flag.                                                %
%                                                                           %
% calls:         nc_dim, nc_vinfo, nc_vname, ncread                         %
%                                                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------
% Inquire information from NetCDF file.
%----------------------------------------------------------------------------

% Inquire about file dimensions.

[dnames,dsizes]=nc_dim(fname);

for n=1:length(dsizes),
  name=deblank(dnames(n,:));
  switch name
    case 'xi_rho',
      Lr=dsizes(n);
    case 'xi_u',
      Lu=dsizes(n);
    case 'xi_v',
      Lv=dsizes(n);
    case 'eta_rho',
      Mr=dsizes(n);
    case 'eta_u',
      Mu=dsizes(n);
    case 'eta_v',
      Mv=dsizes(n);
    case 's_rho',
      Nr=dsizes(n);
    case 's_w',
      Nw=dsizes(n);
  end,
end,  
 
% Inquire about requested variable.

[vdnames,vdsizes,igrid]=nc_vinfo(fname,vname);

% Check if data is only available at water points.

is2d=0;
is3d=0;
water=0;
if (~isempty(vdsizes)),
  for n=1:length(vdsizes),
    name=deblank(vdnames(n,:));
    switch name
      case 'xy_rho',
        msknam='mask_rho';
        is2d=1; Im=Lr; Jm=Mr;
      case 'xy_u',
        msknam='mask_u';
        is2d=1; Im=Lu; Jm=Mu;
      case 'xy_v',
        msknam='mask_v';
        is2d=1; Im=Lv; Jm=Mv;
      case 'xyz_rho',
        msknam='mask_rho';
        is3d=1; Im=Lr; Jm=Mr; Km=Nr;
      case 'xyz_u',
        msknam='mask_u';
        is3d=1; Im=Lu; Jm=Mu; Km=Nr;
      case 'xyz_v',    
        msknam='mask_v';
        is3d=1; Im=Lv; Jm=Mv; Km=Nr;
      case 'xyz_w',    
        msknam='mask_rho';
        is3d=1; Im=Lr; Jm=Mr; Km=Nw;
    end,
  end,
end,
water=is2d | is3d;

% If water data only, read in Land/Sea mask.

got_mask=0;

if (water),
  [Vnames,nvars]=nc_vname(fname);
  got_mask=strmatch(msknam,Vnames);
  if (got_mask),
    mask=ncread(fname,msknam);
  else,
%   [fn,pth]=uigetfile(grid_file,'Enter grid NetCDF file...');
%   gname=[pth,fn];
    gname=input('Enter grid NetCDF file: ');
    mask=ncread(gname,msknam);
  end,
end,

%----------------------------------------------------------------------------
% Read in requested variable.
%----------------------------------------------------------------------------

if (water),

  if (nargin < 3),
    v=ncread(fname,vname);
  else
    v=ncread(fname,vname,tindex);
  end,
  [Npts,Ntime]=size(v);

  if (is2d),
    f=squeeze(zeros([Im,Jm,Ntime]));
    MASK=squeeze(repmat(mask,[1,1,Ntime]));
    ind=find(MASK > 0);
    f(ind)=v;
  elseif (is3d),    
    Im,Jm,Km
    size(v)
    f=squeeze(zeros([Im,Jm,Km,Ntime]));
    MASK=squeeze(repmat(mask,[1,1,Km,Ntime]));
    ind=find(MASK > 0);
    f(ind)=v;
  end,

else,

  if (nargin < 3),
    f=ncread(fname,vname);
  else
    f=ncread(fname,vname,tindex);
  end,
  
end,

return
