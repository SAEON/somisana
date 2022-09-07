mypath='/obs/OA_COUPLING/croco_tools_v3.1/';
addpath([mypath,'Serena'])
addpath('/obs/OA_COUPLING/SCRIPTS_Serena/modif_mask')
addpath([mypath,'netcdf_matlab'])
addpath([mypath,'netcdf_matlab/ncfiles'])
addpath([mypath,'netcdf_matlab/nctype'])
addpath([mypath,'netcdf_matlab/ncutility'])
addpath([mypath,'mexnc'])   % 32 and 64 bits version of mexnc 
%
% ------------WRFP0 and CPLMASK_d01-----------------------
%
mskname='../OASIS_FILES_WRFzoomLR/masks.nc';
nc=netcdf(mskname,'write');
mymask=nc{'wrn0.msk'}(:);

mymask=1-mymask;
save mymask
modifmask('mymask.mat');r=input(' Finished with edit mask ? [press enter when finished]','s');
load mymask
mymask=1-mymask;

mymask(end,:)=1;
mymask(:,end)=1;
nc{'wrp0.msk'}(:)=mymask;
close(nc);

mskname='../OASIS_FILES_WRFzoomLR/CPLMASK_d01.nc';
nc=netcdf(mskname,'write');
wrfg(1,:,:)=1.-mymask(1:end-1,1:end-1);
wrfg(2,:,:)=0.;
nc{'CPLMASK'}(:,:,:)=wrfg;
close(nc);
clear all;

%
% ------------WRFP1 and CPLMASK_d02-----------------------
%
mskname='../OASIS_FILES_WRFzoomLR/masks.nc';
nc=netcdf(mskname,'write');
mymask=nc{'wrn1.msk'}(:);

mymask=1-mymask;
save mymask
modifmask('mymask.mat');r=input(' Finished with edit mask ? [press enter when finished]','s');
load mymask
mymask=1-mymask;

mymask(end,:)=1;
mymask(:,end)=1;
nc{'wrp1.msk'}(:)=mymask;
close(nc);

mskname='../OASIS_FILES_WRFzoomLR/CPLMASK_d02.nc';
nc=netcdf(mskname,'write');
wrfg(2,:,:)=1.-mymask(1:end-1,1:end-1);
wrfg(1,:,:)=0.;
nc{'CPLMASK'}(:,:,:)=wrfg;
close(nc);
clear all;

