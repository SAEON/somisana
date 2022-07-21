create_wrf_areas_function()
#--------------------
# Processing WRF Areas
#--------------------
{
if [ -z "$1" ]
then
   echo "Processing WRF Parent Areas"
   ngrid='0'
   gext=''
   if [ -f grids_wrf.nc${gext} ]; then
       echo '  -->' grids_wrf.nc${gext} exists 
   else
       create_wrf_grids_function $1
   fi
   if [ -f corners_wrf.nc${gext} ]; then
       echo '  -->' corners_wrf.nc${gext} exists 
   else
       create_wrf_corners_function $1
   fi
else 
   if [ $1 == "0" ]
   then
       echo "Processing WRF Parent Areas"
       ngrid='0'
       gext=''
       if [ -f grids_wrf.nc${gext} ]; then
	   echo '  -->' grids_wrf.nc${gext} exists 
       else
	   create_wrf_grids_function $1
       fi
       if [ -f corners_wrf.nc${gext} ]; then
	   echo '  -->' corners_wrf.nc${gext} exists 
       else
	   create_wrf_corners_function $1
       fi
   else
       echo "Processing WRF child N=$1 Areas"
       ngrid=$1 
       gext=.$1
       if [ -f ${wrf_grid_file}${gext} ]; then
	   echo '  -->' grids_wrf.nc${gext} exists 
       else
	   create_wrf_grids_function $1
       fi
       if [ -f corners_wrf.nc${gext} ]; then
	   echo '  -->' corners_wrf.nc${gext} exists 
       else
	   create_wrf_corners_function $1
       fi
   fi
fi

WRN=$(echo ${WRN0} | cut -c1-3)$ngrid
WRP=$(echo ${WRP0} | cut -c1-3)$ngrid

cp grids_wrf.nc${gext} areas_wrf.nc${gext}
ncks -A corners_wrf.nc${gext} areas_wrf.nc${gext}

ncap2 -O -s 'pi=3.14159' areas_wrf.nc${gext} areas_wrf.nc${gext}
ncap2 -O -s 'radian=180.0/pi' areas_wrf.nc${gext} areas_wrf.nc${gext}
ncap2 -O -s 'earth_radius=6370000.0' areas_wrf.nc${gext} areas_wrf.nc${gext}

ncrename -h -v ${WRN}.clo,${WRN}_clo -v ${WRN}.cla,${WRN}_cla -v ${WRN}.lat,${WRN}_lat areas_wrf.nc${gext}
toto_xbox="${WRN}"'_xbox=earth_radius*earth_radius*('"${WRN}"'_clo(0,:,:)'-"${WRN}"'_clo(1,:,:))/radian'
toto_ybox="${WRN}"'_ybox=2*sin(('"${WRN}"'_cla(0,:,:)'-"${WRN}"'_cla(2,:,:))/radian)'
toto_srf="${WRN}"_srf="${WRN}"'_xbox*'"${WRN}"'_ybox*cos('"${WRN}"'_lat/radian)'
ncap2 -O -s $toto_xbox -s $toto_ybox -s $toto_srf areas_wrf.nc${gext} areas_wrf.nc${gext} 
ncatted -h -a units,${WRN}_srf,c,c,"m^2" areas_wrf.nc${gext}
toto="${WRP}"_srf="${WRN}"_srf
ncap2 -O -s $toto areas_wrf.nc${gext} areas_wrf.nc${gext}
toto="Areas of ${WRN} grid"; ncatted -h -a long_name,"${WRN}_srf",c,c,"${toto}" areas_wrf.nc${gext}
toto="Areas of ${WRP} grid"; ncatted -h -a long_name,"${WRP}_srf",c,c,"${toto}" areas_wrf.nc${gext}


ncks -O -h -v ${WRN}_srf,${WRP}_srf areas_wrf.nc${gext} areas_wrf.nc${gext}
ncrename -O -v ${WRN}_srf,${WRN}.srf -v ${WRP}_srf,${WRP}.srf areas_wrf.nc${gext}
ncatted -h -O -a ,global,d,, areas_wrf.nc${gext}
}