#!/bin/bash

#ENV variables

RUNDIR=$1 # set as env variable called WORKDIR in .yml create-working-directory
TIME=$2 # i.e. 20220607 set as env variable called MODEL_RUN_DATE in .yml configure-runtime
TIME_prev=$3 # i.e. 20220606  set as env variable called RESTART_FILE_DATE in .yml configure-runtime

HDAYS=5 # Fixed value in this context
FDAYS=5
NH_AVG=1 # The temporal average of the output file in hours edited to save every hour
NH_AVGSURF=1  # The temporal average of the output file (only surface variables) in hours 
NDAYS=$((HDAYS + FDAYS)) 
INDIR=$(pwd)  # where the croco_frcst.in file is stored, in the current setup it is in the same directory
MPI_NUM_PROCS=8 # TODO - can this be done dynamically? What about parallel computing?
EXEDIR=$(pwd)
INPUTDIR=$RUNDIR/croco/forcing
AGRIF_FILE=$RUNDIR/croco/forcing/AGRIF_FixedGrids.in
SCRATCHDIR=$RUNDIR/croco/scratch
BULK_FILES=1
FORCING_FILES=0
CLIMATOLOGY_FILES=1
BOUNDARY_FILES=0
ATMOS_BULK=GFS # Atmospheric surface forcing dataset used for the bulk formula (NCEP)
ATMOS_FRC=QSCAT # Atmospheric surface forcing dataset used for the wind stress (NCEP, QSCAT)
OGCM=MERCATOR # Oceanic boundary and initial dataset (SODA, ECCO,...)
DT0=180 # Model time step [seconds]
NUMDTFAST=60 # Also related to time stepping? TODO - please correct/confirm
T_REF=3 # Time refinement coefficient (factor to apply to time-step at each child level)
NLEVEL=2 # Number total of grid levels (1: No child grid)
RSTFILE=rst_${TIME_prev} # Restart file

# timesteps for output files: number of hours
NH_HIS=$((NDAYS * 24)) # only write one time-step as we'll use the avg output
NH_HISSURF=$((NDAYS * 24)) # only write one time-step as we'll use the avg output
NH_STA=1 # station output not getting written for now ? TODO - not sure what this means

# netcdf file prefixes
GRDFILE=grd
FRCFILE=frc
BLKFILE=blk
INIFILE=ini
CLMFILE=clm
BRYFILE=bry

echo "Moving atmospher forcing (GFS) from ${INPUTDIR}/${BLKFILE}_${ATMOS_BULK}_${TIME}.nc to $SCRATCHDIR/${BLKFILE}.nc"
echo "Moving mercator forcings (side forcings) from ${INPUTDIR}/${CLMFILE}_${OGCM}_${TIME}.nc to $SCRATCHDIR/${CLMFILE}.nc"
echo "Moving grid file from ${INPUTDIR}/${GRDFILE}.nc to $SCRATCHDIR/"

cd $SCRATCHDIR
cp -f $EXEDIR/croco $SCRATCHDIR
chmod u+x croco

# remove old input/output files that might be lingering around
rm -f $SCRATCHDIR/*.in
rm -f $SCRATCHDIR/*.out

#Added AGRIF_FILE to scratch directory Matt 
cp -f $AGRIF_FILE $SCRATCHDIR

LEVEL=0
while [ $LEVEL != $NLEVEL ]; do
  if [[ ${LEVEL} == 0 ]]; then
    ENDF=
  else
    ENDF=.${LEVEL}
  fi
  #echo "Getting ${GRDFILE}.nc${ENDF} from ${INPUTDIR_BRY}"
  ln -sf ${INPUTDIR_BRY}/${GRDFILE}.nc${ENDF} $SCRATCHDIR
  #echo "Getting ${MODEL}_frcst.in${ENDF} from $RUNDIR"
  cp -f $RUNDIR/croco_frcst.in${ENDF} $SCRATCHDIR
  # check to see if a restart file exists to initialise from
  # otherwise we initialise from the global model
  # (I guess I could have used the make_ini variable as an input
  # to this script but I already had this code which seems to work fine) 
  if test -f "$FORECASTDIR/${RSTFILE}.nc${ENDF}"; then
    echo "Using initial condition from $FORECASTDIR/${RSTFILE}.nc${ENDF}"
    ln -sf $FORECASTDIR/${RSTFILE}.nc${ENDF} ${INIFILE}.nc${ENDF}
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
  sed -e 's/DTNUM/'$DT'/' -e 's/NUMDTFAST/'$NUMDTFAST'/' -e 's/NUMTIMES/'$NUMTIMES'/' -e 's/NUMRST/'$NUMRST'/' -e 's/NUMHISSURF/'$NUMHISSURF'/' -e 's/NUMAVGSURF/'$NUMAVGSURF'/' -e 's/NUMHIS/'$NUMHIS'/' -e 's/NUMAVG/'$NUMAVG'/' -e 's/NUMSTA/'$NUMSTA'/' < croco_frcst.in${ENDF} > croco_${TIME}.in${ENDF}
  LEVEL=$((LEVEL + 1))
done

#
#  COMPUTE
#
#date
mpirun -np $MPI_NUM_PROCS ./croco croco_${TIME}.in > croco_${TIME}.out
#date
#
# Test if the simulation finised properly
#echo "Test ${MODEL}_${TIME}.out"
status=`tail -2 croco_${TIME}.out | grep DONE | wc -l`
if [[ $status == 1 ]]; then
  echo
  echo "CROCO ran without errors"
  echo
else
  echo
  echo "Warning: CROCO run did not finished properly"
  echo
  tail -20 croco_${TIME}.out
  echo
  echo "${TIME} did not work"
  echo
  exit 1
fi
