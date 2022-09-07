create_wrf_grids_function()
#--------------------
# Processing WRF Grids
#--------------------
{
if [ -z "$1" ]
then
   echo "Processing WRF Parent Grids"
   ngrid='0'
   gext=''
   wrf_grid_file2=${wrf_grid_file}
   if [ -f ${wrf_grid_file2} ]; then
       echo '  -->' ${wrf_grid_file2} exists 
   else
       echo '  -->' ${wrf_grid_file2} does not exist : EXIT !
       exit
   fi
else 
   if [ $1 == "0" ]
   then
       echo "Processing WRF Parent Grids"
       ngrid='0'
       gext=''
       wrf_grid_file2=${wrf_grid_file}
       if [ -f ${wrf_grid_file2} ]; then
	       echo '  -->' ${wrf_grid_file2} exists 
       else
	       echo '  -->' ${wrf_grid_file2} does not exist : EXIT !
	       exit
       fi
   else
       echo "Processing WRF child N=$1 Grids"
       (( ngrid = $1 + 1 ))
       gext=.$1
       wrf_grid_file2=`echo "${wrf_grid_file}" | sed 's/d01/'d0${ngrid}'/'` 
       ngrid=$1
       if [ -f ${wrf_grid_file2} ]; then
	       echo '  -->' ${wrf_grid_file2} exists 
       else
	       echo '  -->' ${wrf_grid_file2} does not exist : EXIT !
	       exit
       fi
   fi
fi

WRN=$(echo ${WRN0} | cut -c1-3)$ngrid
WRP=$(echo ${WRP0} | cut -c1-3)$ngrid

. ${functions_path}/function_extend_X.sh
. ${functions_path}/function_extend_Y.sh


cp -f ${wrf_grid_file2} grids_wrf.nc${gext}
xind_deb_wrf=1
(( xind_fin_wrf = `ncdump -h grids_wrf.nc${gext} | grep 'west_east =' | cut -d ' ' -f3` ))
yind_deb_wrf=1
(( yind_fin_wrf = `ncdump -h grids_wrf.nc${gext} | grep 'south_north =' | cut -d ' ' -f3` ))
echo '  --> WRF:' lon = $xind_deb_wrf : $xind_fin_wrf , lat = $yind_deb_wrf : $yind_fin_wrf


#--------------------
#WRF GRIDS
# remove Time dimension
ncwa -A -v XLONG_M,XLAT_M -a Time grids_wrf.nc${gext} out.nc${gext}
mv -f out.nc${gext} grids_wrf.nc${gext}

ncap2 -O -s 'west_east[west_east]=360.+XLONG_M(1,:); south_north[south_north]=XLAT_M(:,1)'   grids_wrf.nc${gext} grids_wrf.nc${gext}
ncap2 -O -h -s 'south_north=double(south_north)' grids_wrf.nc${gext}  grids_wrf.nc${gext}
ncrename -h -d south_north,y_${WRN} -v south_north,y_${WRN} grids_wrf.nc${gext}
ncrename -h -d west_east,x_${WRN} -v west_east,x_${WRN} grids_wrf.nc${gext}
ncks -O -F -d y_${WRN},${yind_deb_wrf},${yind_fin_wrf} -d x_${WRN},${xind_deb_wrf},${xind_fin_wrf} -v XLONG_M,XLAT_M  grids_wrf.nc${gext} grids_wrf.nc${gext}
ncap2 -O -h -s 'XLONG_M=double(XLONG_M)+360.' -s 'XLAT_M=double(XLAT_M)' grids_wrf.nc${gext} grids_wrf.nc${gext} 

# Extent
function_extend_X grids_wrf.nc${gext} x_${WRN} y_${WRN}
ncap2 -h -O -s 'XLONG_M(:,'"${xind_fin_wrf}"')=XLONG_M(:,'"${xind_fin_wrf}"')+dx' grids_wrf.nc${gext} grids_wrf.nc${gext}
ncks -O -x -v dx grids_wrf.nc${gext} grids_wrf.nc${gext}

function_extend_Y grids_wrf.nc${gext} x_${WRN} y_${WRN}
ncap2 -h -O -s 'XLAT_M('"${yind_fin_wrf}"',)=XLAT_M('"${yind_fin_wrf}"',)+dy' grids_wrf.nc${gext} grids_wrf.nc${gext}
ncks -O -x -v dy grids_wrf.nc${gext} grids_wrf.nc${gext}

# Do it nicely
ncap2 -O -s "x_${WRN}"'@units="degree east"; '"y_${WRN}"'@units="degree north"' grids_wrf.nc${gext} grids_wrf.nc${gext}
ncrename -h -v XLONG_M,${WRN}_lon grids_wrf.nc${gext}
ncrename -h -v XLAT_M,${WRN}_lat grids_wrf.nc${gext}
ncatted -O -a ,${WRN}_lon,d,, grids_wrf.nc${gext}
ncatted -O -a ,${WRN}_lat,d,, grids_wrf.nc${gext}
ncatted -h -a units,${WRN}_lon,c,c,"degree east" grids_wrf.nc${gext}
ncatted -h -a units,${WRN}_lat,c,c,"degree north" grids_wrf.nc${gext}

# Duplicate
toto_lat="${WRP}"_lat="${WRN}"_lat;toto_lon="${WRP}"_lon="${WRN}"_lon
ncap2 -O -s $toto_lat -s $toto_lon grids_wrf.nc${gext} grids_wrf.nc${gext}
toto_lon="Longitudes of ${WRN}";ncatted -h -a long_name,"${WRN}_lon",c,c,"${toto_lon}" grids_wrf.nc${gext}
toto_lat="Latitudes of ${WRN}"; ncatted -h -a long_name,"${WRN}_lat",c,c,"${toto_lat}" grids_wrf.nc${gext}
toto_lon="Longitudes of ${WRP}";ncatted -h -a long_name,"${WRP}_lon",c,c,"${toto_lon}" grids_wrf.nc${gext}
toto_lat="Latitudes of ${WRP}"; ncatted -h -a long_name,"${WRP}_lat",c,c,"${toto_lat}" grids_wrf.nc${gext}
ncrename -v ${WRN}_lon,${WRN}.lon -v ${WRN}_lat,${WRN}.lat grids_wrf.nc${gext}
ncrename -v ${WRP}_lon,${WRP}.lon -v ${WRP}_lat,${WRP}.lat grids_wrf.nc${gext}
ncatted -h -O -a ,global,d,, grids_wrf.nc${gext}
}
