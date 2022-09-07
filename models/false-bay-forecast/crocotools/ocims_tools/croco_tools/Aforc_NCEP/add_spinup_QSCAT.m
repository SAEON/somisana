%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add the year of atmospheric forcings for the spin up year after make_ncep
%  if you misfit them ....
%
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
%
if NCEP_version==1
  ncep_frc_prefix=[frc_prefix,'_NCEP1_'];                           
  ncep_blk_prefix=[blk_prefix,'_NCEP1_'];
elseif NCEP_version==2
  ncep_frc_prefix=[frc_prefix,'_NCEP2_'];                           
  ncep_blk_prefix=[blk_prefix,'_NCEP2_'];
end
%
QSCAT_frc_prefix=[ncep_frc_prefix,'wQS_'];
QSCAT_blk_prefix=[ncep_blk_prefix,'wQS_'];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end of user input  parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if level==0
  nc_suffix='.nc';
else
  nc_suffix=['.nc.',num2str(level)];
  grdname=[grdname,'.',num2str(level)];
end
% Spin-up: (reproduce the first year 'SPIN_Long' times)
% just copy the files for the first year and change the time
%
if SPIN_Long>0
  M=Mmin-1;
  Y=Ymin-SPIN_Long;
  for month=1:12*SPIN_Long
    M=M+1;
    if M==13
      M=1; 
      Y=Y+1;
    end
    %
    % Forcing files
    %
    if makefrc==1
      %
      % Copy the file
      %
      frcname=[QSCAT_frc_prefix,'Y',num2str(Ymin),'M',num2str(M),nc_suffix];
      frcname2=[QSCAT_frc_prefix,'Y',num2str(Y),'M',num2str(M),nc_suffix];
      disp(['Create ',frcname2]) 
      eval(['!cp ',frcname,' ',frcname2]) 
      %
      % Change the time
      %
      nc=netcdf(frcname2,'write');
      time=nc{'sms_time'}(:)+datenum(Yorig,1,1);
      [y,m,d,h,mi,s]=datevec(time);
      dy=Ymin-Y;
      y=y-dy;
      time=datenum(y,m,d,h,mi,s)-datenum(Yorig,1,1);
      %      disp(datestr(time+datenum(Yorig,1,1)))
      nc{'sms_time'}(:)=time;
      close(nc)
    end
    %
    % Bulk files
    %
    if makeblk==1
      %
      % Copy the file
      %
      blkname=[QSCAT_blk_prefix,'Y',num2str(Ymin),'M',num2str(M),nc_suffix];
      blkname2=[QSCAT_blk_prefix,'Y',num2str(Y),'M',num2str(M),nc_suffix];
      disp(['Create ',blkname2]) 
      eval(['!cp ',blkname,' ',blkname2]) 
      %
      % Change the time
      %
      nc=netcdf(blkname2,'write');
      time=nc{'bulk_time'}(:)+datenum(Yorig,1,1);
      [y,m,d,h,mi,s]=datevec(time);
      dy=Ymin-Y;
      y=y-dy;
      time=datenum(y,m,d,h,mi,s)-datenum(Yorig,1,1);
      %      disp(datestr(time+datenum(Yorig,1,1)))
      nc{'bulk_time'}(:)=time;
      close(nc)
    end
  end
end
%---------------------------------------------------------------
% Make a few plots
%---------------------------------------------------------------
if makeplot==1
  disp(' ')
  disp(' Make a few plots...')
  slides=[1 25 50 75];
  test_forcing(blkname,grdname,'tair',slides,3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'rhum',slides,3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'prate',slides,3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'uwnd',slides,3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'vwnd',slides,3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'wspd',slides,3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'radlw',slides,3,coastfileplot)
  figure
  test_forcing(blkname,grdname,'radsw',slides,3,coastfileplot)
end
