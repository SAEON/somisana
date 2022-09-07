#!/bin/bash
#
#======================================================================
#
#        Script for running CROCO-WRF coupled simulations 
#                       with OASIS coupler
#
#======================================================================
#
export CROCO_FILES_DIR=$PWD/croco_files
export WRF_FILES_DIR=$PWD/wrf_files
export OASIS_FILES_DIR=$PWD/oasis_files
export WORKDIR=$PWD/outputs
export CROCO_EXE_DIR=$CROCO_FILES_DIR
export WRF_EXE_DIR=$HOME/WRF/WRFV3_coupled/run

NB_PROC_CROCO=2
NB_PROC_WRF=2
#
#=============== END USER CHANGES =====================================
#
# Clean Workdir
rm -Rf $WORKDIR/*

# Link executable
ln -sf $CROCO_EXE_DIR/croco $WORKDIR/croco3d
ln -sf $WRF_EXE_DIR/wrf.exe $WORKDIR/wrfexe

# Copy the croco input files
ln -sf ${CROCO_FILES_DIR}/croco_grd.nc* $WORKDIR
ln -sf ${CROCO_FILES_DIR}/croco_ini.nc* $WORKDIR
ln -sf ${CROCO_FILES_DIR}/croco_clm.nc $WORKDIR
ln -sf ${CROCO_FILES_DIR}/croco_frc.nc $WORKDIR
ln -sf ${CROCO_FILES_DIR}/croco.in* $WORKDIR

# For AGRIF
ln -sf ${CROCO_FILES_DIR}/AGRIF_FixedGrids.in $WORKDIR

# Copy the wrf input file
ln -sf ${WRF_FILES_DIR}/*_d01 $WORKDIR
ln -sf ${WRF_FILES_DIR}/*TBL $WORKDIR
ln -sf ${WRF_FILES_DIR}/*DATA $WORKDIR
ln -sf ${WRF_FILES_DIR}/*DBL $WORKDIR
ln -sf ${WRF_FILES_DIR}/namelist.input $WORKDIR

# Copy the oasis input files
ln -sf ${OASIS_FILES_DIR}/cf_name_table.txt $WORKDIR
ln -sf ${OASIS_FILES_DIR}/namcouple $WORKDIR/namcouple
ln -sf ${OASIS_FILES_DIR}/*.nc $WORKDIR/

## Execution
cd $WORKDIR
mpirun -np $NB_PROC_WRF ./wrfexe : -np $NB_PROC_CROCO ./croco3d
#mpirun -np $NB_PROC_WRF ./wrfexe : -np $NB_PROC_CROCO ./croco3d > run.log 2>&1
cd ../
#

