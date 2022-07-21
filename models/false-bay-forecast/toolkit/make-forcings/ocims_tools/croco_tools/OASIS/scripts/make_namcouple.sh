#!/bin/bash
#======================================================================
#
#        OASIS namcouple generator for CROCO-WRF coupling
#
#======================================================================
#
export CROCO_FILES_DIR=$HOME/OASIS/Run_benguela_lr_oa/croco_files
export WRF_FILES_DIR=$HOME/OASIS/Run_benguela_lr_oa/wrf_files
export OASIS_FILES_DIR='./'

myconfig='TOY'

max_domains_WRF=1
max_domains_CROCO=1
#
#======================== END USER CHANGES ============================

echo ' === Make Parent sequences ==='

#
# JOBNAME
#
#MYJOBNAME=$myconfig
export MYJOBNAME=`ncdump -h $OASIS_FILES_DIR/grids.nc\
  | head -n 1000 | grep -i ':title =' | awk -F '"' '{print $2}' | awk -F '"' '{print $1}'`
echo 'Job name:' $MYJOBNAME

#
# START DATE
#
export YEAR=`ncdump -h $WRF_FILES_DIR/wrfinput_d01\
  | head -n 1000 | grep -i ':START_DATE =' | awk -F '"' '{print $2}' | awk -F '-' '{print $1}'`
export MONTH=`ncdump -h $WRF_FILES_DIR/wrfinput_d01\
  | head -n 1000 | grep -i ':START_DATE =' | awk -F '-' '{print $2}' | awk -F '-' '{print $1}'`
export DAY=`ncdump -h $WRF_FILES_DIR/wrfinput_d01\
  | head -n 1000 | grep -i ':START_DATE =' | awk -F '-' '{print $3}' | awk -F '_' '{print $1}'`
MYINIDATE=${YEAR}${MONTH}${DAY}
echo 'Initial date:' $MYINIDATE

#
# RUN TIME
#
export ndt=`awk 'NR==4 {print $1}' $CROCO_FILES_DIR/croco.in`
export dt=`awk 'NR==4 {print $2}' $CROCO_FILES_DIR/croco.in`
MYRUNTIME=`expr $ndt \* $dt`
echo 'Run time:' $MYRUNTIME

#
# Get CROCO data =========
#
dto_d01='1'
dto_d02='1'
dto_d03='1'
xodim_d01='1'
xodim_d02='1'
xodim_d03='1'
yodim_d01='1'
yodim_d02='1'
yodim_d03='1'
DN=1
while [ $DN -le $max_domains_CROCO ]; do
  if [ $DN = 1 ]; then
    SN=''
  else
    SN=`expr $DN \- 1`; SN=.$SN
  fi
  export dto_d0${DN}=`awk 'NR==4 {print $2}' $CROCO_FILES_DIR/croco.in${SN}`
  export xodim_d0${DN}=`ncdump -h $CROCO_FILES_DIR/croco_grd.nc${SN}\
    | head -n 12 | grep -i 'xi_psi =' | awk -F '= ' '{print $2}' | awk -F ' ;' '{print $1}'`
  export yodim_d0${DN}=`ncdump -h $CROCO_FILES_DIR/croco_grd.nc${SN}\
    | head -n 12 | grep -i 'eta_psi =' | awk -F '= ' '{print $2}' | awk -F ' ;' '{print $1}'`
  let DN=DN+1
done
dto=$dto_d01
LCROCO=`expr $xodim_d01 \- 1`
MCROCO=`expr $yodim_d01 \- 1`

echo 'CROCO X dim    :' $LCROCO
echo 'CROCO Y dim    :' $MCROCO
echo 'CROCO time-step:' $dto

#
# Get WRF data =========
#
dta_d01='1'
dta_d02='1'
dta_d03='1'
xadim_d01='1'
xadim_d02='1'
xadim_d03='1'
yadim_d01='1'
yadim_d02='1'
yadim_d03='1'
DN=1
while [ $DN -le $max_domains_WRF ]; do
  export dta_d0${DN}=`ncdump -h $WRF_FILES_DIR/wrfinput_d01\
    | head -n 1000 | grep -i ':DT =' | awk -F '= ' '{print $2}' | awk -F '.f ;' '{print $1}'`
  export xadim_d0${DN}=`ncdump -h $WRF_FILES_DIR/wrfinput_d0${DN}\
    | head -n 12 | grep -i 'west_east_stag =' | awk -F '= ' '{print $2}' | awk -F ' ;' '{print $1}'`
  export yadim_d0${DN}=`ncdump -h $WRF_FILES_DIR/wrfinput_d0${DN}\
    | head -n 12 | grep -i 'south_north_stag =' | awk -F '= ' '{print $2}' | awk -F ' ;' '{print $1}'`
  let DN=DN+1
done
dta=$dta_d01
LWRF=$xadim_d01
MWRF=$yadim_d01

echo 'WRF X dim     :' $LWRF
echo 'WRF Y dim     :' $MWRF
echo 'WRF time-step :' $dta

#
# Compute coupling parameters =========
#
CPL_FREQ=$dto
MYLAG=`echo $dta $dto | awk '{print $1 - $2}'`
echo 'Coupling Lag  :' $MYLAG
echo 'Coupling Freq :' $CPL_FREQ

max_domains=$(($max_domains_WRF>$max_domains_CROCO?$max_domains_WRF:$max_domains_CROCO))
MYNFIELDS=6
DN=2
while [ $DN -le $max_domains ]; do
  DNW=$(($max_domains_WRF<$DN?$max_domains_WRF:$DN))
  DNR=$(($max_domains_CROCO<$DN?$max_domains_CROCO:$DN))
  if [ $DNW = $DNR ]; then
  MYNFIELDS=`expr $MYNFIELDS \+ 6`
  else
    if [ $DNW < $DNR ]; then
     MYNFIELDS=`expr $MYNFIELDS \+ 5`
    else
      if [ $DNW > $DNR ]; then
        MYNFIELDS=`expr $MYNFIELDS \+ 1`
      fi
    fi
  fi
  let DN=DN+1
done
echo 'Number of coupling sequences:' $MYNFIELDS
#
#==============================================================================
#   				MAKE NAMCOUPLE
#
#                       First make parent coupling part
#==============================================================================
#
cat << End_Of_Namelist > ./namcouple_TMP_11
###############################################################################
#
#                          Input file for OASIS3
#
###############################################################################
# 
#      Input delimiters have to occupy position 1 to 9 !
#      No blank lines allowed !
#      Length of input lines <= 80 !
#
###############################################################################
#
# SEQMODE : 1        if all models run simultaneously
#           n        if  n  models run sequentially
 \$SEQMODE
#
###############################################################################
#
# CHANNEL (CHAR*4)
#           PIPE        if named pipes + binary files are used
#                       for synchro and data respectively (not tested);
#           MPI1/2      if MPI message passing is used for data exchange;
#
 \$CHANNEL      
 \$END
###############################################################################
#
# NFIELDS : total number of fields being exchanged.
#
 \$NFIELDS
 $MYNFIELDS
 \$END
###############################################################################
#
# JOBNAME : acronym for the given simulation (CHAR*3)
#
 \$JOBNAME
 $MYJOBNAME
 \$END
###############################################################################
#
# NBMODEL : number of models and their names (CHAR*6).
#
 \$NBMODEL
 2 wrfexe croco3d
 \$END
###############################################################################
#
# RUNTIME: total simulated time for the actual run in seconds (<I8)
#
 \$RUNTIME
 $MYRUNTIME
 \$END
###############################################################################
#
# INIDATE (I8)
#         initial date of the run (YYYYMMDD)         
#
 \$INIDATE
 $MYINIDATE
 \$END
###############################################################################
#
# MODINFO (YES or NOT)
#         Indicates whether a header is encapsulated within the field
#
 \$MODINFO
  NOT
 \$END
###############################################################################
#
# NLOGPRT: printing level in output file cplout:
#              0 = no printing
#              1 = main routines and field names when treated
#              2 = complete output
#
 \$NLOGPRT
  2  
 \$END
###############################################################################
#
# CALTYPE: Calendar type
#                  0      = 365 day calendar (no leap years)
#                  1      = 365 day, or 366 days for leap years, calendar
#                  n (>1) = n day month calendar
#
 \$CALTYPE
         1
 \$END
#
#
###############################################################################
 \$STRINGS
###############################################################################
###############################################################################
#                   (Parent CROCO  - Parent WRF)
#                      OCEAN  --->>>  ATMOS
#                      --------------------
###############################################################################
###############################################################################
# Field 1 : Weighted sea surface temperature (o->a 1)
#
SRMSSTV0 WRF_d01_EXT_d01_SST 1 $CPL_FREQ 1  sstoc.nc  EXPOUT
$LCROCO $MCROCO $LWRF $MWRF rrn0 wrp0 LAG=0
R 0 R 0
SCRIPR  
BILINEAR LR SCALAR LATLON 1
# 
###############################################################################
###############################################################################
#                     (Parent WRF  - Parent CROCO)
#                      ATMOSPHERE  --->>>  OCEAN  
#                      -------------------------
###############################################################################
###############################################################################
#
# Field 1 : solar heat flux on ocean (a->o flx 2)
#
WRF_d01_EXT_d01_SURF_NET_SOLAR RRMSRFL0 7 $CPL_FREQ 2  flxat.nc EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp0 rrp0  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
# Field 2 : emp = emp_oce = evap_oce - ( rain_oce + snow_oce ) (a->o flx 9)
#
WRF_d01_EXT_d01_EVAP-PRECIP RRMEVPR0 29 $CPL_FREQ  2  flxat.nc   EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp0 rrp0  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
# Field 3 : Non solar heat flux on ocean (a->o flx 4)
#
WRF_d01_EXT_d01_SURF_NET_NON-SOLAR RRMSTFL0 6 $CPL_FREQ  2  flxat.nc  EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp0 rrp0  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
#
# Field 4 : stress along X axis (a->o tau 1)
#
WRF_d01_EXT_d01_TAUX RRMTAUX0 23 $CPL_FREQ  2  flxat.nc  EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp0 rrp0  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
###############################################################################
#
# Field 5 : stress along Y axis (a->o tau 1)
#
WRF_d01_EXT_d01_TAUY RRMTAUY0 24 $CPL_FREQ  2  flxat.nc  EXPOUT  
$LWRF $MWRF $LCROCO $MCROCO wrp0 rrp0  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
###############################################################################
#
End_Of_Namelist
#
#==============================================================================
#
#                   Second make children coupling part
#
#==============================================================================
#
echo ' === Make Children sequences ==='

DN=2
while [ $DN -le $max_domains ]; do


  DNW=$(($max_domains_WRF<$DN?$max_domains_WRF:$DN))
  DNR=$(($max_domains_CROCO<$DN?$max_domains_CROCO:$DN))
  DNWm=`expr $DNW \- 1`
  DNRm=`expr $DNR \- 1`

  echo 'CROCO domain: '$DNR '     WRF domain: '$DNW

  xodim="xodim_d0${DNR}"
  yodim="yodim_d0${DNR}"
  xadim="xadim_d0${DNW}"
  yadim="yadim_d0${DNW}"
  dto="dto_d0${DNR}"
  dta="dta_d0${DNW}"
  LCROCO=${!xodim}
  MCROCO=${!yodim}
  LWRF=${!xadim}
  MWRF=${!yadim}
  DTO=${!dto}
  DTA=${!dta}
  CPL_FREQ=$DTO
  MYLAG=`echo $DTO $DTA | awk '{print $1 - $2}'`
  echo 'CROCO X dim    :' $LCROCO
  echo 'CROCO Y dim    :' $MCROCO
  echo 'CROCO time-step:' $DTO
  echo 'WRF  X dim    :' $LWRF
  echo 'WRF  Y dim    :' $MWRF
  echo 'WRF  time-step:' $DTA
  echo 'Coupling Lag  :' $MYLAG
  echo 'Coupling Freq :' $CPL_FREQ

  if [ $DNW = $DNR ]; then

cat << End_Of_Namelist > ./namcouple_TMP_${DN}${DN}
###############################################################################
###############################################################################
#               (Child $DNR CROCO  - Child $DNW WRF)
#                      OCEAN  --->>>  ATMOS
#                      --------------------
###############################################################################
###############################################################################
# Field 1 : Weighted sea surface temperature (o->a 1)
#
SRMSSTV${DNRm} WRF_d0${DNW}_EXT_d0${DNW}_SST 1 $CPL_FREQ 1  sstoc.nc  EXPOUT
$LCROCO $MCROCO $LWRF $MWRF rrn${DNRm} wrp${DNWm} LAG=0
R 0 R 0
SCRIPR  
BILINEAR LR SCALAR LATLON 1
# 
###############################################################################
###############################################################################
#                  (Child $DNW WRF  - Child $DNR CROCO)
#                      ATMOSPHERE  --->>>  OCEAN  
#                      -------------------------
###############################################################################
###############################################################################
#
# Field 1 : solar heat flux on ocean (a->o flx 2)
#
WRF_d0${DNW}_EXT_d0${DNW}_SURF_NET_SOLAR RRMSRFL${DNRm} 7 $CPL_FREQ 2  flxat.nc EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
# Field 2 : emp = emp_oce = evap_oce - ( rain_oce + snow_oce ) (a->o flx 9)
#
WRF_d0${DNW}_EXT_d0${DNW}_EVAP-PRECIP RRMEVPR${DNRm} 29 $CPL_FREQ  2  flxat.nc   EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
# Field 3 : Non solar heat flux on ocean (a->o flx 4)
#
WRF_d0${DNW}_EXT_d0${DNW}_SURF_NET_NON-SOLAR RRMSTFL${DNRm} 6 $CPL_FREQ  2  flxat.nc  EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
#
# Field 4 : stress along X axis (a->o tau 1)
#
WRF_d0${DNW}_EXT_d0${DNW}_TAUX RRMTAUX${DNRm} 23 $CPL_FREQ  2  flxat.nc  EXPOUT
LWRF MWRF LCROCO MCROCO wrp0 rrp0  LAG=MYLAG
$LWRF $MWRF $LCROCO $MCROCO  wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
#
# Field 5 : stress along Y axis (a->o tau 1)
#
WRF_d0${DNW}_EXT_d0${DNW}_TAUY RRMTAUY${DNRm} 24 $CPL_FREQ  2  flxat.nc  EXPOUT  
$LWRF $MWRF $LCROCO $MCROCO  wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
###############################################################################
#
End_Of_Namelist

  else
    if [ $DNW < $DNR ]; then

cat << End_Of_Namelist > ./namcouple_TMP_${DNW}${DNR}
###############################################################################
###############################################################################
#                  (Child $DNW WRF  - Child $DNR CROCO)
#                      ATMOSPHERE  --->>>  OCEAN  
#                      -------------------------
############################################################################### 
############################################################################### 
#
# Field 1 : solar heat flux on ocean (a->o flx 2)
#
WRF_d0${DNW}_EXT_d0${DNW}_SURF_NET_SOLAR RRMSRFL${DNRm} 7 $CPL_FREQ 2  flxat.nc EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
# Field 2 : emp = emp_oce = evap_oce - ( rain_oce + snow_oce ) (a->o flx 9)
#
WRF_d0${DNW}_EXT_d0${DNW}_EVAP-PRECIP RRMEVPR${DNRm} 29 $CPL_FREQ  2  flxat.nc   EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
# Field 3 : Non solar heat flux on ocean (a->o flx 4)
#
WRF_d0${DNW}_EXT_d0${DNW}_SURF_NET_NON-SOLAR RRMSTFL${DNRm} 6 $CPL_FREQ  2  flxat.nc  EXPOUT
$LWRF $MWRF $LCROCO $MCROCO wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
#
# Field 4 : stress along X axis (a->o tau 1)
#
WRF_d0${DNW}_EXT_d0${DNW}_TAUX RRMTAUX${DNRm} 23 $CPL_FREQ  2  flxat.nc  EXPOUT
LWRF MWRF LCROCO MCROCO wrp0 rrp0  LAG=MYLAG
$LWRF $MWRF $LCROCO $MCROCO  wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
#
# Field 5 : stress along Y axis (a->o tau 1)
#
WRF_d0${DNW}_EXT_d0${DNW}_TAUY RRMTAUY${DNRm} 24 $CPL_FREQ  2  flxat.nc  EXPOUT  
$LWRF $MWRF $LCROCO $MCROCO  wrp${DNWm} rrp${DNRm}  LAG=$MYLAG
R 0 R 0
LOCTRANS SCRIPR
AVERAGE
BILINEAR LR SCALAR LATLON 1
#
###############################################################################
#
End_Of_Namelist

    else
      if [ $DNW > $DNR ]; then

cat << End_Of_Namelist > ./namcouple_TMP_${DNW}${DNR}
###############################################################################
###############################################################################
#               (Child $DNR CROCO  - Child $DNW)
#                      OCEAN  --->>>  ATMOS
#                      --------------------
###############################################################################
###############################################################################
# Field 1 : Weighted sea surface temperature (o->a 1)
#
SRMSSTV${DNRm} WRF_d0${DNW}_EXT_d0${DNW}_SST 1 $CPL_FREQ 1  sstoc.nc  EXPOUT
$LCROCO $MCROCO $LWRF $MWRF rrn${DNRm} wrp${DNWm} LAG=0
R 0 R 0
SCRIPR  
BILINEAR LR SCALAR LATLON 1
# 
End_Of_Namelist

      fi
    fi    
  fi
  let DN=DN+1
done

#
# Concatenate namcouple file and write END line
#
cat namcouple_TMP* > namcouple
rm namcouple_TMP*
echo '$END' >> namcouple



