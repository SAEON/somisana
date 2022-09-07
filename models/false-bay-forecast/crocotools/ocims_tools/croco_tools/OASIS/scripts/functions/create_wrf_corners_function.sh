create_wrf_corners_function()
#--------------------
# Processing WRF Corners
#--------------------
{
if [ -z "$1" ]
then
   echo "Processing WRF Parent Corners"
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
       echo "Processing WRF Parent Corners"
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
       echo "Processing WRF child N=$1 Corners"
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

cp -f ${wrf_grid_file2} corners_wrf.nc${gext}
(( xind_fin = `ncdump -h corners_wrf.nc${gext} | grep 'west_east =' | cut -d ' ' -f3` ))
(( yind_fin = `ncdump -h corners_wrf.nc${gext} | grep 'south_north =' | cut -d ' ' -f3` ))
(( xind_fin_b = `ncdump -h corners_wrf.nc${gext} | grep 'west_east_stag =' | cut -d ' ' -f3` - 1 ))
(( yind_fin_b = `ncdump -h corners_wrf.nc${gext} | grep 'south_north_stag =' | cut -d ' ' -f3` - 1 ))
(( xind_fin_a = `ncdump -h corners_wrf.nc${gext} | grep 'west_east_stag =' | cut -d ' ' -f3` ))
(( yind_fin_a = `ncdump -h corners_wrf.nc${gext} | grep 'south_north_stag =' | cut -d ' ' -f3` ))



#--------------------
#WRF GRIDS

ncwa -A -v XLONG_M,XLAT_M,XLONG_U,XLAT_V -a Time corners_wrf.nc${gext} out.nc${gext}
mv -f out.nc${gext} corners_wrf.nc${gext}

ncap2 -O -s 'west_east[west_east]=360.+XLONG_M(1,:); south_north[south_north]=XLAT_M(:,1)'   corners_wrf.nc${gext} corners_wrf.nc${gext}
ncap2 -O -h -s 'south_north=double(south_north)' corners_wrf.nc${gext}  corners_wrf.nc${gext}
ncap2 -O -h -s 'lon=360.+XLONG_U(:,:)' corners_wrf.nc${gext} corners_wrf.nc${gext}
ncap2 -O -h -s 'lat=XLAT_V(:,:)+0.' corners_wrf.nc${gext} corners_wrf.nc${gext}

# Longitudes
ncks -F -h -v lon corners_wrf.nc${gext} corners_wrf_tmp_lon1.nc${gext}
ncrename -h -d west_east_stag,x_${WRN} -d south_north,y_${WRN} corners_wrf_tmp_lon1.nc${gext}
ncks -F -h -d y_${WRN},1,${yind_fin} -d x_${WRN},1,${xind_fin_b} -v lon corners_wrf_tmp_lon1.nc${gext} corners_wrf_lonb.nc${gext}
ncrename -h -v lon,lon_b corners_wrf_lonb.nc${gext}
ncks -F -h -d y_${WRN},1,${yind_fin} -d x_${WRN},2,${xind_fin_a} -v lon corners_wrf_tmp_lon1.nc${gext} corners_wrf_lona.nc${gext}
ncrename -h -v lon,lon_a corners_wrf_lona.nc${gext} 

# Latitudes
ncks -F -h -v lat corners_wrf.nc${gext} corners_wrf_tmp_lat1.nc${gext}
ncrename -h -d west_east,x_${WRN} -d south_north_stag,y_${WRN} corners_wrf_tmp_lat1.nc${gext}
ncks -F -h -d x_${WRN},1,${xind_fin} -d y_${WRN},1,${yind_fin_b} -v lat corners_wrf_tmp_lat1.nc${gext} corners_wrf_latb.nc${gext}
ncrename -h -v lat,lat_b corners_wrf_latb.nc${gext}
ncks -F -h -d x_${WRN},1,${xind_fin} -d y_${WRN},2,${yind_fin_a} -v lat corners_wrf_tmp_lat1.nc${gext} corners_wrf_lata.nc${gext}
ncrename -h -v lat,lat_a corners_wrf_lata.nc${gext}

# Dimensions
ncks -O -F -h -d south_north,1,${yind_fin} -d west_east,1,${xind_fin} -v west_east,south_north corners_wrf.nc${gext} corners_wrf.nc${gext}
ncrename -h -d west_east,x_${WRN} -d south_north,y_${WRN} -v west_east,x_${WRN} -v south_north,y_${WRN} corners_wrf.nc${gext} 

# 4 corners
cp corners_wrf.nc${gext} corners1_wrf.nc${gext}
ncks -h -A corners_wrf_lona.nc${gext} corners1_wrf.nc${gext}
ncks -h -A corners_wrf_lata.nc${gext} corners1_wrf.nc${gext}
ncrename -h -v lon_a,${WRN}_clo -v lat_a,${WRN}_cla corners1_wrf.nc${gext}

cp corners_wrf.nc${gext} corners2_wrf.nc${gext}
ncks -h -A corners_wrf_lonb.nc${gext} corners2_wrf.nc${gext}
ncks -h -A corners_wrf_lata.nc${gext} corners2_wrf.nc${gext}
ncrename -h -v lon_b,${WRN}_clo -v lat_a,${WRN}_cla corners2_wrf.nc${gext}

cp corners_wrf.nc${gext} corners3_wrf.nc${gext}
ncks -h -A corners_wrf_lonb.nc${gext} corners3_wrf.nc${gext}
ncks -h -A corners_wrf_latb.nc${gext} corners3_wrf.nc${gext}
ncrename -h -v lon_b,${WRN}_clo -v lat_b,${WRN}_cla corners3_wrf.nc${gext}

mv corners_wrf.nc${gext} corners4_wrf.nc${gext}
ncks -h -A corners_wrf_lona.nc${gext} corners4_wrf.nc${gext}
ncks -h -A corners_wrf_latb.nc${gext} corners4_wrf.nc${gext}
ncrename -h -v lon_a,${WRN}_clo -v lat_b,${WRN}_cla corners4_wrf.nc${gext}

ncecat -h -O corners?_wrf.nc${gext} corners_wrf.nc${gext}
ncrename -d record,corners corners_wrf.nc${gext}
rm -f  corners?_wrf.nc${gext} corners_wrf_*  

# Extent
function_extend_X_corners corners_wrf.nc${gext} x_${WRN} y_${WRN} corners
ncap2 -h -O -s "${WRN}"'_clo(:,:,'"${xind_fin}"')='"${WRN}"'_clo(:,:,'"${xind_fin}"')+dx' corners_wrf.nc${gext} corners_wrf.nc${gext}
ncks -O -x -v dx corners_wrf.nc${gext} corners_wrf.nc${gext}

function_extend_Y_corners corners_wrf.nc${gext} x_${WRN} y_${WRN} corners
ncap2 -h -O -s "${WRN}"'_cla(:,'"${yind_fin}"',:)='"${WRN}"'_cla(:,'"${yind_fin}"',:)+dy' corners_wrf.nc${gext} corners_wrf.nc${gext}
ncks -O -x -v dy corners_wrf.nc${gext} corners_wrf.nc${gext}
ncap2 -O -s "x_${WRN}"'@units="degree east"; '"y_${WRN}"'@units="degree north"' corners_wrf.nc${gext} corners_wrf.nc${gext}

# Duplicate and change longname
ncatted -O -a ,${WRN}_clo,d,, corners_wrf.nc${gext}
ncatted -O -a ,${WRN}_cla,d,, corners_wrf.nc${gext}
toto_lat="${WRP}"_cla="${WRN}"_cla;toto_lon="${WRP}"_clo="${WRN}"_clo
ncap2 -O -s $toto_lat -s $toto_lon corners_wrf.nc${gext} corners_wrf.nc${gext}
toto_lon="Longitudes of ${WRN} corners"; ncatted -h -a long_name,"${WRN}_clo",c,c,"${toto_lon}" corners_wrf.nc${gext}
toto_lat="Latitudes of ${WRN} corners"; ncatted -h -a long_name,"${WRN}_cla",c,c,"${toto_lat}" corners_wrf.nc${gext}
toto_lon="Longitudes of ${WRP} corners"; ncatted -h -a long_name,"${WRP}_clo",c,c,"${toto_lon}" corners_wrf.nc${gext}
toto_lat="Latitudes of ${WRP} corners"; ncatted -h -a long_name,"${WRP}_cla",c,c,"${toto_lat}" corners_wrf.nc${gext}
ncrename -v ${WRN}_clo,${WRN}.clo -v ${WRN}_cla,${WRN}.cla corners_wrf.nc${gext}
ncrename -v ${WRP}_clo,${WRP}.clo -v ${WRP}_cla,${WRP}.cla corners_wrf.nc${gext}
ncatted -h -O -a ,global,d,, corners_wrf.nc${gext}

}
