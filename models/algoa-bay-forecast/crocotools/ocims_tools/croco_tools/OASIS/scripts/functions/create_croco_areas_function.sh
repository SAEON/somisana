create_croco_areas_function()
#--------------------
# Processing CROCO Areas
#--------------------
{
if [ -z "$1" ]
then
   echo "Processing CROCO Parent Areas"
   ngrid='0'
   gext=''
   if [ -f grids_croco.nc${gext} ]; then
       echo '  -->' grids_croco.nc${gext} exists 
   else
       create_croco_grids_function $1
   fi
   if [ -f corners_croco.nc${gext} ]; then
       echo '  -->' corners_croco.nc${gext} exists 
   else
       create_croco_corners_function $1
   fi
else 
   if [ $1 == "0" ]
   then
       echo "Processing CROCO Parent Areas"
       ngrid='0'
       gext=''
       if [ -f grids_croco.nc${gext} ]; then
	   echo '  -->' grids_croco.nc${gext} exists 
       else
	   create_croco_grids_function $1
       fi
       if [ -f corners_croco.nc${gext} ]; then
	   echo '  -->' corners_croco.nc${gext} exists 
       else
	   create_croco_corners_function $1
       fi
   else
       echo "Processing CROCO child N=$1 Areas"
       ngrid=$1 
       gext=.$1
       if [ -f ${croco_grid_file}${gext} ]; then
	   echo '  -->' grids_croco.nc${gext} exists 
       else
	   create_croco_grids_function $1
       fi
       if [ -f corners_croco.nc${gext} ]; then
	   echo '  -->' corners_croco.nc${gext} exists 
       else
	   create_croco_corners_function $1
       fi
   fi
fi

RRN=$(echo ${RRN0} | cut -c1-3)$ngrid
RRP=$(echo ${RRP0} | cut -c1-3)$ngrid
RUN=$(echo ${RUN0} | cut -c1-3)$ngrid
RUP=$(echo ${RUP0} | cut -c1-3)$ngrid
RVN=$(echo ${RVN0} | cut -c1-3)$ngrid
RVP=$(echo ${RVP0} | cut -c1-3)$ngrid

cp grids_croco.nc${gext} areas_croco.nc${gext}
ncks -A corners_croco.nc${gext} areas_croco.nc${gext}

ncap2 -O -s 'pi=3.14159' areas_croco.nc${gext} areas_croco.nc${gext}
ncap2 -O -s 'radian=180.0/pi' areas_croco.nc${gext} areas_croco.nc${gext}
ncap2 -O -s 'earth_radius=6370000.0' areas_croco.nc${gext} areas_croco.nc${gext}

ncrename -h -v ${RRN}.clo,${RRN}_clo -v ${RRN}.cla,${RRN}_cla -v ${RRN}.lat,${RRN}_lat areas_croco.nc${gext}
toto_xbox="${RRN}"'_xbox=earth_radius*earth_radius*('"${RRN}"'_clo(0,:,:)'-"${RRN}"'_clo(1,:,:))/radian'
toto_ybox="${RRN}"'_ybox=2*sin(('"${RRN}"'_cla(0,:,:)'-"${RRN}"'_cla(2,:,:))/radian)'
toto_srf="${RRN}"_srf="${RRN}"'_xbox*'"${RRN}"'_ybox*cos('"${RRN}"'_lat/radian)'
ncap2 -O -s $toto_xbox -s $toto_ybox -s $toto_srf areas_croco.nc${gext} areas_croco.nc${gext} 
ncatted -h -a units,${RRN}_srf,c,c,"m^2" areas_croco.nc${gext}
toto="${RRP}"_srf="${RRN}"_srf
ncap2 -O -s $toto areas_croco.nc${gext} areas_croco.nc${gext}
toto="Areas of ${RRN} grid"; ncatted -h -a long_name,"${RRN}_srf",c,c,"${toto}" areas_croco.nc${gext}
toto="Areas of ${RRP} grid"; ncatted -h -a long_name,"${RRP}_srf",c,c,"${toto}" areas_croco.nc${gext}

ncrename -h -v ${RUN}.clo,${RUN}_clo -v ${RUN}.cla,${RUN}_cla -v ${RUN}.lat,${RUN}_lat areas_croco.nc${gext}
toto_xbox="${RUN}"'_xbox=earth_radius*earth_radius*('"${RUN}"'_clo(0,:,:)'-"${RUN}"'_clo(1,:,:))/radian'
toto_ybox="${RUN}"'_ybox=2*sin(('"${RUN}"'_cla(0,:,:)'-"${RUN}"'_cla(2,:,:))/radian)'
toto_srf="${RUN}"_srf="${RUN}"'_xbox*'"${RUN}"'_ybox*cos('"${RUN}"'_lat/radian)'
ncap2 -O -s $toto_xbox -s $toto_ybox -s $toto_srf areas_croco.nc${gext} areas_croco.nc${gext} 
ncatted -h -a units,${RUN}_srf,c,c,"m^2" areas_croco.nc${gext}
toto="${RUP}"_srf="${RUN}"_srf
ncap2 -O -s $toto areas_croco.nc${gext} areas_croco.nc${gext}
toto="Areas of ${RUN} grid"; ncatted -h -a long_name,"${RUN}_srf",c,c,"${toto}" areas_croco.nc${gext}
toto="Areas of ${RUP} grid"; ncatted -h -a long_name,"${RUP}_srf",c,c,"${toto}" areas_croco.nc${gext}

ncrename -h -v ${RVN}.clo,${RVN}_clo -v ${RVN}.cla,${RVN}_cla -v ${RVN}.lat,${RVN}_lat areas_croco.nc${gext}
toto_xbox="${RVN}"'_xbox=earth_radius*earth_radius*('"${RVN}"'_clo(0,:,:)'-"${RVN}"'_clo(1,:,:))/radian'
toto_ybox="${RVN}"'_ybox=2*sin(('"${RVN}"'_cla(0,:,:)'-"${RVN}"'_cla(2,:,:))/radian)'
toto_srf="${RVN}"_srf="${RVN}"'_xbox*'"${RVN}"'_ybox*cos('"${RVN}"'_lat/radian)'
ncap2 -O -s $toto_xbox -s $toto_ybox -s $toto_srf areas_croco.nc${gext} areas_croco.nc${gext} 
ncatted -h -a units,${RVN}_srf,c,c,"m^2" areas_croco.nc${gext}
toto="${RVP}"_srf="${RVN}"_srf
ncap2 -O -s $toto areas_croco.nc${gext} areas_croco.nc${gext}
toto="Areas of ${RVN} grid"; ncatted -h -a long_name,"${RVN}_srf",c,c,"${toto}" areas_croco.nc${gext}
toto="Areas of ${RVP} grid"; ncatted -h -a long_name,"${RVP}_srf",c,c,"${toto}" areas_croco.nc${gext}

ncks -O -h -v ${RRN}_srf,${RRP}_srf,${RUN}_srf,${RUP}_srf,${RVN}_srf,${RVP}_srf areas_croco.nc${gext} areas_croco.nc${gext}
ncatted -h -O -a ,global,d,, areas_croco.nc${gext}
}