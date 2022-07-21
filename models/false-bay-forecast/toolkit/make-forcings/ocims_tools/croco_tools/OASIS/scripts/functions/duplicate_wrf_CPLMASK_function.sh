duplicate_wrf_CPLMASK_function()
#--------------------
# Processing WRF Masks
#--------------------
{
if [ -z "$1" ]
then
   echo "Duplicate WRF Parent CPLMASK"
   ngrid='1'
   wrf_cplmask_file=CPLMASK_d0${ngrid}.nc
   if [ -f ${wrf_cplmask_file} ]; then
       echo '  -->' ${wrf_cplmask_file} exists 
   else
       echo '  -->' ${wrf_cplmask_file} does not exist : EXIT !
       exit
   fi
else 
   if [ $1 == "0" ]
   then
       echo "Duplicate WRF Parent CPLMASK"
       ngrid='1'
       gext=''
       wrf_cplmask_file=CPLMASK_d0${ngrid}.nc
       if [ -f ${wrf_grid_file2} ]; then
	       echo '  -->' ${wrf_cplmask_file} exists 
       else
	       echo '  -->' ${wrf_cplmask_file} does not exist : EXIT !
	       exit
       fi
   else
       echo "Duplicate WRF child N=$1 CPLMASK"
       (( ngrid = $1 + 1 ))
       gext=.$1
       wrf_cplmask_file=CPLMASK_d0${ngrid}.nc
       if [ -f ${wrf_grid_file2} ]; then
	       echo '  -->' ${wrf_cplmask_file} exists 
       else
	       echo '  -->' ${wrf_cplmask_file} does not exist : EXIT !
	       exit
       fi
   fi
fi

ncpdq -a num_ext_model_couple_dom,Time,south_north,west_east ${wrf_cplmask_file} ${wrf_cplmask_file}2
ncks -O --mk_rec_dmn num_ext_model_couple_dom ${wrf_cplmask_file}2 ${wrf_cplmask_file}2
ncap2 -s 'CPLMASK=CPLMASK-CPLMASK' ${wrf_cplmask_file}2 ${wrf_cplmask_file}3
ncrcat ${wrf_cplmask_file}2 ${wrf_cplmask_file}3 ${wrf_cplmask_file}4
nccopy -u ${wrf_cplmask_file}4 ${wrf_cplmask_file}5
ncpdq -O -a Time,num_ext_model_couple_dom,south_north,west_east ${wrf_cplmask_file}5 ${wrf_cplmask_file}
ncatted -h -O -a ,global,d,, ${wrf_cplmask_file}
rm -f ${wrf_cplmask_file}2  ${wrf_cplmask_file}3  ${wrf_cplmask_file}4  ${wrf_cplmask_file}5
#
}
