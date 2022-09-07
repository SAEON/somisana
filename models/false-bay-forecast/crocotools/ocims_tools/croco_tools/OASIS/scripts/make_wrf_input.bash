#!/bin/bash 
#*********************************************************************
#
#  Script to prepare WRF using the WRF Preprocessing System (WPS)
#  and run WRF simulations in forecast and hindcast mode
#
#*********************************************************************
# Usage : 
#  - multiple nested domains (3 max currently)
#  - possible use of SST data from a different source
# 
# Dependence : 
#  - read "configure.namelist" defining basic domain and 
#    run parameters
#  - Vtable : Vtable.AMIP or Vtable.GFS
#  - Vtable : Vtable.SSTCROCO     
# 
# Source grib file: 
#   - AMIPII (run cdf2grib.sh first)
#   - SST CROCO (run sst2grib.sh first)
#
# IRD NOUMEA  January 2007, P. MARCHESIELLO, J. LEFEVRE
# adapted from F. Lemarie. LMC-IMAG, Grenoble, France
#
# Last Update : J. LEFEVRE, updated to use WRFV3.2 
#               Fix new SST_update control rules
#               Add Spectral nudging entries
# 
# ADD Spectral nudging (jul 2010)
#*********************************************************************

#=====================================================================
#                       USER CHANGES                                 = 
#=====================================================================

CONFIGURE_NAMELIST=configure.namelist_benguela_lr_oa

#============= Define OPTIONS for running the script =================

# SWITCH to define the simulation domains, and interpolate static 
# terrestrial data sets to the model grids.
# (process $WPS_ROOT/geogrid.exe) ? (1 : yes / 0 : no)
switch_geogrid=0

# SWITCH to plot the domains with ferret
switch_plot=0

# SWITCH to degribs global model data, and write the data in a simple format
# called intermediate GRIB format.
# (process $WPS_ROOT/ungrib) ? (1 : yes / 0 : no)
switch_ungrib=0

# SWITCH to horizontally interpolates the intermediate-format meteorological 
# data that are extracted by the ungrib program onto the simulation domains 
# defined by the geogrid program. 
# (process $WPS_ROOT/metgrid) ? (1 : yes / 0 : no)
switch_metgrid=0

# SWITCH Creation of input, boundary and SST update files for WRF
# also performs the vertical interpolation
# (process "$RUN_ROOT/real.exe") ? (1 : yes / 0 : no)
switch_real=0

# SWITCH Run WRF
# (process $RUN_ROOT/wrf.exe) ? (1 : yes / 0 : no)
switch_wrf=1

# SWITCH SST update from other SOURCES? (1 : yes / 0 : no)
# Case 1: AMIP SKT file is deleted and we put SST CROCO
# in Land Surface Module (LSM_ROOT)
# Moreover, "grip_prep" is run twice
switch_SST=0

#==========  Initialize environment variables ========================
# Reset Bash Environment for Crontab
if [ -f /etc/bashrc ]; then
   . /etc/bashrc
fi
# Set Environment for WPS and WRF
export WPS_ROOT=$HOME/WRF/WPS3.6.1
export WRF_ROOT=$HOME/WRF/WRF3.6.1
export RUN_ROOT=$HOME/WRF/WRF3.6.1/run_benguela_lr_oa
export REAL_ROOT=$RUN_ROOT
export WRF_ROOM=$RUN_ROOT

source $WPS_ROOT/$CONFIGURE_NAMELIST
export MY_PATH=`pwd`
export I_DATAROOT=$WPS_ROOT/I_DATA/ncep_fnl_2008_09-10
echo "  "
echo "==============================="
echo "O_DATAROOT=> "$O_DATAROOT
echo "==============================="

export O_DATAROOT=$WPS_ROOT/O_DATA/$domain_name
echo "  "
echo "==============================="
echo "O_DATAROOT=> "$O_DATAROOT
echo "==============================="

export GEOG_DATAROOT=$WPS_ROOT/geog
echo "  "
echo "==============================="
echo "GEOG_DATAROOT=> "$GEOG_DATAROOT
echo "==============================="

export NETCDF=/usr/local
export NCDUMP=$NETCDF/bin/ncdump
export LBC_type='FNL'
export LBC_type_dir=$O_DATAROOT'/'$LBC_type

export LBC_type_Vtable='GFS'
export LSM_type='FNL'
export LBC_MOTIF='fnl'

#export myMPI=
export myMPI="mpirun -np 2"

mkdir $O_DATAROOT


#=========================================================================
#=======================  END USER CHANGES  ==============================
#=========================================================================

echo " "
echo "************************************************************"
echo "*                                                          *"
echo "*                This script will run the                  *"
echo "*              WRF Preprocessing System (WPS)              *"
echo "*               and WRF model simulations                  *"
echo "*        (P. Marchesiello, J. Lefevre, F. Lemarie)         *"
echo "*                                                          *"
echo "************************************************************"

                  #************************************
                  #                                   *
                  #           Program WPS             *
                  #                                   *
                  #************************************

cd $MY_PATH
#----------------------------------------------
# Rescale parameters from configure.namelist
#----------------------------------------------
export interval_s=`expr $obc_freq_h \* 3600`
export dx_d01=`expr $dx \* 1000`       # dx in meters
#export dt=`expr $dx \* 6`             # estimate dt=6*dx
export dt=180
export rst_interval_m=`expr $rst_interval_h \* 60` # refresh interval in minutes
nudge=0
## end running SST input
#export run_time_auxinput4_h=`expr $run_time_d \* 24 \+ $run_time_h`
## end running Nudging input
#export run_time_gfdda_end_h=`expr $run_time_d \* 24 \+ $run_time_h`
#echo "time long = $run_time_auxinput4_h"

#------------------------------------------
# Create output data directory if needed
#-------------------------------------------
  if ! [ -e $O_DATAROOT ] ; then
    mkdir $O_DATAROOT
  fi

#-------------------------------------------
# Remove old files
#-------------------------------------------
if [ $LBC_type = 'AMIP' ]; then
  rm -f $I_DATAROOT/gfs*
fi
if [ $switch_ungrib -eq 1 ]; then
  rm -f $O_DATAROOT/${LBC_type}:*
fi
if [ $switch_metgrid -eq 1 ]; then
  rm -f $O_DATAROOT/met_em*
fi
if [ $RUN_ROOT = $WRF_ROOT'/test/em_real' ]; then
  rm -f $RUN_ROOT/wrfrst*
  rm -f $RUN_ROOT/wrfout*
fi

#---------------------------------------------
# Check global data files
#--------------------------------------------- 
if [ $LBC_type = 'FNL' ]; then
  echo ' LBC_type='$LBC_type ;  echo ' I_DATAROOT='$I_DATAROOT
  list_AMIP=(`ls $I_DATAROOT/fnl*`)
  if [ $#{list_AMIP} != "0" ]; then
    echo " BASH:  FNL files are available"
  else
    echo " BASH:  FNL files are missing. Download them first."
    exit
  fi    
fi

if [ $LBC_type = 'GFDL' ]; then
  list_AMIP=(`ls $I_DATAROOT/GFDL.*.grb`)
  if [ $#{list_AMIP} != "0" ]; then
    echo " BASH:  GFDL files are available"
  else
    echo " BASH:  GFDL files are missing. Download them first."
    exit
  fi    
fi

if [ $LBC_type = 'AMIP' ]; then
  list_AMIP=(`ls $I_DATAROOT/$LBC_MOTIF*.grb`)
  if [ $#{list_AMIP} != "0" ]; then
   echo " BASH:  AMIP files are available"
  else
   echo " BASH:  AMIP files are missing. Download them first."
   exit
  fi
fi

if [ $switch_SST -eq 1 ]; then 
  list_SST=(`ls $I_DATAROOT/SSTCROCO.*.grb`)
  if [ $#{list_SST} != "0" ]; then
    echo " BASH: SST forcing files are available"
  else
    echo " BASH: SST forcing files are missing. Download them first."
    exit 
  fi
# suppress AMIP file containing SKINTEMP
 rm -f $I_DATAROOT/AMIP2.skt.sfc.gauss.*.grb      
fi

#--------------------------------------
# Check executables
#--------------------------------------
if [ -e $MY_PATH/geogrid.exe -a -e $MY_PATH/ungrib.exe -a -e $MY_PATH/metgrid.exe ] ; then
  echo " BASH: Executables checked in $WPS_ROOT"
else
  echo " BASH: Executables are missing $WPS_ROOT"
  exit 1
fi

# O  O  O  O  O  O  O  O  O        START geogrid      O  O  O  O  O  O  O  O  O

if [ $switch_geogrid -eq 1 ]; then
  echo " "
  echo " BASH:"
  echo " =========================================================="
  echo "                       GEOGRID                             "
  echo "                                                           "
  echo "   Localize computational domain, interpolate static data  "
  echo "   Check geogrid.log in current directory                  "
  echo " =========================================================="
  echo " "

  #------------------------------------------------
  # Create namelist.wps from configure.namelist 
  #------------------------------------------------
  if [ -e namelist.wps ] ; then
    rm -f namelist.wps
  fi

cat << End_Of_Namelist | sed -e 's/#.*//; s/  *$//' > ./namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = $max_domains,
 start_date = $start_date_d01,$start_date_d02,$start_date_d03,
 end_date   = $end_date_d01,$end_date_d02,$end_date_d03,
 interval_seconds = $interval_s,
 io_form_geogrid = 2,
 opt_output_from_geogrid_path = '$O_DATAROOT',
 debug_level = 0
/

&geogrid
 parent_id         =   1,   1,  2,
 parent_grid_ratio =   1, $refine_coef_d02, $refine_coef_d03,
 i_parent_start    =   1, $i_parent_str_d02, $i_parent_str_d03,
 j_parent_start    =   1, $j_parent_str_d02, $j_parent_str_d03,
 e_we              =   $xdim_d01, $xdim_d02, $xdim_d03,
 e_sn              =   $ydim_d01, $ydim_d02, $ydim_d03,
 geog_data_res     =   $topo_res_d01, $topo_res_d02, $topo_res_d03,
 dx = $dx_d01,
 dy = $dx_d01,
 map_proj = 'mercator',
 ref_lat   = $central_lat
 ref_lon   = $central_lon
 truelat1  = $central_lat,
 truelat2  = 0.0,
 stand_lon = $central_lon,
 geog_data_path = '$GEOG_DATAROOT'
 opt_geogrid_tbl_path ='./geogrid'
/
End_Of_Namelist


  ./geogrid.exe 
#$myMPI geogrid.exe

  echo "%  list geogrid output directory $O_DATAROOT :"
  ls $O_DATAROOT
fi

# O  O  O  O  O  O  O  O  O         END geogrid        O  O  O  O  O  O  O  O  O 

# O  O  O  O  O  O  O  O  O     VISUALIZE DOMAINS Embedding with Ferret    O  O  O  O  O  O  O
if [ $switch_plot -eq 1 ]; then
cd $O_DATAROOT

cat << EOF | sed -e 's/#.*//; s/  *$//' > ./Plot_Domains.jnl
! tmp.jnl  visualisation sortie de geogrid
CANCEL/ALL DATA
CANCEL/ALL VAR
CANCEL REGION

# LOOP1 BEGIN
`I=0
 while [ $I -lt $max_domains ]; do
  let I=I+1
 echo "use geo_em.d0$I.nc;"
 echo "DEFINE AXIS/Y/unit=degree_north LT$I=XLAT_M[d=$I,i=1,l=1];"
 echo "LET Xval$I = if XLONG_M[d=$I,j=1,l=1] lt 0 then XLONG_M[d=$I,j=1,l=1]+360 else XLONG_M[d=$I,j=1,l=1];"
 echo "DEFINE AXIS/X/unit=degree_east LL$I=Xval$I;"
 echo "LET H$I=RESHAPE(HGT_M[d=$I,l=1],x[gx=LL$I]+y[gy=LT$I]);"
 echo "DEFINE SYMBOL XR$I=@H$I,return=istart@;"
 echo "DEFINE SYMBOL XL$I=@H$I,return=iend@;"
 echo "DEFINE SYMBOL YU$I=@H$I,return=jstart@;"
 echo "DEFINE SYMBOL YA$I=@H$I,return=jend@;"
 echo "LET xD$I = {@x[gx=LL$I,i=(?XR$I)]@,@x[gx=LL$I,i=(?XR$I)]@,@x[gx=LL$I,i=(?XL$I)]@,@x[gx=LL$I,i=(?XL$I)]@,@x[gx=LL$I,i=(?XR$I)]@};"
 echo "LET yD$I = {@y[gy=LT$I,j=(?YU$I)]@,@y[gy=LT$I,j=(?YA$I)]@,@y[gy=LT$I,j=(?YA$I)]@,@y[gy=LT$I,j=(?YU$I)]@,@y[gy=LT$I,j=(?YU$I)]@};"
 done`
 SHADE/nolab/lev=(0,20,1),(20,100,5),(100,600,50),(600,2500,250) H1;
`I=1
 while [ $I -lt $max_domains ]; do
  let I=I+1
 echo "SHADE/nokey/nolab/over/lev=(0,20,1),(20,100,5),(100,600,50),(600,2500,250) H$I;"
 echo "PLOT/vs/over/nolab/nokey/line=1 xD$I,yD$I;"
 done`
go coastline;
frame/file=Nested_Domains.gif;

EOF

# Make some substitution in Ferret script  before execution :
 perl -pi -e "s/\@/\`/g;" Plot_Domains.jnl
 perl -pi -e "s/\?/\\$/g;" Plot_Domains.jnl
 ferret -gif -script Plot_Domains.jnl
 echo "Look my Domains : $O_DATAROOT/Nested_Domains.gif"

cd $MY_PATH							  
fi

# O  O  O  O  O  O  O  O  O         START ungrib       O  O  O  O  O  O  O  O  O

if [ $switch_ungrib -eq 1 ]; then
  echo " "
  echo " BASH:"
  echo " =========================================================="
  echo "                       UNGRIB                              "
  echo "                                                           "
  echo "   read Grib files, degrib the data                        "
  echo "   and write the data in intermediate format               "
  echo " =========================================================="
  echo " "

  #-------------------------
  # Create namelist.wps
  #-------------------------
  if [ -e namelist.wps ] ; then
    rm -f namelist.wps
  fi

cat << End_Of_Namelist | sed -e 's/#.*//; s/  *$//' > ./namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = $max_domains,
 start_date = $start_date_d01,$start_date_d02,$start_date_d03,
 end_date   = $end_date_d01,$end_date_d02,$end_date_d03,
 interval_seconds = $interval_s,
 io_form_geogrid = 2,
 opt_output_from_geogrid_path = '$O_DATAROOT',
 debug_level = 0
/

&ungrib
 out_format = 'WPS',
 prefix = '$LBC_type_dir',
/
End_Of_Namelist

  #-----------------------------------
  # check VTABLE for LBC and make link
  #-----------------------------------
  Vtable_ROOT=${WPS_ROOT}/ungrib/Variable_Tables
  if [ -e Vtable ] ; then
    rm -f Vtable
  fi 
  echo "   Vtable :  Link to $Vtable_ROOT/Vtable.${LBC_type_Vtable}"
  if [ ! -e $Vtable_ROOT/Vtable.${LBC_type_Vtable} ] ; then
    echo " "
    echo "   ERROR : no Vtable.${LBC_type_Vtable} found"
    echo " "
    exit 1
  fi

# MODIF JEROME POUR FORCER L'UTILISATION DE LA TABLE speciale "AMIP"
# QUAND GDAS PROVIENT DE la CHAINE CDF (NOMADS) to GRIB

if [ $switch_SST -eq 1 ]; then
 ln -s $Vtable_ROOT/Vtable.${LBC_type_Vtable} Vtable
else
# ln -s $Vtable_ROOT/Vtable.${LBC_type}_ORIGINAL Vtable
 ln -s $Vtable_ROOT/Vtable.${LBC_type_Vtable} Vtable
fi

  #-----------------------------------------------------
  # Create link to input grib files using link_grib.csh
  # after checking their existence
  #-----------------------------------------------------
  echo "                                                        "
  echo "   Create links to Input Grib data in: $I_DATAROOT "
  echo "   Data type is ${LBC_type}                             "

  if [ $LBC_type = 'FNL' ]; then
      echo "- FNL FNL FNL FNL -"
      echo "./link_grib.csh $I_DATAROOT/fnl*"
      ./link_grib.csh $I_DATAROOT/fnl*
      echo $I_DATAROOT
  elif [ $LBC_type = 'GFS' ]; then
     ./link_grib.csh $I_DATAROOT/gfs*.grb
  elif [ $LBC_type = 'GDAS' ]; then
     ./link_grib.csh $I_DATAROOT/gdas1*
  else 
    if [ $LBC_type = 'AMIP' ]; then
     ./link_grib.csh $I_DATAROOT/${LSM_TYPE}*.grb
    else
      echo "  ERROR: Data type should be gfs* or amip*  "
      exit 1
    fi
  fi

  #---------------------------------------------------
  #   Execute ungrib for initial and boundary data
  #---------------------------------------------------
  echo " "
  echo "   Run ungrib for initial and boundary data"
  echo " "

  ./ungrib.exe >& ungrib.log

  mv -f ${LBC_type}:* $O_DATAROOT
  rm -f GRIBFILE.*
  echo "   ls $O_DATAROOT"
  ls $O_DATAROOT


# O  O  O  O  O  O      START ungrib  for surface forcing     O  O  O  O  O  O  O

  if [ $switch_SST -eq 1 ]; then

    #-------------------------------------------------------------
    #   Repete procedure for secondary source of surface forcing
    #   (case switch_SST). first create a temporary namelist.wps
    #-------------------------------------------------------------

    if [ -e namelist.wps ] ; then
      rm -f namelist.wps
    fi

cat << End_Of_Namelist | sed -e 's/#.*//; s/  *$//' > ./namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = $max_domains,
 start_date = $start_date_d01,$start_date_d02,$start_date_d03,
 end_date   = $end_date_d01,$end_date_d02,$end_date_d03,
 interval_seconds = $interval_s,
 io_form_geogrid = 2,
 opt_output_from_geogrid_path = '$O_DATAROOT',
 debug_level = 0
/

&ungrib
 out_format = 'WPS',
 prefix = '$LSM_type',
/
End_Of_Namelist

    #--------------------------
    # Check VTABLE for LSM 
    #---------------------------

    if [ -e Vtable ] ; then
      rm -f Vtable
    fi  
    echo "Vtable :  Link to $Vtable_ROOT/Vtable.${LBC_type}"
    if [ ! -e $Vtable_ROOT/Vtable.${LBC_type} ] ; then
      echo " "
      echo "   ERROR : no Vtable.${LBC_type} found"
      echo " "
      exit 1
    fi
      ln -s $Vtable_ROOT/Vtable.${LBC_type} Vtable
   
    #----------------------------------------------------- 
    # Check that VTABLE.AMIP has no entry for SKINTEMP
    #-----------------------------------------------------
    str=`cat $Vtable_ROOT/Vtable.${LBC_type} | grep -i 'SST'`
    if [ ${#str} != "0" ]; then
      echo " "
      echo "   ERROR : Vtable.${LBC_type} has entry SKINTEMP "
      echo "   Possible conflict with forcing specified by $LBC_type "
      echo " "
#      exit 1
    fi

    #-------------------------------------------------------
    # Create new link to data and run ungrib a second time
    #-------------------------------------------------------
    echo "                                                        "
    echo "   Create links to Input Grib data in: $I_DATAROOT "
    echo "   Data type is ${LSM_type}                             "
    ./link_grib.csh $I_DATAROOT/${LSM_type}*.grb

    echo " "
    echo " Run ungrib a second time for surface forcing data " 
    ./ungrib.exe >& ungrib_${LSM_type}.log

    mv -f ${LBC_type}:* $O_DATAROOT
    rm -f GRIBFILE.*
    echo "   ls $O_DATAROOT"
    ls $O_DATAROOT

  fi
fi

# O  O  O  O  O  O  O  O  O         END ungrib          O  O  O  O  O  O  O  O  O 

# O  O  O  O  O  O  O  O  O        START metgrid        O  O  O  O  O  O  O  O  O

if [ $switch_metgrid -eq 1 ]; then
  echo " "
  echo " BASH:"
  echo " =========================================================="
  echo "                        METGRID                            "
  echo "                                                           "
  echo "  horizontally interpolate external data on WRF            "
  echo "  computational grid. Check metgrid.log in current         "
  echo "  directory for diagnostics                                "
  echo " =========================================================="
  echo " "

  if [ -e namelist.wps ] ; then
    rm -f namelist.wps
  fi

# Add path to LSM in "fg_name" if switch_SST is up
if [ $switch_SST -eq 1 ]; then
fg_name="fg_name                      = '$O_DATAROOT/${LBC_type}','$O_DATAROOT/${LSM_type}'"  
else
fg_name="fg_name                      = '$O_DATAROOT/${LBC_type}'"
fi	

cat << End_Of_Namelist | sed -e 's/#.*//; s/  *$//' > ./namelist.wps
&share
 wrf_core = 'ARW',
 max_dom = $max_domains,
 start_date = $start_date_d01,$start_date_d02,$start_date_d03,
 end_date   = $end_date_d01,$end_date_d02,$end_date_d03,
 interval_seconds = $interval_s,
 io_form_geogrid = 2,
 opt_output_from_geogrid_path = '$O_DATAROOT',
 debug_level = 0
/
&metgrid
 $fg_name
 io_form_metgrid              = 2,
 opt_output_from_metgrid_path = '$O_DATAROOT',
 opt_metgrid_tbl_path         = './metgrid',
/
End_Of_Namelist



  ./metgrid.exe
#$myMPI metgrid.exe

  echo "   ls -rtl $O_DATAROOT"
  ls -rtl $O_DATAROOT*

fi

# O  O  O  O  O  O  O  O  O         END metgrid          O  O  O  O  O  O  O  O  O 


                     #************************************
                     #                                   *
                     #         Program WRFV3             *
                     #                                   *
                     #************************************

               #************************************************
               # PREPARE AND RUN A SIMULATION ON 3 DOMAINS MAX *
               # WITH 2 WAY INTERACTIONS                       *
               #************************************************

# O  O  O  O  O  O  O  O  O        START real.exe        O  O  O  O  O  O  O  O  O

if [ $switch_real -eq 1 ]; then

  echo "         "
  echo "   BASH: "
  echo " =========================================================="
  echo "   REAL.EXE                                                "
  echo " =========================================================="
  echo "         "

  #************************
  # Check real.exe        *
  #************************
  echo "chdir $WRF_ROOT"
  cd $WRF_ROOT

  if [ -e main/real.exe ] ; then
    echo "   Executables are available "
    echo " "
    echo "cp main/real.exe $REAL_ROOT"

#LEFEVRE J 2010-jul : 
# trouble avec real 3.2 et AMIP cdf2grib     
# cp main/real.exe $REAL_ROOT
# cp /home/jlefevre/WRF/WRFV2.2/main/real.exe $REAL_ROOT

  else
    echo "   Executables real.exe is missing ... "
    exit 1
  fi
  
  echo "chdir $REAL_ROOT"
  cd $REAL_ROOT
  echo `pwd`
  #**********************************************************
  # Create initial and boundary conditions for each domain  *
  # LOOP backward over domain                               *
  #**********************************************************

  rm -f wrfinput* wrfbdy* wrflowinp* rsl.* met_em.*
  DN=$max_domains
  while [ $DN -gt 0 ]; do  
    for metfile in `ls $O_DATAROOT/met_em.d0${DN}*`
     do
      link_target=`basename $metfile`	     
      echo "Link $metfile to $link_target"	     
      ln -s $metfile $link_target
     done

    # GET WEST-EAST_and SOUTH-NORTH_GRID_DIMENSION and RESOLUTION from Netcdf file:"
    if [ $DN -eq 1 ]; then
      xdim=$xdim_d01
      ydim=$ydim_d01
      start_date_d0N=$start_date_d01
    else
      if [ $DN -eq 2 ]; then
        xdim=$xdim_d02
        ydim=$ydim_d02
        start_date_d0N=$start_date_d02
      else
        if [ $DN -eq 3 ]; then
          xdim=$xdim_d03
          ydim=$ydim_d03
          start_date_d0N=$start_date_d03
        fi
      fi
    fi
    dxn=`$NCDUMP -h met_em.d0${DN}.${start_date_d0N}.nc\
    | head -n 1000 | grep -i ':DX =' | gawk -F '= ' '{print $2}' | gawk -F 'f ;' '{print $1}'`
    #echo $xdim $ydim $dxn

    # Grid nudging : Only Domain 1
    nudge=0 # 1 : grid nudging ; 2 : spectral nudging
    echo 'NUDG FLAG='$nudge
    nudge_coef=0.0003
    if [ $DN -ne 1 ]; then
     nudge_coef=0
    fi     

    echo " "
    echo "   Create namelist.input for domain $DN"
    echo " "
    if [ -e namelist.input ] ; then
      rm -f namelist.input
    fi

cat << End_Of_Namelist | sed -e 's/#.*//; s/  *$//' > ./namelist.input
&time_control
 run_days                            = $run_time_d,
 run_hours                           = $run_time_h,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = $start_y,
 start_month                         = $start_m,
 start_day                           = $start_d,
 start_hour                          = $start_h,
 start_minute                        = 00,
 start_second                        = 00,
 end_year                            = $end_y, 
 end_month                           = $end_m, 
 end_day                             = $end_d, 
 end_hour                            = $end_h, 
 end_minute                          = 00,
 end_second                          = 00, 
 interval_seconds                    = $interval_s,
 input_from_file                     = .true.,
 history_interval_h                  = $his_interval_h, 
 frames_per_outfile                  = $his_frames, 
 restart                             = $restart,
 restart_interval                    = $rst_interval_m,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 io_form_auxinput4                   = 2
 debug_level                         = 100
 auxinput4_inname                    = "wrflowinp_d<domain>",
 auxinput4_interval                  = $auxinput4_interval,
 override_restart_timers             = .true.,
 /
 
 &domains
 time_step                           = $dt,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = 1,
 s_we                                = 1,     
 e_we                                = $xdim,  
 s_sn                                = 1,     
 e_sn                                = $ydim,   
 s_vert                              = 1,     
 e_vert                              = $nbvertlevel,
 num_metgrid_levels                  = $nbmetlevel,
 num_metgrid_soil_levels             = 4,
 p_top_requested                     = 25000.0,
 dx                                  = $dxn, 
 dy                                  = $dxn, 
 grid_id                             = 1,     
 parent_id                           = 0,     
 i_parent_start                      = 0,     
 j_parent_start                      = 0,     
 parent_grid_ratio                   = 1,     
 parent_time_step_ratio              = 1,    
 feedback                            = 1,
 smooth_option                       = 2
 /

 &physics
 mp_physics                          = 3,     
 ra_lw_physics                       = 1,    
 ra_sw_physics                       = 1,    
 radt                                = 30,   
 sf_sfclay_physics                   = 1,     
 sf_surface_physics                  = 2,     
 bl_pbl_physics                      = 1,     
 bldt                                = 0,     
 cu_physics                          = 2,    
 cudt                                = 0,   
 isfflx                              = 1,
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 sst_update                          = 1,
 tmn_update                          = 1,
 sst_skin                            = 1,
 num_soil_layers                     = 4,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 /

 &dynamics
 dyn_opt                             = 2,
 rk_ord                              = 3,
 w_damping                           = 0,
 diff_opt                            = 1,
 km_opt                              = 4,
 damp_opt                            = 0,
 zdamp                               = 5000.,  
 dampcoef                            = 0.2,    
 khdif                               = 0,      
 kvdif                               = 0,      
 smdiv                               = 0.1,    
 emdiv                               = 0.01,   
 epssm                               = 0.1,    
 non_hydrostatic                     = .true., 
 time_step_sound                     = 4,      
 h_mom_adv_order                     = 5,     
 v_mom_adv_order                     = 3,      
 h_sca_adv_order                     = 5,      
 v_sca_adv_order                     = 3,  
 moist_adv_opt                       = 1,
 gwd_opt                             = 1,

/

 &bdy_control
 spec_bdy_width                      = 10,
 spec_zone                           = 1,
 relax_zone                          = 9,
 spec_exp                            = 0.33,
 specified                           = .true.,
 periodic_x                          = .false.,
 symmetric_xs                        = .false.,
 symmetric_xe                        = .false.,
 open_xs                             = .false.,
 open_xe                             = .false.,
 periodic_y                          = .false.,
 symmetric_ys                        = .false.,
 symmetric_ye                        = .false.,
 open_ys                             = .false.,
 open_ye                             = .false.,
 nested                              = .false.,
 /

 &namelist_quilt
 nio_tasks_per_group = 0,
 nio_groups = 1,
 /

 &fdda
 grid_fdda                           = $nudge
 gfdda_inname                        = "wrffdda_d<domain>"
 gfdda_end_h                         = $run_time_gfdda_end_h
 gfdda_interval_m                    = 360
 io_form_gfdda                       = 2
 fgdt                                = 0 
 fgdtzero                            = 0 
 if_no_pbl_nudging_uv                = 1
 if_no_pbl_nudging_t                 = 1
 if_no_pbl_nudging_ph                = 1
 if_no_pbl_nudging_q                 = 1
 if_zfac_uv                          = 1
 k_zfac_uv                           = 9
 if_zfac_t                           = 1
 k_zfac_t                            = 9
 if_zfac_ph                          = 1
 k_zfac_ph                           = 9
 if_zfac_q                           = 1
 k_zfac_q                            = 9
 dk_zfac_uv                          = 1
 dk_zfac_t                           = 1
 dk_zfac_ph                          = 1
 guv                                 = $nudge_coef
 gt                                  = 0
 gph                                 = $nudge_coef
 gq                                  = 0
 xwavenum                            = 3
 ywavenum                            = 3
 if_ramping                          = 0
 dtramp_min                          = 60.0
 /

 &grib2
 /
End_Of_Namelist
    chmod +x namelist.input
    cp -p namelist.input namelist.input_real_d$DN

# Rename wrf_real_input files (d01) for real.exe 
    if [ $DN -ne 1 ] ; then 
###
#fix pour ubuntu
###
#      rename d0${DN} d01 met_em.d0${DN}*
      rename.ul d0${DN} d01 met_em.d0${DN}*
    fi
    # RUN real.exe
    echo "   Run real.exe for domain ${DN}"
    date
    ./real.exe
#    $myMPI real.exe
    date
    # Purge
    rm -f met_em.d01*
    # Rename wrfinput and wrflowinp files for each domain
    if [ $DN -ne 1 ] ; then  
      mv wrfinput_d01 wrfinput_d0${DN}
      mv wrflowinp_d01 wrflowinp_d0${DN}
      echo "NUDGE FLAG"$nudge
      if [ $nudge -ne 0 ]; then
       mv wrffdda_d01 wrffdda_d0${DN}
      fi
    fi
    let DN=DN-1 
  done

  ls -l wrfinput* wrfbdy* wrflowinp* 
#  mv wrfinput* wrfbdy* wrflowinp* $MY_PATH/
  if [ $nudge -ne 0 ]; then
   ls -l wrffdda*
#   mv wrffdda* $MY_PATH/
  fi
  rm -f met_em.*
  mv rsl.error.0000 rsl_real.error.0000

fi
  echo "SUCCESS"

# O  O  O  O  O  O  O  O  O        END real.exe        O  O  O  O  O  O  O  O  O



# O  O  O  O  O  O  O  O  O        START wrf.exe        O  O  O  O  O  O  O  O  O

if [ $switch_wrf -eq 1 ]; then

  echo "             "
  echo "   BASH:     "
  echo " =========================================================="
  echo "    WRF.EXE                                                "
  echo " =========================================================="
  echo "             "

  mv $REAL_ROOT/wrfinput* $REAL_ROOT/wrfbdy* $REAL_ROOT/wrflowinp* $RUN_ROOT
  echo '=== nudge='$nudge' ==='
  if [ $nudge -ne 0 ]; then
   mv $REAL_ROOT/wrffdda_d0* $RUN_ROOT
  fi
  
  cd $RUN_ROOT
  rm -f rsl.*

  #****************************************
  #  Create namelist.input file           *
  #  for simulation on 3 domains max      *
  #  with 2-way interaction               *
  #****************************************  
  if [ -e namelist.input ] ; then
    rm -f namelist.input
  fi

  # Initialization of some parameters
  xdim_d01='1'
  xdim_d02='1'
  xdim_d03='1'
  ydim_d01='1'
  ydim_d02='1'
  ydim_d03='1'
  dx_d01='1'
  dx_d02='1'
  dx_d03='1'

  # GET WEST-EAST_and SOUTH-NORTH_GRID_DIMENSION and RESOLUTION from Netcdf file
  DN=1
  while [ $DN -le $max_domains ]; do
    export xdim_d0${DN}=`$NCDUMP -h wrfinput_d0${DN}\
    | head -n 12 | grep -i 'west_east_stag =' | gawk -F '= ' '{print $2}' | gawk -F ' ;' '{print $1}'`
    export ydim_d0${DN}=`$NCDUMP -h wrfinput_d0${DN}\
    | head -n 12 | grep -i 'south_north_stag =' | gawk -F '= ' '{print $2}' | gawk -F ' ;' '{print $1}'`
    export dx_d0${DN}=`$NCDUMP -h wrfinput_d0${DN}\
    | head -n 1000 | grep -i ':DX =' | gawk -F '= ' '{print $2}' | gawk -F 'f ;' '{print $1}'`
    let DN=DN+1
  done

#read -p "Appuyer sur une touche pour continuer ..."

cat << End_Of_Namelist | sed -e 's/#.*//; s/  *$//' > ./namelist.input
&time_control
 run_days                            = $run_time_d,
 run_hours                           = $run_time_h,
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = `echo $start_y $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 start_month                         = `echo $start_m $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 start_day                           = `echo $start_d $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 start_hour                          = `echo 00 $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 start_minute                        = `echo 00  $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 start_second                        = `echo 00  $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 end_year                            = `echo $end_y $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 end_month                           = `echo $end_m $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 end_day                             = `echo $end_d $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 end_hour                            = `echo 00 $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 end_minute                          = `echo 00  $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 end_second                          = `echo 00  $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 interval_seconds                    = $interval_s
 input_from_file                     = `echo '.TRUE.' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 history_interval_h                  = `echo $his_interval_h $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 frames_per_outfile                  = `echo $his_frames $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 restart                             = $restart,
 restart_interval                    = $rst_interval_m,
 io_form_history                     = 2,
 io_form_restart                     = 2,
 io_form_input                       = 2,
 io_form_boundary                    = 2,
 debug_level                         = 0,
 auxinput4_inname                    = "wrflowinp_d<domain>"
 auxinput4_interval                  = $auxinput4_interval,$auxinput4_interval,
 override_restart_timers             = .true.,
 io_form_auxinput4                   = 2, 

 /

 &domains
 time_step                           = $dt,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = $max_domains,
 s_we                                = `echo '1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 e_we                                = $xdim_d01, $xdim_d02, $xdim_d03,
 s_sn                                = `echo '1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 e_sn                                = $ydim_d01,$ydim_d02, $ydim_d03,
 s_vert                              = `echo '1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 e_vert                              = `echo $nbvertlevel $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 num_metgrid_levels                  = $nbmetlevel 
 dx                                  = $dx_d01, $dx_d02, $dx_d03,
 dy                                  = $dx_d01, $dx_d02, $dx_d03,
 grid_id                             = 1,2,3,
 parent_id                           = 0,1,2,
 i_parent_start                      = 0,$i_parent_str_d02,$i_parent_str_d03
 j_parent_start                      = 0,$j_parent_str_d02,$j_parent_str_d03
 parent_grid_ratio                   = 1,$refine_coef_d02,$refine_coef_d03, 
 parent_time_step_ratio              = 1,$refine_coef_d02,$refine_coef_d03,
 feedback                            = 1,
 smooth_option                       = 2
 /

 &physics
 mp_physics                          = `echo '3' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`    
 ra_lw_physics                       = `echo '1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`     
 ra_sw_physics                       = `echo '1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`    
 radt                                = `echo '30' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'` 
 sf_sfclay_physics                   = `echo '1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`     
 sf_surface_physics                  = `echo '2' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`   
 bl_pbl_physics                      = `echo '1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`     
 bldt                                = `echo '0' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`     
 cu_physics                          = `echo '2' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`     
 cudt                                = `echo '0' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`     
 isfflx                              = 1,
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 sst_update                          = 1,
 tmn_update                          = 1,
 sst_skin                            = 1,
 num_soil_layers                     = 4,
 maxiens                             = 1,
 maxens                              = 3,
 maxens2                             = 3,
 maxens3                             = 16,
 ensdim                              = 144,
 /

 &dynamics
 dyn_opt                             = 2,
 rk_ord                              = 3,
 w_damping                           = 0,
 diff_opt                            = 0,
 km_opt                              = 4,
 damp_opt                            = 0,
 zdamp                               = `echo '5000.' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 dampcoef                            = `echo '0.2' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 khdif                               = `echo '0' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`     
 kvdif                               = `echo '0' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`    
 smdiv                               = `echo '0.1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'` 
 emdiv                               = `echo '0.01' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 epssm                               = `echo '0.1' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'` 
 non_hydrostatic                     = `echo '.true.' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'` 
 time_step_sound                     = `echo '4' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`
 h_mom_adv_order                     = `echo '5' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`  
 v_mom_adv_order                     = `echo '3' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`     
 h_sca_adv_order                     = `echo '5' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`  
 v_sca_adv_order                     = `echo '3' $max_domains\
 | awk '{for (i=1;i<=$2;i++) print $1","}' | tr -d '\n'`   
/

 &bdy_control
 spec_bdy_width                      = 10,
 spec_zone                           = 1,
 relax_zone                          = 9,
 spec_exp                            = 0.33,
 specified                           = .true., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 periodic_x                          = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 symmetric_xs                        = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 symmetric_xe                        = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 open_xs                             = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 open_xe                             = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 periodic_y                          = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 symmetric_ys                        = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 symmetric_ye                        = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 open_ys                             = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 open_ye                             = .false., `echo '.false.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 nested                              = .false., `echo '.true.' $max_domains\
 | awk '{for (i=1;i<$2;i++) print $1","}' | tr -d '\n'`   
 /

 &namelist_quilt
 nio_tasks_per_group                 = 0,
 nio_groups                          = 1,
 /

&fdda
 grid_fdda                           = $nudge,     0,     0,
 gfdda_inname                        = "wrffdda_d<domain>",
 gfdda_end_h                         = $run_time_gfdda_end_h, $run_time_gfdda_end_h, $run_time_gfdda_end_h,
 gfdda_interval_m                    = 360,   360,   360,
 fgdt                                = 0,     0,     0,
 fgdtzero                            = 0,     0,     0,
 if_no_pbl_nudging_uv                = 1,     1,     1,
 if_no_pbl_nudging_t                 = 1,     1,     1,
 if_no_pbl_nudging_ph                = 1,     1,     1,
 if_no_pbl_nudging_q                 = 1,     1,     1,
 if_zfac_uv                          = 1,     1,     1,
 k_zfac_uv                           = 9,     9,     9,
 if_zfac_t                           = 1,     1,     1,
 k_zfac_t                            = 9,     9,     9,
 if_zfac_ph                          = 1,     1,     1,
 k_zfac_ph                           = 9,     9,     9,
 if_zfac_q                           = 1,     1,     1,
 k_zfac_q                            = 9,     9,     9,
 dk_zfac_uv                          = 1,     1,     1,
 dk_zfac_t                           = 1,     1,     1,
 dk_zfac_ph                          = 1,     1,     1,
 guv                                 = $nudge_coef,     0,     0,
 gt                                  = 0,     0,     0,
 gph                                 = $nudge_coef,     0,     0,
 gq                                  = 0,     0,     0,
 xwavenum                            = 3,0,0
 ywavenum                            = 3,0,0
 if_ramping                          = 0,
 dtramp_min                          = 60.0,
 io_form_gfdda                       = 2,
 /

 &grib2
 /

End_Of_Namelist

# kwrite namelist.input &
  chmod +x namelist.input

  echo " "
  echo "   WRF RUNNING   "
  echo " "
# rajouter la copie des namelist.input
# cp namelist.input namelist.input_real_d$DN $O_DATAROOT/.

  time $myMPI ./wrf.exe

# echo "Please type :"
# echo "scp $RUN_ROOT/namelist.input $RUN_ROOT/wrfinput* $RUN_ROOT/wrfbdy* $RUN_ROOT/wrflowinp* $WRF_ROOM"
# echo "log to Editr and cd to $WRF_ROOM"
# #time mpirun -np 2 wrf.exe
# #time ./wrf.exe
# echo "ready to launch with pbs"
  echo " "
  echo "   DONE   "
  echo " "
  
fi

# O  O  O  O  O  O  O  O  O        END wrf.exe        O  O  O  O  O  O  O  O  O


