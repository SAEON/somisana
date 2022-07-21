create_croco_masks_function()
#--------------------
# Processing CROCO Masks
#--------------------
{
if [ -z "$1" ]
then
   echo "Processing CROCO Parent Masks"
   ngrid='0'
   gext=''
   if [ -f ${croco_grid_file}${gext} ]; then
       echo '  -->' ${croco_grid_file}${gext} exists 
   else
       echo '  -->' ${croco_grid_file}${gext} does not exist : EXIT !
       exit
   fi
else 
   if [ $1 == "0" ]
   then
       echo "Processing CROCO Parent Grids"
       ngrid='0'
       gext=''
       if [ -f ${croco_grid_file}${gext} ]; then
	   echo '  -->' ${croco_grid_file}${gext} exists 
       else
	   echo '  -->' ${croco_grid_file}${gext} does not exist : EXIT !
	   exit
       fi
   else
       echo "Processing CROCO child N=$1 Grids"
       ngrid=$1 
       gext=.$1
       if [ -f ${croco_grid_file}${gext} ]; then
	   echo '  -->' ${croco_grid_file}${gext} exists 
       else
	   echo '  -->' ${croco_grid_file}${gext} does not exist : EXIT !
	   exit
       fi
   fi
fi
RRN=$(echo ${RRN0} | cut -c1-3)$ngrid
RRP=$(echo ${RRP0} | cut -c1-3)$ngrid
RUN=$(echo ${RUN0} | cut -c1-3)$ngrid
RUP=$(echo ${RUP0} | cut -c1-3)$ngrid
RVN=$(echo ${RVN0} | cut -c1-3)$ngrid
RVP=$(echo ${RVP0} | cut -c1-3)$ngrid

echo '  --> CROCO grid sizes:'

# processing Grid RHO
# For croco remove ghost cell -1 et +1 nord et sud
#  RULES :    xind_deb_croco_rho=2
#             xind_fin_croco_rho=Lm0 - 1
#             yind_deb_croco_rho=2
#             yind_fin_croco_rho=Mm0 - 1
#
cp -f ${croco_grid_file}${gext} mask_croco_rho.nc${gext}
xind_deb_croco_rho=2
(( xind_fin_croco_rho = `ncdump -h mask_croco_rho.nc${gext} | grep 'xi_rho =' | cut -d ' ' -f3` - 1 ))
yind_deb_croco_rho=2
(( yind_fin_croco_rho = `ncdump -h mask_croco_rho.nc${gext} | grep 'eta_rho =' | cut -d ' ' -f3` - 1 ))
#echo '  --> RHO:' lon = $xind_deb_croco_rho : $xind_fin_croco_rho , lat = $yind_deb_croco_rho : $yind_fin_croco_rho

ncap2 -O -s 'xi_rho[xi_rho]=lon_rho(1,:); xi_rho@units="degree east"' mask_croco_rho.nc${gext} mask_croco_rho.nc${gext}
ncap2 -O -s 'eta_rho[eta_rho]=lat_rho(:,1); eta_rho@units="degree north"' mask_croco_rho.nc${gext} mask_croco_rho.nc${gext}
ncrename -h -d xi_rho,x_${RRN} -v xi_rho,x_${RRN} mask_croco_rho.nc${gext} 
ncrename -h -d eta_rho,y_${RRN} -v eta_rho,y_${RRN} mask_croco_rho.nc${gext}
ncap2 -O -s 'mask_rho=int(mask_rho)' mask_croco_rho.nc${gext} mask_croco_rho.nc${gext}
ncap2 -O -s 'mask_rho=1-mask_rho' mask_croco_rho.nc${gext} mask_croco_rho.nc${gext}
ncks -O -F -h -d y_${RRN},${yind_deb_croco_rho},${yind_fin_croco_rho} -d x_${RRN},${xind_deb_croco_rho},${xind_fin_croco_rho} -v mask_rho mask_croco_rho.nc${gext} mask_croco_rho.nc${gext}
ncrename -h -v mask_rho,${RRN}_msk mask_croco_rho.nc${gext}
ncatted -O -a ,${RRN}_msk,d,, mask_croco_rho.nc${gext}
toto_msk="${RRP}"_msk="${RRN}"_msk-"${RRN}"_msk
ncap2 -O -s $toto_msk mask_croco_rho.nc${gext} mask_croco_rho.nc${gext}
toto_msk="Mask of ${RRN}"; ncatted -h -a long_name,"${RRN}_msk",c,c,"${toto_msk}" mask_croco_rho.nc${gext}
toto_msk="Mask of ${RRP}"; ncatted -h -a long_name,"${RRP}_msk",c,c,"${toto_msk}" mask_croco_rho.nc${gext}
ncrename -v ${RRN}_msk,${RRN}.msk -v ${RRP}_msk,${RRP}.msk mask_croco_rho.nc${gext}
ncatted -h -O -a ,global,d,, mask_croco_rho.nc${gext}

#
#--------------------
# 2. Processing CROCO U Grid
#--------------------
#
cp -f ${croco_grid_file}${gext} mask_croco_u.nc${gext}
xind_deb_croco_u=1
(( xind_fin_croco_u = `ncdump -h mask_croco_u.nc${gext} | grep 'xi_u =' | cut -c 8-11` - 1 ))
yind_deb_croco_u=2
(( yind_fin_croco_u = `ncdump -h mask_croco_u.nc${gext} | grep 'eta_u =' | cut -c 9-12` - 1 ))

#echo '  --> U  :' lon = $xind_deb_croco_u : $xind_fin_croco_u , lat = $yind_deb_croco_u : $yind_fin_croco_u

ncap2 -O -s 'xi_u[xi_u]=lon_u(1,:); xi_u@units="degree east"' mask_croco_u.nc${gext} mask_croco_u.nc${gext}
ncap2 -O -s 'eta_u[eta_u]=lat_u(:,1); eta_u@units="degree north"' mask_croco_u.nc${gext} mask_croco_u.nc${gext}
ncrename -h -d xi_u,x_${RUN} -v xi_u,x_${RUN} mask_croco_u.nc${gext} 
ncrename -h -d eta_u,y_${RUN} -v eta_u,y_${RUN} mask_croco_u.nc${gext}
ncap2 -O -s 'mask_u=int(mask_u)' mask_croco_u.nc${gext} mask_croco_u.nc${gext}
ncap2 -O -s 'mask_u=1-mask_u' mask_croco_u.nc${gext} mask_croco_u.nc${gext}
ncks -O -F -h -d y_${RUN},${yind_deb_croco_u},${yind_fin_croco_u} -d x_${RUN},${xind_deb_croco_u},${xind_fin_croco_u} -v mask_u mask_croco_u.nc${gext} mask_croco_u.nc${gext}
ncrename -h -v mask_u,${RUN}_msk mask_croco_u.nc${gext}
ncatted -O -a ,${RUN}_msk,d,, mask_croco_u.nc${gext}
toto_msk="${RUP}"_msk="${RUN}"_msk-"${RUN}"_msk
ncap2 -O -s $toto_msk mask_croco_u.nc${gext} mask_croco_u.nc${gext}
toto_msk="Mask of ${RUN}"; ncatted -h -a long_name,"${RUN}_msk",c,c,"${toto_msk}" mask_croco_u.nc${gext}
toto_msk="Mask of ${RUP}"; ncatted -h -a long_name,"${RUP}_msk",c,c,"${toto_msk}" mask_croco_u.nc${gext}
ncrename -v ${RUN}_msk,${RUN}.msk -v ${RUP}_msk,${RUP}.msk mask_croco_u.nc${gext}
ncatted -h -O -a ,global,d,, mask_croco_u.nc${gext}

#
#--------------------
# 3. Processing CROCO V Grid
#--------------------
#
cp -f ${croco_grid_file}${gext} mask_croco_v.nc${gext}
xind_deb_croco_v=2
(( xind_fin_croco_v = `ncdump -h mask_croco_v.nc${gext} | grep 'xi_v =' | cut -c 8-11` - 1 ))
yind_deb_croco_v=1
(( yind_fin_croco_v = `ncdump -h mask_croco_v.nc${gext} | grep 'eta_v =' | cut -c 9-12` - 1 ))
#echo '  --> V  :' lon = $xind_deb_croco_v : $xind_fin_croco_v , lat = $yind_deb_croco_v : $yind_fin_croco_v


ncap2 -O -s 'xi_v[xi_v]=lon_v(1,:); xi_v@units="degree east"' mask_croco_v.nc${gext} mask_croco_v.nc${gext}
ncap2 -O -s 'eta_v[eta_v]=lat_v(:,1); eta_v@units="degree north"' mask_croco_v.nc${gext} mask_croco_v.nc${gext}
ncrename -h -d xi_v,x_${RVN} -v xi_v,x_${RVN} mask_croco_v.nc${gext} 
ncrename -h -d eta_v,y_${RVN} -v eta_v,y_${RVN} mask_croco_v.nc${gext}
ncap2 -O -s 'mask_v=int(mask_v)' mask_croco_v.nc${gext} mask_croco_v.nc${gext}
ncap2 -O -s 'mask_v=1-mask_v' mask_croco_v.nc${gext} mask_croco_v.nc${gext}
ncks -O -F -h -d y_${RVN},${yind_deb_croco_v},${yind_fin_croco_v} -d x_${RVN},${xind_deb_croco_v},${xind_fin_croco_v} -v mask_v mask_croco_v.nc${gext} mask_croco_v.nc${gext}
ncrename -h -v mask_v,${RVN}_msk mask_croco_v.nc${gext}
ncatted -O -a ,${RVN}_msk,d,, mask_croco_v.nc${gext}
toto_msk="${RVP}"_msk="${RVN}"_msk-"${RVN}"_msk
ncap2 -O -s $toto_msk mask_croco_v.nc${gext} mask_croco_v.nc${gext}
toto_msk="Mask of ${RVN}"; ncatted -h -a long_name,"${RVN}_msk",c,c,"${toto_msk}" mask_croco_v.nc${gext}
toto_msk="Mask of ${RVP}"; ncatted -h -a long_name,"${RVP}_msk",c,c,"${toto_msk}" mask_croco_v.nc${gext}
ncrename -v ${RVN}_msk,${RVN}.msk -v ${RVP}_msk,${RVP}.msk mask_croco_v.nc${gext}
ncatted -h -O -a ,global,d,, mask_croco_v.nc${gext}

#--------------------
# 4. Merging in one file
#--------------------
mv mask_croco_rho.nc${gext} masks_croco.nc${gext}
ncks -h -A mask_croco_u.nc${gext} masks_croco.nc${gext}
ncks -h -A mask_croco_v.nc${gext} masks_croco.nc${gext}
rm -f mask_croco_u.nc${gext} mask_croco_v.nc${gext}
}