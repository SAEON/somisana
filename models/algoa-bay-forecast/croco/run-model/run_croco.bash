#!/bin/bash

# ENV variables

RUNDIR=$1 # set as env variable called WORKDIR in .yml create-working-directory
TIME=$2 # i.e. 20220607 set as env variable called MODEL_RUN_DATE in .yml configure-runtime
TIME_prev=$3 # i.e. 20220606  set as env variable called RESTART_FILE_DATE in .yml configure-runtime

HDAYS=5   # Fixed value in this context
FDAYS=5
NH_AVG=6  # The temporal average of the output file in hours 
NH_AVGSURF=1  # The temporal average of the output file (only surface variables) in hours 
NDAYS=$((HDAYS + FDAYS)) 
INDIR=$(pwd)  # where the croco_frcst.in file is stored, in the current setup it is in the same directory

########################################################
#  Define files and run parameters
########################################################
#
MPI_NUM_PROCS=12

MODEL=croco
SCRATCHDIR=$RUNDIR/croco/scratch
#EXEDIR=$RUNDIR/exe
EXEDIR=$(pwd)
INPUTDIR_SRF=$RUNDIR/croco/forcing
INPUTDIR_BRY=$RUNDIR/croco/forcing
INPUTDIR_GRD=$RUNDIR/croco/forcing
FORECASTDIR=$RUNDIR/croco/forecast
ARCHIVEDIR=$RUNDIR/croco/archive
#TIDEDIR=$RUNDIR/tide
CODFILE=croco
#AGRIF_FILE=AGRIF_FixedGrids.in
#
BULK_FILES=1
FORCING_FILES=0
CLIMATOLOGY_FILES=1
BOUNDARY_FILES=0
#
# Atmospheric surface forcing dataset used for the bulk formula (NCEP)
#
ATMOS_BULK=GFS
#
# Atmospheric surface forcing dataset used for the wind stress (NCEP, QSCAT)
#
ATMOS_FRC=QSCAT
#
# Oceanic boundary and initial dataset (SODA, ECCO,...)
#
OGCM=MERCATOR
#
# Model time step [seconds]
#
DT0=30
NUMDTFAST=30
# timesteps for output files: number of hours
#NH_AVG=6 # now a user defined input 
NH_HIS=$((NDAYS * 24)) # only write one time-step as we'll use the avg output
#NH_AVGSURF=1 # now a user defined input
NH_HISSURF=$((NDAYS * 24)) # only write one time-step as we'll use the avg output
NH_STA=1 # station output not getting written for now
#
# Time refinement coefficient (factor to apply to time-step at each child level)
#
T_REF=1
#
# Number total of grid levels (1: No child grid)
#
NLEVEL=1
#
########################################################
#
# netcdf file prefixes
#
GRDFILE=grd
FRCFILE=frc
BLKFILE=blk
INIFILE=ini
CLMFILE=clm
BRYFILE=bry
#
echo "${INPUTDIR_SRF}/${BLKFILE}_${ATMOS_BULK}_${TIME}.nc${ENDF} ${BLKFILE}.nc${ENDF}"
echo "${INPUTDIR_BRY}/${CLMFILE}_${OGCM}_${TIME}.nc ${CLMFILE}.nc"
echo "${INPUTDIR_GRD}/${GRDFILE}.nc${ENDF} $SCRATCHDIR"
# Get the code
#
cd $SCRATCHDIR
#echo "Getting $CODFILE from $EXEDIR"
cp -f $EXEDIR/$CODFILE $SCRATCHDIR
chmod u+x $CODFILE
#echo "Getting $AGRIF_FILE from ${INPUTDIR_BRY}"
#cp -f ${INPUTDIR_BRY}/$AGRIF_FILE $SCRATCHDIR
#echo "Getting stations file from $RUNDIR"
#cp -f $RUNDIR/stations.in $SCRATCHDIR
#cp -f $TIDEDIR/frc.nc $SCRATCHDIR
#
# remove old input/output files that might be lingering around
rm -f $SCRATCHDIR/*.in
rm -f $SCRATCHDIR/*.out

#
# Get the netcdf files for run initiation
#
RSTFILE=rst_${TIME_prev}
#
LEVEL=0
while [ $LEVEL != $NLEVEL ]; do
  if [[ ${LEVEL} == 0 ]]; then
    ENDF=
  else
    ENDF=.${LEVEL}
  fi
  #echo "Getting ${GRDFILE}.nc${ENDF} from ${INPUTDIR_BRY}"
  ln -sf ${INPUTDIR_GRD}/${GRDFILE}.nc${ENDF} $SCRATCHDIR
  #echo "Getting ${MODEL}_frcst.in${ENDF} from $RUNDIR"
  cp -f $INDIR/${MODEL}_frcst.in${ENDF} $SCRATCHDIR
  # check to see if a restart file exists to initialise from
  # otherwise we initialise from the global model (ini)
  # The rst file moved to the croco/forcing directory (INPUTDIR_BRY)
  if test -f "$INPUTDIR_BRY/${RSTFILE}.nc${ENDF}"; then
    echo "Using initial condition from $FORECASTDIR/${RSTFILE}.nc${ENDF}"
    ln -sf $INPUTDIR_BRY/${RSTFILE}.nc${ENDF} ${INIFILE}.nc${ENDF}
    RST=1
  else
    echo "Using initial condition from ${INPUTDIR_BRY}/${INIFILE}_${OGCM}_${TIME}.nc${ENDF}"
    ln -sf ${INPUTDIR_BRY}/${INIFILE}_${OGCM}_${TIME}.nc${ENDF} ${INIFILE}.nc${ENDF}
    RST=0
  fi
  LEVEL=$((LEVEL + 1))
done
###########################################################
#  Compute
###########################################################
#
# Get forcing and clim for this time
#
LEVEL=0
while [ $LEVEL != $NLEVEL ]; do
  if [[ ${LEVEL} == 0 ]]; then
    ENDF=
  else
    ENDF=.${LEVEL}
  fi
  if [[ ${FORCING_FILES} == 1 ]]; then
    #echo "Getting ${FRCFILE}_${ATMOS_FRC}_${TIME}.nc${ENDF} from ${INPUTDIR_SRF}"
    ln -sf ${INPUTDIR_SRF}/${FRCFILE}_${ATMOS_FRC}_${TIME}.nc${ENDF} ${FRCFILE}.nc${ENDF}
  fi
  if [[ ${BULK_FILES} == 1 ]]; then
    #echo "Getting ${BLKFILE}_${ATMOS_BULK}_${TIME}.nc${ENDF} from ${INPUTDIR_SRF}"
    ln -sf ${INPUTDIR_SRF}/${BLKFILE}_${ATMOS_BULK}_${TIME}.nc${ENDF} ${BLKFILE}.nc${ENDF}
  fi
  LEVEL=$((LEVEL + 1))
done
#
# No child climatology or boundary files
#
if [[ ${CLIMATOLOGY_FILES} == 1 ]]; then
  #echo "Getting ${CLMFILE}_${OGCM}_${TIME}.nc from ${INPUTDIR_BRY}"
  ln -sf ${INPUTDIR_BRY}/${CLMFILE}_${OGCM}_${TIME}.nc ${CLMFILE}.nc
fi
if [[ ${BOUNDARY_FILES} == 1 ]]; then
  #echo "Getting ${BRYFILE}_${OGCM}_${TIME}.nc from ${INPUTDIR_BRY}"
  ln -sf ${INPUTDIR_BRY}/${BRYFILE}_${OGCM}_${TIME}.nc ${BRYFILE}.nc
fi
#

DT=$DT0

NUMTIMES=$((NDAYS * 24 * 3600))
NUMTIMES=$((NUMTIMES / DT))

NUMRST=$((1 * 24 * 3600)) #restart file written 1 day from start
NUMRST=$((NUMRST / DT))

NUMAVG=$((NH_AVG*3600))
NUMAVG=$((NUMAVG / DT))

NUMHIS=$((NH_HIS*3600))
NUMHIS=$((NUMHIS / DT))

NUMAVGSURF=$((NH_AVGSURF*3600))
NUMAVGSURF=$((NUMAVGSURF / DT))

NUMHISSURF=$((NH_HISSURF*3600))
NUMHISSURF=$((NUMHISSURF / DT))

NUMSTA=$((NH_STA*3600))
NUMSTA=$((NUMSTA / DT))

echo "Baroclinic timestep = $DT s"
echo "Output frequency for full domain = $NH_AVG hrs"
echo "Output frequency for surface layer = $NH_AVGSURF hrs"
# 
#echo "Writing in ${MODEL}_${TIME}.in"
LEVEL=0
while [[ $LEVEL != $NLEVEL ]]; do
  if [[ ${LEVEL} == 0 ]]; then
    ENDF=
  else
    ENDF=.${LEVEL}
    DT=$((DT / T_REF))
    NUMTIMES=$((T_REF * NUMTIMES))
    NUMRST=$((T_REF * NUMRST))
    NUMAVG=$((T_REF * NUMAVG))
    NUMHIS=$((T_REF * NUMHIS))
    NUMAVGSURF=$((T_REF * NUMAVGSURF))
    NUMHISSURF=$((T_REF * NUMHISSURF))
    NUMSTA=$((T_REF * NUMSTA))
  fi
  #echo "USING NUMTIMES = $NUMTIMES"
  sed -e 's/DTNUM/'$DT'/' -e 's/NUMDTFAST/'$NUMDTFAST'/' -e 's/NUMTIMES/'$NUMTIMES'/' -e 's/NUMRST/'$NUMRST'/' -e 's/NUMHISSURF/'$NUMHISSURF'/' -e 's/NUMAVGSURF/'$NUMAVGSURF'/' -e 's/NUMHIS/'$NUMHIS'/' -e 's/NUMAVG/'$NUMAVG'/' -e 's/NUMSTA/'$NUMSTA'/' < ${MODEL}_frcst.in${ENDF} > ${MODEL}_${TIME}.in${ENDF}
  LEVEL=$((LEVEL + 1))
done

#
#  COMPUTE
#
#date
mpirun -np $MPI_NUM_PROCS ./$CODFILE ${MODEL}_${TIME}.in > ${MODEL}_${TIME}.out
#date
#
# Test if the simulation finised properly
#echo "Test ${MODEL}_${TIME}.out"
status=`tail -2 ${MODEL}_${TIME}.out | grep DONE | wc -l`
if [[ $status == 1 ]]; then
  echo
  echo "CROCO ran without errors"
  echo
else
  echo
  echo "Warning: CROCO run did not finished properly"
  echo
  tail -20 ${MODEL}_${TIME}.out
  echo
  echo "${TIME} did not work"
  echo
  exit 1
fi

