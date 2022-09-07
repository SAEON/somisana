create_wrf_CPLMASK_function()
#--------------------
# Processing WRF Masks
#--------------------
{
if [ -z "$1" ]
then
   echo "Processing WRF Parent CPLMASK"
   ngrid='1'
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
       echo "Processing WRF Parent CPLMASK"
       ngrid='1'
       gext=''
       wrf_grid_file2=${wrf_grid_file}
       if [ -f ${wrf_grid_file2} ]; then
	       echo '  -->' ${wrf_grid_file2} exists 
       else
	       echo '  -->' ${wrf_grid_file2} does not exist : EXIT !
	       exit
       fi
   else
       echo "Processing WRF child N=$1 CPLMASK"
       (( ngrid = $1 + 1 ))
       gext=.$1
       wrf_grid_file2=`echo "${wrf_grid_file}" | sed 's/d01/'d0${ngrid}'/'` 
       if [ -f ${wrf_grid_file2} ]; then
	       echo '  -->' ${wrf_grid_file2} exists 
       else
	       echo '  -->' ${wrf_grid_file2} does not exist : EXIT !
	       exit
       fi
   fi
fi


cp -f ${wrf_grid_file2} CPLMASK_d0${ngrid}.nc
xind_deb_wrf=1
(( xind_fin_wrf = `ncdump -h CPLMASK_d0${ngrid}.nc | grep 'west_east =' | cut -d ' ' -f3` ))
yind_deb_wrf=1
(( yind_fin_wrf = `ncdump -h CPLMASK_d0${ngrid}.nc | grep 'south_north =' | cut -d ' ' -f3` ))
#echo '  --> WRF:' lon = $xind_deb_wrf : $xind_fin_wrf , lat = $yind_deb_wrf : $yind_fin_wrf


#--------------------
#WRF GRIDS
# remove Time dimension
ncwa -A -v XLONG_M,XLAT_M,LANDMASK -a Time CPLMASK_d0${ngrid}.nc out.nc${gext}
mv -f out.nc${gext} CPLMASK_d0${ngrid}.nc
ncap2 -O -s 'west_east[west_east]=360.+XLONG_M(1,:); west_east@units="degree east"; south_north[south_north]=XLAT_M(:,1); south_north@units="degree north"'   CPLMASK_d0${ngrid}.nc CPLMASK_d0${ngrid}.nc
ncap2 -O -h -s 'south_north=double(south_north)' CPLMASK_d0${ngrid}.nc  CPLMASK_d0${ngrid}.nc

ncks -O -F -d south_north,${yind_deb_wrf},${yind_fin_wrf} -d west_east,${xind_deb_wrf},${xind_fin_wrf} -v LANDMASK  CPLMASK_d0${ngrid}.nc CPLMASK_d0${ngrid}.nc

ncap2 -h -O -s 'CPLMASK=float(1.-LANDMASK)' CPLMASK_d0${ngrid}.nc CPLMASK_d0${ngrid}.nc
ncks -O -x -v LANDMASK CPLMASK_d0${ngrid}.nc CPLMASK_d0${ngrid}.nc

ncecat -h -O CPLMASK_d0${ngrid}.nc out.nc
ncrename -d record,num_ext_model_couple_dom out.nc
nccopy -u out.nc CPLMASK_d0${ngrid}.nc
ncecat -h -O CPLMASK_d0${ngrid}.nc out.nc
ncrename -d record,Time out.nc
nccopy -u out.nc CPLMASK_d0${ngrid}.nc
ncpdq -O -a Time,num_ext_model_couple_dom,south_north,west_east CPLMASK_d0${ngrid}.nc CPLMASK_d0${ngrid}.nc
rm -f out.nc

#ncatted -O -a ,CPLMASK,d,, CPLMASK_d0${ngrid}.nc
#ncap2 -O -s 'CPLMASK=double(CPLMASK)'  CPLMASK_d0${ngrid}.nc CPLMASK_d0${ngrid}.nc
ncatted -h -a sr_x,CPLMASK,d,, CPLMASK_d0${ngrid}.nc
ncatted -h -a sr_y,CPLMASK,d,, CPLMASK_d0${ngrid}.nc
ncatted -h -a coordinates,CPLMASK,c,c,"XLONG XLAT" CPLMASK_d0${ngrid}.nc
ncatted -h -a description,CPLMASK,o,c,"COUPLING MASK (0 FOR OBSERVATION, 1 FOR COUPLER), number of external domains" CPLMASK_d0${ngrid}.nc
ncatted -h -a stagger,CPLMASK,o,c," " CPLMASK_d0${ngrid}.nc
ncatted -h -a units,CPLMASK,o,c," " CPLMASK_d0${ngrid}.nc
ncatted -h -O -a ,global,d,, CPLMASK_d0${ngrid}.nc
#
}
