create_croco_grids_function()
#--------------------
# Processing CROCO Grids
#--------------------
{
if [ -z "$1" ]
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
cp -f ${croco_grid_file}${gext} grid_croco_rho.nc${gext}
xind_deb_croco_rho=2
(( xind_fin_croco_rho = `ncdump -h grid_croco_rho.nc${gext} | grep 'xi_rho =' | cut -d ' ' -f3` - 1 ))
yind_deb_croco_rho=2
(( yind_fin_croco_rho = `ncdump -h grid_croco_rho.nc${gext} | grep 'eta_rho =' | cut -d ' ' -f3` - 1 ))
echo '  --> RHO:' lon = $xind_deb_croco_rho : $xind_fin_croco_rho , lat = $yind_deb_croco_rho : $yind_fin_croco_rho

ncap2 -O -s 'xi_rho[xi_rho]=lon_rho(1,:); xi_rho@units="degree east"' grid_croco_rho.nc${gext} grid_croco_rho.nc${gext}
ncap2 -O -s 'eta_rho[eta_rho]=lat_rho(:,1); eta_rho@units="degree north"' grid_croco_rho.nc${gext} grid_croco_rho.nc${gext}
ncrename -h -d xi_rho,x_${RRN} -v xi_rho,x_${RRN} grid_croco_rho.nc${gext} 
ncrename -h -d eta_rho,y_${RRN} -v eta_rho,y_${RRN} grid_croco_rho.nc${gext}
ncap2 -O -s 'lon_rho=double(lon_rho)' grid_croco_rho.nc${gext} grid_croco_rho.nc${gext}
ncap2 -O -s 'lat_rho=double(lat_rho)' grid_croco_rho.nc${gext} grid_croco_rho.nc${gext}
ncks -O -F -h -d y_${RRN},${yind_deb_croco_rho},${yind_fin_croco_rho} -d x_${RRN},${xind_deb_croco_rho},${xind_fin_croco_rho} -v lon_rho,lat_rho grid_croco_rho.nc${gext} grid_croco_rho.nc${gext}
ncrename -h -v lon_rho,${RRN}_lon grid_croco_rho.nc${gext}
ncrename -h -v lat_rho,${RRN}_lat grid_croco_rho.nc${gext}
ncatted -h -a units,${RRN}_lon,m,c,"degree east" grid_croco_rho.nc${gext}
ncatted -h -a units,${RRN}_lat,m,c,"degree north" grid_croco_rho.nc${gext}
toto_lat="${RRP}"_lat="${RRN}"_lat;toto_lon="${RRP}"_lon="${RRN}"_lon
ncap2 -O -s $toto_lat -s $toto_lon grid_croco_rho.nc${gext} grid_croco_rho.nc${gext}
toto_lon="Longitudes of ${RRN}"; ncatted -h -a long_name,"${RRN}_lon",m,c,"${toto_lon}" grid_croco_rho.nc${gext}
toto_lat="Latitudes of ${RRN}"; ncatted -h -a long_name,"${RRN}_lat",m,c,"${toto_lat}" grid_croco_rho.nc${gext}
toto_lon="Longitudes of ${RRP}"; ncatted -h -a long_name,"${RRP}_lon",m,c,"${toto_lon}" grid_croco_rho.nc${gext}
toto_lat="Latitudes of ${RRP}"; ncatted -h -a long_name,"${RRP}_lat",m,c,"${toto_lat}" grid_croco_rho.nc${gext}
ncrename -v ${RRN}_lon,${RRN}.lon -v ${RRN}_lat,${RRN}.lat grid_croco_rho.nc${gext}
ncrename -v ${RRP}_lon,${RRP}.lon -v ${RRP}_lat,${RRP}.lat grid_croco_rho.nc${gext}
ncatted -h -O -a ,global,d,, grid_croco_rho.nc${gext}

#
#--------------------
# 2. Processing CROCO U Grid
#--------------------
#
cp -f ${croco_grid_file}${gext} grid_croco_u.nc${gext}
xind_deb_croco_u=1
(( xind_fin_croco_u = `ncdump -h grid_croco_u.nc${gext} | grep 'xi_u =' | cut -c 8-11` - 1 ))
yind_deb_croco_u=2
(( yind_fin_croco_u = `ncdump -h grid_croco_u.nc${gext} | grep 'eta_u =' | cut -c 9-12` - 1 ))

echo '  --> U  :' lon = $xind_deb_croco_u : $xind_fin_croco_u , lat = $yind_deb_croco_u : $yind_fin_croco_u

ncap2 -O -s 'xi_u[xi_u]=lon_u(1,:); xi_u@units="degree east"' grid_croco_u.nc${gext} grid_croco_u.nc${gext}
ncap2 -O -s 'eta_u[eta_u]=lat_u(:,1); eta_u@units="degree north"' grid_croco_u.nc${gext} grid_croco_u.nc${gext}
ncrename -h -d xi_u,x_${RUN} -v xi_u,x_${RUN} grid_croco_u.nc${gext} 
ncrename -h -d eta_u,y_${RUN} -v eta_u,y_${RUN} grid_croco_u.nc${gext}
ncap2 -O -s 'lon_u=double(lon_u)' grid_croco_u.nc${gext} grid_croco_u.nc${gext}
ncap2 -O -s 'lat_u=double(lat_u)' grid_croco_u.nc${gext} grid_croco_u.nc${gext}
ncks -O -F -h -d y_${RUN},${yind_deb_croco_u},${yind_fin_croco_u} -d x_${RUN},${xind_deb_croco_u},${xind_fin_croco_u} -v lon_u,lat_u grid_croco_u.nc${gext} grid_croco_u.nc${gext}
ncrename -h -v lon_u,${RUN}_lon grid_croco_u.nc${gext}
ncrename -h -v lat_u,${RUN}_lat grid_croco_u.nc${gext}
ncatted -h -a units,${RUN}_lon,m,c,"degree east" grid_croco_u.nc${gext}
ncatted -h -a units,${RUN}_lat,m,c,"degree north" grid_croco_u.nc${gext}
toto_lat="${RUP}"_lat="${RUN}"_lat;toto_lon="${RUP}"_lon="${RUN}"_lon
ncap2 -O -s $toto_lat -s $toto_lon grid_croco_u.nc${gext} grid_croco_u.nc${gext}
toto_lon="Longitudes of ${RUN}"; ncatted -h -a long_name,"${RUN}_lon",m,c,"${toto_lon}" grid_croco_u.nc${gext}
toto_lat="Latitudes of ${RUN}"; ncatted -h -a long_name,"${RUN}_lat",m,c,"${toto_lat}" grid_croco_u.nc${gext}
toto_lon="Longitudes of ${RUP}"; ncatted -h -a long_name,"${RUP}_lon",m,c,"${toto_lon}" grid_croco_u.nc${gext}
toto_lat="Latitudes of ${RUP}"; ncatted -h -a long_name,"${RUP}_lat",m,c,"${toto_lat}" grid_croco_u.nc${gext}
ncrename -v ${RUN}_lon,${RUN}.lon -v ${RUN}_lat,${RUN}.lat grid_croco_u.nc${gext}
ncrename -v ${RUP}_lon,${RUP}.lon -v ${RUP}_lat,${RUP}.lat grid_croco_u.nc${gext}
ncatted -h -O -a ,global,d,, grid_croco_u.nc${gext}

#
#--------------------
# 3. Processing CROCO V Grid
#--------------------
#
cp -f ${croco_grid_file}${gext} grid_croco_v.nc${gext}
xind_deb_croco_v=2
(( xind_fin_croco_v = `ncdump -h grid_croco_v.nc${gext} | grep 'xi_v =' | cut -c 8-11` - 1 ))
yind_deb_croco_v=1
(( yind_fin_croco_v = `ncdump -h grid_croco_v.nc${gext} | grep 'eta_v =' | cut -c 9-12` - 1 ))
echo '  --> V  :' lon = $xind_deb_croco_v : $xind_fin_croco_v , lat = $yind_deb_croco_v : $yind_fin_croco_v

ncap2 -O -s 'xi_v[xi_v]=lon_v(1,:); xi_v@units="degree east"' grid_croco_v.nc${gext} grid_croco_v.nc${gext}
ncap2 -O -s 'eta_v[eta_v]=lat_v(:,1); eta_v@units="degree north"' grid_croco_v.nc${gext} grid_croco_v.nc${gext}
ncrename -h -d xi_v,x_${RVN} -v xi_v,x_${RVN} grid_croco_v.nc${gext} 
ncrename -h -d eta_v,y_${RVN} -v eta_v,y_${RVN} grid_croco_v.nc${gext}
ncap2 -O -s 'lon_v=double(lon_v)' grid_croco_v.nc${gext} grid_croco_v.nc${gext}
ncap2 -O -s 'lat_v=double(lat_v)' grid_croco_v.nc${gext} grid_croco_v.nc${gext}
ncks -O -F -h -d y_${RVN},${yind_deb_croco_v},${yind_fin_croco_v} -d x_${RVN},${xind_deb_croco_v},${xind_fin_croco_v} -v lon_v,lat_v grid_croco_v.nc${gext} grid_croco_v.nc${gext}
ncrename -h -v lon_v,${RVN}_lon grid_croco_v.nc${gext}
ncrename -h -v lat_v,${RVN}_lat grid_croco_v.nc${gext}
ncatted -h -a units,${RVN}_lon,m,c,"degree east" grid_croco_v.nc${gext}
ncatted -h -a units,${RVN}_lat,m,c,"degree north" grid_croco_v.nc${gext}
toto_lat="${RVP}"_lat="${RVN}"_lat;toto_lon="${RVP}"_lon="${RVN}"_lon
ncap2 -O -s $toto_lat -s $toto_lon grid_croco_v.nc${gext} grid_croco_v.nc${gext}
toto_lon="Longitudes of ${RVN}"; ncatted -h -a long_name,"${RVN}_lon",m,c,"${toto_lon}" grid_croco_v.nc${gext}
toto_lat="Latitudes of ${RVN}"; ncatted -h -a long_name,"${RVN}_lat",m,c,"${toto_lat}" grid_croco_v.nc${gext}
toto_lon="Longitudes of ${RVP}"; ncatted -h -a long_name,"${RVP}_lon",m,c,"${toto_lon}" grid_croco_v.nc${gext}
toto_lat="Latitudes of ${RVP}"; ncatted -h -a long_name,"${RVP}_lat",m,c,"${toto_lat}" grid_croco_v.nc${gext}
ncrename -v ${RVN}_lon,${RVN}.lon -v ${RVN}_lat,${RVN}.lat grid_croco_v.nc${gext}
ncrename -v ${RVP}_lon,${RVP}.lon -v ${RVP}_lat,${RVP}.lat grid_croco_v.nc${gext}
ncatted -h -O -a ,global,d,, grid_croco_v.nc${gext}

#--------------------
# 4. Merging in one file
#--------------------
mv grid_croco_rho.nc${gext} grids_croco.nc${gext}
ncks -h -A grid_croco_u.nc${gext} grids_croco.nc${gext}
ncks -h -A grid_croco_v.nc${gext} grids_croco.nc${gext}
rm -f grid_croco_u.nc${gext} grid_croco_v.nc${gext}
}