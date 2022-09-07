#!/bin/bash
#
#======================================================================
#
#        OASIS namcouple generator for CROCO-WRF coupling
#
#======================================================================
#
functions_path=$HOME/OASIS/functions

export CROCO_FILES_DIR=$HOME/OASIS/Run_benguela_lr_oa/croco_files
export WRF_FILES_DIR=$HOME/OASIS/Run_benguela_lr_oa/wrf_files
export OASIS_FILES_DIR='./'

croco_grid_file=$CROCO_FILES_DIR/croco_grd.nc
wrf_grid_file=$WRF_FILES_DIR/geo_em.d01.nc
wrf_inp_file=$WRF_FILES_DIR/wrfinput_d01

myconfig='TOY'
mydate=`date +%Y%m%d`

max_domains_WRF=1
max_domains_CROCO=1
#
#=============== END USER CHANGES =====================================
#
. ${functions_path}/create_croco_grids_function.sh
. ${functions_path}/create_croco_masks_function.sh
. ${functions_path}/create_croco_corners_function.sh
. ${functions_path}/create_croco_areas_function.sh
. ${functions_path}/create_wrf_grids_function.sh
. ${functions_path}/create_wrf_masks_function.sh
. ${functions_path}/create_wrf_corners_function.sh
. ${functions_path}/create_wrf_areas_function.sh
. ${functions_path}/create_wrf_CPLMASK_function.sh
. ${functions_path}/duplicate_wrf_CPLMASK_function.sh
#
#--------------
#1. Grid names
#--------------
RRN0='rrn0' # croco Rho Normal    0=Parent
RRP0='rrp0' # croco Rho Processed 0=Parent
RUN0='run0' # croco U   Normal    0=Parent
RUP0='rup0' # croco U   Processed 0=Parent
RVN0='rvn0' # croco V   Normal    0=Parent
RVP0='rvp0' # croco V   Processed 0=Parent
#
WRN0='wrn0' # WRF Rho Normal    0=Parent
WRP0='wrp0' # WRF Rho Processed 0=Parent
#
#-----------------------------------------------
# 2. Processing CROCO Grids: Parent and Children
#-----------------------------------------------
DNcroco=1
while [ $DNcroco -le $max_domains_CROCO ]; do
  SNcroco=`expr $DNcroco \- 1`
  create_croco_grids_function $SNcroco
  create_croco_corners_function $SNcroco
  create_croco_masks_function $SNcroco
  create_croco_areas_function $SNcroco
  if [ $DNcroco = 1 ]; then
     ncks -A corners_croco.nc grids_croco.nc
  else
     ncks -A corners_croco.nc.$SNcroco grids_croco.nc.$SNcroco
     ncks -A grids_croco.nc.$SNcroco grids_croco.nc
     ncks -A masks_croco.nc.$SNcroco masks_croco.nc
     ncks -A areas_croco.nc.$SNcroco areas_croco.nc
  fi
  let DNcroco=DNcroco+1
done
#
#----------------------------------------------
# 3. Processing WRF Grids: Parent and Children
#----------------------------------------------
#
DNwrf=1
while [ $DNwrf -le $max_domains_WRF ]; do
  SNwrf=`expr $DNwrf \- 1`
  create_wrf_grids_function $SNwrf
  create_wrf_masks_function $SNwrf
  create_wrf_corners_function $SNwrf
  create_wrf_areas_function $SNwrf
  create_wrf_CPLMASK_function $SNwrf
  DNcroco=2
  if [ $max_domains_CROCO -gt 1 ]; then
     duplicate_wrf_CPLMASK_function $SNwrf $max_domains_CROCO
  fi
  if [ $DNwrf = 1 ]; then
     ncks -A corners_wrf.nc grids_wrf.nc
  else
     ncks -A corners_wrf.nc.$SNwrf grids_wrf.nc.$SNwrf
     ncks -A grids_wrf.nc.$SNwrf grids_wrf.nc
     ncks -A masks_wrf.nc.$SNwrf masks_wrf.nc
     ncks -A areas_wrf.nc.$SNwrf areas_wrf.nc
  fi
  let DNwrf=DNwrf+1
done
#
#-----------------------------------
# 4. Merging CROCO and WRF  the files
#-----------------------------------
echo Merging all CROCO and WRF files
mv -f grids_croco.nc grids.nc
ncks -A grids_wrf.nc grids.nc
mv -f masks_croco.nc masks.nc
ncks -A masks_wrf.nc masks.nc
mv -f areas_croco.nc areas.nc
ncks -A areas_wrf.nc areas.nc
rm -f grids_*.nc* corners*.nc* masks_*.nc* areas_*.nc*

#
#----------------------------------------
# 5. Clean history and global Attributes
#----------------------------------------
ncatted -h -O -a ,global,d,, grids.nc
ncatted -h -a title,global,c,c,"${myconfig}" grids.nc
ncatted -h -a date,global,c,c,${mydate} grids.nc

ncatted -h -O -a ,global,d,, masks.nc
ncatted -h -a title,global,c,c,"${myconfig}" masks.nc
ncatted -h -a date,global,c,c,${mydate} masks.nc

ncatted -h -O -a ,global,d,, areas.nc
ncatted -h -a title,global,c,c,"${myconfig}" areas.nc
ncatted -h -a date,global,c,c,${mydate} areas.nc

echo Moving files
mv -f grids.nc areas.nc masks.nc CPLMASK* ${OASIS_FILES_DIR}
#
#----------------------------
# 5. Generate namcouple file
#----------------------------
#make_namcouple.sh
#
