#!/bin/bash

# ENV variables

RUNDIR=$1 # set as env variable called WORKDIR in .yml create-working-directory
TIME=$2 # i.e. 20220607 set as env variable called MODEL_RUN_DATE in .yml configure-runtime
TIME_prev=$3 # i.e. 20220606  set as env variable called RESTART_FILE_DATE in .yml configure-runtime

HDAYS=5   # Fixed value in this context
FDAYS=5
NH_AVG=1  # The temporal average of the output file in hours edited to save every hour
NH_AVGSURF=1  # The temporal average of the output file (only surface variables) in hours 
NDAYS=$((HDAYS + FDAYS)) 
INDIR=$(pwd)  # where the croco_frcst.in file is stored, in the current setup it is in the same directory
MPI_NUM_PROCS=${NNODES:-4} # In the Docker environment, NNODES will always be set. The default is 4 when this file is used directly
EXEDIR=$(pwd)
INPUTDIR=$RUNDIR/croco/forcing
SCRATCHDIR=$RUNDIR/croco/scratch
BULK_FILES=1
FORCING_FILES=0
CLIMATOLOGY_FILES=1
BOUNDARY_FILES=0
ATMOS_BULK=GFS # Atmospheric surface forcing dataset used for the bulk formula (NCEP)
ATMOS_FRC=QSCAT # Atmospheric surface forcing dataset used for the wind stress (NCEP, QSCAT)
OGCM=MERCATOR # Oceanic boundary and initial dataset (SODA, ECCO,...)
DT0=30 # Model time step [seconds]
NUMDTFAST=30 # Also related to time stepping? TODO - please correct/confirm
T_REF=1 # Time refinement coefficient (factor to apply to time-step at each child level)
NLEVEL=1 # Number total of grid levels (1: No child grid)
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

# Configure either the rst or ini file symlinks
LEVEL=0
while [ $LEVEL != $NLEVEL ]; do
  if [[ ${LEVEL} == 0 ]]; then
    ENDF=
  else
    ENDF=.${LEVEL}
  fi
  ln -sf ${INPUTDIR}/${GRDFILE}.nc${ENDF} $SCRATCHDIR
  cp -f $INDIR/croco_frcst.in${ENDF} $SCRATCHDIR
  # Use the restart file if available
  if test -f "$INPUTDIR/${RSTFILE}.nc${ENDF}"; then
    echo "Using initial condition from $INPUTDIR/${RSTFILE}.nc${ENDF}"
    ln -sf $INPUTDIR/${RSTFILE}.nc${ENDF} ${INIFILE}.nc${ENDF}
    RST=1
  else
    # Otherwise initialise from the global model (ini)
    echo "Using initial condition from ${INPUTDIR}/${INIFILE}_${OGCM}_${TIME}.nc${ENDF}"
    ln -sf ${INPUTDIR}/${INIFILE}_${OGCM}_${TIME}.nc${ENDF} ${INIFILE}.nc${ENDF}
    RST=0
  fi
  LEVEL=$((LEVEL + 1))
done

# Create the atmosphere and ocean forcing symlinks
LEVEL=0
while [ $LEVEL != $NLEVEL ]; do
  if [[ ${LEVEL} == 0 ]]; then
    ENDF=
  else
    ENDF=.${LEVEL}
  fi
  if [[ ${FORCING_FILES} == 1 ]]; then
    ln -sf ${INPUTDIR}/${FRCFILE}_${ATMOS_FRC}_${TIME}.nc${ENDF} ${FRCFILE}.nc${ENDF}
  fi
  if [[ ${BULK_FILES} == 1 ]]; then
    ln -sf ${INPUTDIR}/${BLKFILE}_${ATMOS_BULK}_${TIME}.nc${ENDF} ${BLKFILE}.nc${ENDF}
  fi
  LEVEL=$((LEVEL + 1))
done

# The Algoa Bay Forecast model does use this type of boundary file
if [[ ${CLIMATOLOGY_FILES} == 1 ]]; then
  ln -sf ${INPUTDIR}/${CLMFILE}_${OGCM}_${TIME}.nc ${CLMFILE}.nc
fi

# The Algoa Bay forecast model does NOT use this type of boundary file
if [[ ${BOUNDARY_FILES} == 1 ]]; then
  ln -sf ${INPUTDIR}/${BRYFILE}_${OGCM}_${TIME}.nc ${BRYFILE}.nc
fi

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

# Configure the model run
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
  sed -e 's/DTNUM/'$DT'/' -e 's/NUMDTFAST/'$NUMDTFAST'/' -e 's/NUMTIMES/'$NUMTIMES'/' -e 's/NUMRST/'$NUMRST'/' -e 's/NUMHISSURF/'$NUMHISSURF'/' -e 's/NUMAVGSURF/'$NUMAVGSURF'/' -e 's/NUMHIS/'$NUMHIS'/' -e 's/NUMAVG/'$NUMAVG'/' -e 's/NUMSTA/'$NUMSTA'/' < croco_frcst.in${ENDF} > croco_${TIME}.in${ENDF}
  LEVEL=$((LEVEL + 1))
done

# Run the model
mpirun -np $MPI_NUM_PROCS ./croco croco_${TIME}.in > croco_${TIME}.out

# Check that the model ran correctly
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

