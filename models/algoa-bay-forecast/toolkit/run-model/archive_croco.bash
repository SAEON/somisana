#!/bin/bash
#

################################################
# define the input variables
################################################
PARENTDIR=$1
TIME=$2
TIME_prev=$3
ARCHIVE_START=$4
ARCHIVE_END=$5
NH_AVG=$6
NH_AVGSURF=$7

########################################################
# Archive the latest CROCO output
########################################################
#
# we move the latest run from 'scratch' to 'forecast' and move yesterdays 'forecast' to 'archive'

SCRATCHDIR=${PARENTDIR}croco/scratch
FORECASTDIR=${PARENTDIR}croco/forecast
ARCHIVEDIR=${PARENTDIR}croco/archive
#
# T_REF amd NLEVEL are only used if there is nesting (which we don't currently have for the Algoa Bay model)
# (these should be the same as in croco/run_croco.bash)
# Time refinement coefficient (factor to apply to time-step at each child level)
T_REF=1
# Number total of grid levels (1: No child grid)
NLEVEL=1
#
# check if we need to archive yesterdays forecast (using the existance of yesterday's restart file as a check)
if test -f "$FORECASTDIR/rst_${TIME_prev}.nc"; then
  RST=1
  mkdir ${ARCHIVEDIR}/${TIME_prev}
fi
#
# define time_step numbers to archive
#
AVG_START=$((ARCHIVE_START * 24 / NH_AVG)) # start day divided by days per timestep to get number of timesteps
AVGSURF_START=$((ARCHIVE_START * 24 / NH_AVGSURF))
AVG_END=$((ARCHIVE_END * 24 / NH_AVG - 1)) # minus 1 as ncks indices start at zero 
AVGSURF_END=$((ARCHIVE_END * 24 / NH_AVGSURF - 1))
#
# for debugging
#echo "AVG_START = ${AVG_START}"
#echo "AVGSURF_START = ${AVGSURF_START}"
#echo "AVG_END = ${AVG_END}"
#echo "AVGSURF_END = ${AVGSURF_END}"

LEVEL=0
while [[ $LEVEL != $NLEVEL ]]; do
  if [[ ${LEVEL} == 0 ]]; then
    ENDF=
  else
    ENDF=.${LEVEL}
    AVG_START=$((T_REF * AVG_START))
    AVGSURF_START=$((T_REF * AVGSURF_START))
    AVG_END=$((T_REF * AVG_END))
    AVGSURF_END=$((T_REF * AVGSURF_END))
  fi
      rm -f ${SCRATCHDIR}/his.nc${ENDF} # we're not using the his files, only the avg files
      rm -f ${SCRATCHDIR}/his_surf.nc${ENDF} # we're not using the his files, only the avg files
      mv -f ${SCRATCHDIR}/avg.nc${ENDF} ${FORECASTDIR}/avg_${TIME}.nc${ENDF}
      mv -f ${SCRATCHDIR}/avg_surf.nc${ENDF} ${FORECASTDIR}/avg_surf_${TIME}.nc${ENDF}
      mv -f ${SCRATCHDIR}/rst.nc${ENDF} ${FORECASTDIR}/rst_${TIME}.nc${ENDF}
      #
      # archive yesterday's run if it exists
      #
      if [[ ${RST} == 1 ]]; then

        ncks -v temp,salt,u,v,w,zeta,sustr,svstr -d time,${AVG_START},${AVG_END} -O ${FORECASTDIR}/avg_${TIME_prev}.nc${ENDF} ${ARCHIVEDIR}/${TIME_prev}/avg_${TIME_prev}.nc${ENDF}
        ncks -v surf_t,surf_s,surf_u,surf_v,surf_z -d time,${AVGSURF_START},${AVGSURF_END} -O ${FORECASTDIR}/avg_surf_${TIME_prev}.nc${ENDF} ${ARCHIVEDIR}/${TIME_prev}/avg_surf_${TIME_prev}.nc${ENDF}
        # only archive the first time-step of the restart file... keep it in case we want to start up a run from an archived date
        ncks -d time,0 -O ${FORECASTDIR}/rst_${TIME_prev}.nc${ENDF} ${ARCHIVEDIR}/${TIME_prev}/rst_${TIME_prev}.nc${ENDF}
        
        # delete yesterday's files now that we've archived the data we need
        rm -f ${FORECASTDIR}/rst_${TIME_prev}.nc${ENDF}
        rm -f ${FORECASTDIR}/avg_${TIME_prev}.nc${ENDF}
        rm -f ${FORECASTDIR}/avg_surf_${TIME_prev}.nc${ENDF} 
      fi
  LEVEL=$((LEVEL + 1))
done
# keep the input and output files for our records
mv -f ${SCRATCHDIR}/croco_${TIME}.in ${FORECASTDIR} 
mv -f ${SCRATCHDIR}/croco_${TIME}.out ${FORECASTDIR} 
if [[ ${RST} == 1 ]]; then
  mv -f ${FORECASTDIR}/croco_${TIME_prev}.in ${ARCHIVEDIR}/${TIME_prev} 
  mv -f ${FORECASTDIR}/croco_${TIME_prev}.out ${ARCHIVEDIR}/${TIME_prev} 
fi
#
#############################################################







