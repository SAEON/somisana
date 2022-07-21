create_wrf_masks_function()
#--------------------
# Processing WRF Masks
#--------------------
{
if [ -z "$1" ]
then
   echo "Processing WRF Parent Masks"
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
       echo "Processing WRF Parent Masks"
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
       echo "Processing WRF child N=$1 Masks"
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

cp -f ${wrf_grid_file2} masks_wrf.nc${gext}
xind_deb_wrf=1
(( xind_fin_wrf = `ncdump -h masks_wrf.nc${gext} | grep 'west_east =' | cut -d ' ' -f3` ))
yind_deb_wrf=1
(( yind_fin_wrf = `ncdump -h masks_wrf.nc${gext} | grep 'south_north =' | cut -d ' ' -f3` ))
#echo '  --> WRF:' lon = $xind_deb_wrf : $xind_fin_wrf , lat = $yind_deb_wrf : $yind_fin_wrf


#--------------------
#WRF GRIDS
# remove Time dimension
ncwa -A -v XLONG_M,XLAT_M,LANDMASK -a Time masks_wrf.nc${gext} out.nc${gext}
mv -f out.nc${gext} masks_wrf.nc${gext}

ncap2 -O -s 'west_east[west_east]=360.+XLONG_M(1,:); south_north[south_north]=XLAT_M(:,1)'   masks_wrf.nc${gext} masks_wrf.nc${gext}
ncap2 -O -h -s 'south_north=double(south_north)' masks_wrf.nc${gext}  masks_wrf.nc${gext}

ncrename -h -d south_north,y_${WRN} -v south_north,y_${WRN} masks_wrf.nc${gext}
ncrename -h -d west_east,x_${WRN} -v west_east,x_${WRN} masks_wrf.nc${gext}
ncks -O -F -d y_${WRN},${yind_deb_wrf},${yind_fin_wrf} -d x_${WRN},${xind_deb_wrf},${xind_fin_wrf} -v LANDMASK masks_wrf.nc${gext} masks_wrf.nc${gext}

# Extent grid
function_extend_X masks_wrf.nc${gext} x_${WRN} y_${WRN}
ncap2 -h -O -s 'LANDMASK(:,'"${xind_fin_wrf}"')=1.' masks_wrf.nc${gext} masks_wrf.nc${gext}
ncks -O -x -v dx masks_wrf.nc${gext} masks_wrf.nc${gext}
function_extend_Y masks_wrf.nc${gext} x_${WRN} y_${WRN}
ncap2 -h -O -s 'LANDMASK('"${yind_fin_wrf}"',)=1.' masks_wrf.nc${gext} masks_wrf.nc${gext}
ncks -O -x -v dy masks_wrf.nc${gext} masks_wrf.nc${gext}

ncap2 -O -s "x_${WRN}"'@units="degree east"; '"y_${WRN}"'@units="degree north"' masks_wrf.nc${gext} masks_wrf.nc${gext}
ncap2 -h -O -s 'LANDMASK=int(LANDMASK)' masks_wrf.nc${gext} masks_wrf.nc${gext}
ncrename -v LANDMASK,${WRN}_msk masks_wrf.nc${gext}
ncatted -O -a ,${WRN}_msk,d,, masks_wrf.nc${gext}
ncap2 -O -s "${WRP}"'_msk='"${WRN}"'_msk' masks_wrf.nc${gext} masks_wrf.nc${gext}
toto_msk="Mask of ${WRN}"; ncatted -h -a long_name,"${WRN}_msk",c,c,"${toto_msk}" masks_wrf.nc${gext}
toto_msk="Mask of ${WRP}"; ncatted -h -a long_name,"${WRP}_msk",c,c,"${toto_msk}" masks_wrf.nc${gext}
ncrename -v ${WRN}_msk,${WRN}.msk -v ${WRP}_msk,${WRP}.msk masks_wrf.nc${gext}
ncatted -h -O -a ,global,d,, masks_wrf.nc${gext}
#
}
