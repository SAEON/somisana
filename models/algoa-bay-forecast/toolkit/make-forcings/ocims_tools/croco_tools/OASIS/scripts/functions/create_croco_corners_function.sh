create_croco_corners_function()
#--------------------
# Processing CROCO Corners
#--------------------
{
if [ -z "$1" ]
then
   echo "Processing CROCO Parent Corners"
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
       echo "Processing CROCO Parent Corners"
       ngrid='0'
       gext=''
       if [ -f ${croco_grid_file}${gext} ]; then
	   echo '  -->' ${croco_grid_file}${gext} exists 
       else
	   echo '  -->' ${croco_grid_file}${gext} does not exist : EXIT !
	   exit
       fi
   else
       echo "Processing CROCO child N=$1 Corners"
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

#
#--------------------
# 1. Processing CROCO RHO Grid
#--------------------
#
cp -f ${croco_grid_file}${gext} corners_croco_rho.nc${gext}
(( xind_fin = `ncdump -h corners_croco_rho.nc${gext} | grep 'xi_rho =' | cut -d ' ' -f3` - 1))
(( xind_fin_a = `ncdump -h corners_croco_rho.nc${gext} | grep 'xi_u =' | cut -d ' ' -f3` ))
(( xind_fin_b = `ncdump -h corners_croco_rho.nc${gext} | grep 'xi_u =' | cut -d ' ' -f3` - 1))
(( yind_fin = `ncdump -h corners_croco_rho.nc${gext} | grep 'eta_rho =' | cut -d ' ' -f3` - 1 ))
(( yind_fin_a = `ncdump -h corners_croco_rho.nc${gext} | grep 'eta_v =' | cut -d ' ' -f3`  ))
(( yind_fin_b = `ncdump -h corners_croco_rho.nc${gext} | grep 'eta_v =' | cut -d ' ' -f3` - 1 ))

# Usefull variables
ncap2 -h -O -s 'lon=double(lon_u)' corners_croco_rho.nc${gext} corners_croco_rho.nc${gext}
ncap2 -h -O -s 'lat=double(lat_v)' corners_croco_rho.nc${gext} corners_croco_rho.nc${gext}
ncap2 -h -O -s 'xi_rho[xi_rho]=lon_rho(1,:); xi_rho@units="degree east"' corners_croco_rho.nc${gext} corners_croco_rho.nc${gext}
ncap2 -h -O -s 'eta_rho[eta_rho]=lat_rho(:,1); eta_rho@units="degree north"' corners_croco_rho.nc${gext} corners_croco_rho.nc${gext}

# Longitudes
ncks -F -h -v lon corners_croco_rho.nc${gext} corners_croco_rho_tmp_lon1.nc${gext}
ncrename -h -d xi_u,x_${RRN} -d eta_u,y_${RRN} corners_croco_rho_tmp_lon1.nc${gext}
ncks -F -h -d y_${RRN},2,${yind_fin} -d x_${RRN},1,${xind_fin_b} -v lon corners_croco_rho_tmp_lon1.nc${gext} corners_croco_rho_lonb.nc${gext}
ncrename -h -v lon,lon_b corners_croco_rho_lonb.nc${gext}
ncks -F -h -d y_${RRN},2,${yind_fin} -d x_${RRN},2,${xind_fin_a} -v lon corners_croco_rho_tmp_lon1.nc${gext} corners_croco_rho_lona.nc${gext}
ncrename -h -v lon,lon_a corners_croco_rho_lona.nc${gext} 

# Latitudes
ncks -F -h -v lat corners_croco_rho.nc${gext} corners_croco_rho_tmp_lat1.nc${gext}
ncrename -h -d xi_v,x_${RRN} -d eta_v,y_${RRN} corners_croco_rho_tmp_lat1.nc${gext}
ncks -F -h -d x_${RRN},2,${xind_fin} -d y_${RRN},1,${yind_fin_b} -v lat corners_croco_rho_tmp_lat1.nc${gext} corners_croco_rho_latb.nc${gext}
ncrename -h -v lat,lat_b corners_croco_rho_latb.nc${gext}
ncks -F -h -d x_${RRN},2,${xind_fin} -d y_${RRN},2,${yind_fin_a} -v lat corners_croco_rho_tmp_lat1.nc${gext} corners_croco_rho_lata.nc${gext}
ncrename -h -v lat,lat_a corners_croco_rho_lata.nc${gext}

# Dimensions
ncks -O -F -h -d eta_rho,2,${yind_fin} -d xi_rho,2,${xind_fin} -v xi_rho,eta_rho corners_croco_rho.nc${gext} corners_croco_rho.nc${gext}
ncrename -h -d xi_rho,x_${RRN} -d eta_rho,y_${RRN} -v xi_rho,x_${RRN} -v eta_rho,y_${RRN} corners_croco_rho.nc${gext} 

# 4 corners
cp corners_croco_rho.nc${gext} corners1_croco_rho.nc${gext}
ncks -h -A corners_croco_rho_lona.nc${gext} corners1_croco_rho.nc${gext}
ncks -h -A corners_croco_rho_lata.nc${gext} corners1_croco_rho.nc${gext}
ncrename -h -v lon_a,${RRN}_clo -v lat_a,${RRN}_cla corners1_croco_rho.nc${gext}

cp corners_croco_rho.nc${gext} corners2_croco_rho.nc${gext}
ncks -h -A corners_croco_rho_lonb.nc${gext} corners2_croco_rho.nc${gext}
ncks -h -A corners_croco_rho_lata.nc${gext} corners2_croco_rho.nc${gext}
ncrename -h -v lon_b,${RRN}_clo -v lat_a,${RRN}_cla corners2_croco_rho.nc${gext}

cp corners_croco_rho.nc${gext} corners3_croco_rho.nc${gext}
ncks -h -A corners_croco_rho_lonb.nc${gext} corners3_croco_rho.nc${gext}
ncks -h -A corners_croco_rho_latb.nc${gext} corners3_croco_rho.nc${gext}
ncrename -h -v lon_b,${RRN}_clo -v lat_b,${RRN}_cla corners3_croco_rho.nc${gext}

mv corners_croco_rho.nc${gext} corners4_croco_rho.nc${gext}
ncks -h -A corners_croco_rho_lona.nc${gext} corners4_croco_rho.nc${gext}
ncks -h -A corners_croco_rho_latb.nc${gext} corners4_croco_rho.nc${gext}
ncrename -h -v lon_a,${RRN}_clo -v lat_b,${RRN}_cla corners4_croco_rho.nc${gext}

ncecat -h -O corners?_croco_rho.nc${gext} corners_croco_rho.nc${gext}
ncrename -d record,corners corners_croco_rho.nc${gext}
rm -f  corners?_croco_rho.nc${gext} corners_croco_rho_*  

# Duplicate and change longname
toto_lat="${RRP}"_cla="${RRN}"_cla;toto_lon="${RRP}"_clo="${RRN}"_clo
ncap2 -O -s $toto_lat -s $toto_lon corners_croco_rho.nc${gext} corners_croco_rho.nc${gext}
toto_lon="Longitudes of ${RRN} corners"; ncatted -h -a long_name,"${RRN}_clo",m,c,"${toto_lon}" corners_croco_rho.nc${gext}
toto_lat="Latitudes of ${RRN} corners"; ncatted -h -a long_name,"${RRN}_cla",m,c,"${toto_lat}" corners_croco_rho.nc${gext}
toto_lon="Longitudes of ${RRP} corners"; ncatted -h -a long_name,"${RRP}_clo",m,c,"${toto_lon}" corners_croco_rho.nc${gext}
toto_lat="Latitudes of ${RRP} corners"; ncatted -h -a long_name,"${RRP}_cla",m,c,"${toto_lat}" corners_croco_rho.nc${gext}
ncrename -v ${RRN}_clo,${RRN}.clo -v ${RRN}_cla,${RRN}.cla corners_croco_rho.nc${gext}
ncrename -v ${RRP}_clo,${RRP}.clo -v ${RRP}_cla,${RRP}.cla corners_croco_rho.nc${gext}
ncatted -h -O -a ,global,d,, corners_croco_rho.nc${gext}

#
#--------------------
# 2. Processing CROCO U Grid
#--------------------
#
cp -f ${croco_grid_file}${gext} corners_croco_u.nc${gext}
(( xind_fin = `ncdump -h corners_croco_u.nc${gext} | grep 'xi_u =' | cut -d ' ' -f3` - 1 ))
(( xind_fin_a = `ncdump -h corners_croco_u.nc${gext} | grep 'xi_rho =' | cut -d ' ' -f3` -1 ))
(( xind_fin_b = `ncdump -h corners_croco_u.nc${gext} | grep 'xi_rho =' | cut -d ' ' -f3` - 2 ))
(( yind_fin = `ncdump -h corners_croco_u.nc${gext} | grep 'eta_rho =' | cut -d ' ' -f3` - 1 ))
(( yind_fin_a = `ncdump -h corners_croco_u.nc${gext} | grep 'eta_v =' | cut -d ' ' -f3`  ))
(( yind_fin_b = `ncdump -h corners_croco_u.nc${gext} | grep 'eta_v =' | cut -d ' ' -f3` - 1 ))

# Usefull variables
ncap2 -h -O -s 'lon=double(lon_rho)' corners_croco_u.nc${gext} corners_croco_u.nc${gext}
ncap2 -h -O -s 'lat=double(lat_v)' corners_croco_u.nc${gext} corners_croco_u.nc${gext}
ncap2 -h -O -s 'xi_u[xi_u]=lon_u(1,:); xi_u@units="degree east"' corners_croco_u.nc${gext} corners_croco_u.nc${gext}
ncap2 -h -O -s 'eta_u[eta_u]=lat_u(:,1); eta_u@units="degree north"' corners_croco_u.nc${gext} corners_croco_u.nc${gext}

# Longitudes
ncks -F -h -v lon corners_croco_u.nc${gext} corners_croco_u_tmp_lon1.nc${gext}
ncrename -h -d xi_rho,x_${RUN} -d eta_rho,y_${RUN} corners_croco_u_tmp_lon1.nc${gext}
ncks -F -h -d y_${RUN},2,${yind_fin} -d x_${RUN},1,${xind_fin_b} -v lon corners_croco_u_tmp_lon1.nc${gext} corners_croco_u_lonb.nc${gext}
ncrename -h -v lon,lon_b corners_croco_u_lonb.nc${gext}
ncks -F -h -d y_${RUN},2,${yind_fin} -d x_${RUN},2,${xind_fin_a} -v lon corners_croco_u_tmp_lon1.nc${gext} corners_croco_u_lona.nc${gext}
ncrename -h -v lon,lon_a corners_croco_u_lona.nc${gext}

# Latitudes
ncks -F -h -v lat corners_croco_u.nc${gext} corners_croco_u_tmp_lat1.nc${gext}
ncrename -h -d xi_v,x_${RUN} -d eta_v,y_${RUN} corners_croco_u_tmp_lat1.nc${gext}
ncks -F -h -d x_${RUN},2,${xind_fin_a} -d y_${RUN},1,${yind_fin_b} -v lat corners_croco_u_tmp_lat1.nc${gext} corners_croco_u_latb.nc${gext}
ncrename -h -v lat,lat_b corners_croco_u_latb.nc${gext}
ncks -F -h -d x_${RUN},2,${xind_fin_a} -d y_${RUN},2,${yind_fin_a} -v lat corners_croco_u_tmp_lat1.nc${gext} corners_croco_u_lata.nc${gext}
ncrename -h -v lat,lat_a corners_croco_u_lata.nc${gext}

# Dimensions
ncks -O -F -h -d eta_u,2,${yind_fin} -d xi_u,1,${xind_fin} -v xi_u,eta_u corners_croco_u.nc${gext} corners_croco_u.nc${gext}
ncrename -h -d xi_u,x_${RUN} -d eta_u,y_${RUN} -v xi_u,x_${RUN} -v eta_u,y_${RUN} corners_croco_u.nc${gext} 

# 4 corners
cp corners_croco_u.nc${gext} corners1_croco_u.nc${gext}
ncks -h -A corners_croco_u_lona.nc${gext} corners1_croco_u.nc${gext}
ncks -h -A corners_croco_u_lata.nc${gext} corners1_croco_u.nc${gext}
ncrename -h -v lon_a,${RUN}_clo -v lat_a,${RUN}_cla corners1_croco_u.nc${gext}

cp corners_croco_u.nc${gext} corners2_croco_u.nc${gext}
ncks -h -A corners_croco_u_lonb.nc${gext} corners2_croco_u.nc${gext}
ncks -h -A corners_croco_u_lata.nc${gext} corners2_croco_u.nc${gext}
ncrename -h -v lon_b,${RUN}_clo -v lat_a,${RUN}_cla corners2_croco_u.nc${gext}

cp corners_croco_u.nc${gext} corners3_croco_u.nc${gext}
ncks -h -A corners_croco_u_lonb.nc${gext} corners3_croco_u.nc${gext}
ncks -h -A corners_croco_u_latb.nc${gext} corners3_croco_u.nc${gext}
ncrename -h -v lon_b,${RUN}_clo -v lat_b,${RUN}_cla corners3_croco_u.nc${gext}

mv corners_croco_u.nc${gext} corners4_croco_u.nc${gext}
ncks -h -A corners_croco_u_lona.nc${gext} corners4_croco_u.nc${gext}
ncks -h -A corners_croco_u_latb.nc${gext} corners4_croco_u.nc${gext}
ncrename -h -v lon_a,${RUN}_clo -v lat_b,${RUN}_cla corners4_croco_u.nc${gext}

ncecat -h -O corners?_croco_u.nc${gext} corners_croco_u.nc${gext}
ncrename -d record,corners corners_croco_u.nc${gext}
rm -f  corners?_croco_u.nc${gext} corners_croco_u_*  

# Duplicate and change longname
toto_lat="${RUP}"_cla="${RUN}"_cla;toto_lon="${RUP}"_clo="${RUN}"_clo
ncap2 -O -s $toto_lat -s $toto_lon corners_croco_u.nc${gext} corners_croco_u.nc${gext}
toto_lon="Longitudes of ${RUN} corners"; ncatted -h -a long_name,"${RUN}_clo",m,c,"${toto_lon}" corners_croco_u.nc${gext}
toto_lat="Latitudes of ${RUN} corners"; ncatted -h -a long_name,"${RUN}_cla",m,c,"${toto_lat}" corners_croco_u.nc${gext}
toto_lon="Longitudes of ${RUP} corners"; ncatted -h -a long_name,"${RUP}_clo",m,c,"${toto_lon}" corners_croco_u.nc${gext}
toto_lat="Latitudes of ${RUP} corners"; ncatted -h -a long_name,"${RUP}_cla",m,c,"${toto_lat}" corners_croco_u.nc${gext}
ncrename -v ${RUN}_clo,${RUN}.clo -v ${RUN}_cla,${RUN}.cla corners_croco_u.nc${gext}
ncrename -v ${RUP}_clo,${RUP}.clo -v ${RUP}_cla,${RUP}.cla corners_croco_u.nc${gext}
ncatted -h -O -a ,global,d,, corners_croco_u.nc${gext}

#
#--------------------
# 3. Processing CROCO V Grid
#--------------------
#
cp -f ${croco_grid_file}${gext} corners_croco_v.nc${gext}
(( xind_fin = `ncdump -h corners_croco_v.nc${gext} | grep 'xi_rho =' | cut -d ' ' -f3` - 1))
(( xind_fin_a = `ncdump -h corners_croco_v.nc${gext} | grep 'xi_u =' | cut -d ' ' -f3` ))
(( xind_fin_b = `ncdump -h corners_croco_v.nc${gext} | grep 'xi_u =' | cut -d ' ' -f3` - 1))
(( yind_fin = `ncdump -h corners_croco_v.nc${gext} | grep 'eta_v =' | cut -d ' ' -f3` - 1 ))
(( yind_fin_a = `ncdump -h corners_croco_v.nc${gext} | grep 'eta_rho =' | cut -d ' ' -f3` - 1 ))
(( yind_fin_b = `ncdump -h corners_croco_v.nc${gext} | grep 'eta_rho =' | cut -d ' ' -f3` - 2 ))

# Usefull variables
ncap2 -h -O -s 'lon=double(lon_u)' corners_croco_v.nc${gext} corners_croco_v.nc${gext}
ncap2 -h -O -s 'lat=double(lat_rho)' corners_croco_v.nc${gext} corners_croco_v.nc${gext}
ncap2 -h -O -s 'xi_v[xi_v]=lon_v(1,:); xi_v@units="degree east"' corners_croco_v.nc${gext} corners_croco_v.nc${gext}
ncap2 -h -O -s 'eta_v[eta_v]=lat_v(:,1); eta_v@units="degree north"' corners_croco_v.nc${gext} corners_croco_v.nc${gext}

# Longitudes
ncks -F -h -v lon corners_croco_v.nc${gext} corners_croco_v_tmp_lon1.nc${gext}
ncrename -h -d xi_u,x_${RVN} -d eta_u,y_${RVN} corners_croco_v_tmp_lon1.nc${gext}
ncks -F -h -d y_${RVN},1,${yind_fin} -d x_${RVN},1,${xind_fin_b} -v lon corners_croco_v_tmp_lon1.nc${gext} corners_croco_v_lonb.nc${gext}
ncrename -h -v lon,lon_b corners_croco_v_lonb.nc${gext}
ncks -F -h -d y_${RVN},1,${yind_fin} -d x_${RVN},2,${xind_fin_a} -v lon corners_croco_v_tmp_lon1.nc${gext} corners_croco_v_lona.nc${gext}
ncrename -h -v lon,lon_a corners_croco_v_lona.nc${gext} 

# Latitudes
ncks -F -h -v lat corners_croco_v.nc${gext} corners_croco_v_tmp_lat1.nc${gext}
ncrename -h -d xi_rho,x_${RVN} -d eta_rho,y_${RVN} corners_croco_v_tmp_lat1.nc${gext}
ncks -F -h -d x_${RVN},2,${xind_fin} -d y_${RVN},1,${yind_fin_b} -v lat corners_croco_v_tmp_lat1.nc${gext} corners_croco_v_latb.nc${gext}
ncrename -h -v lat,lat_b corners_croco_v_latb.nc${gext}
ncks -F -h -d x_${RVN},2,${xind_fin} -d y_${RVN},2,${yind_fin_a} -v lat corners_croco_v_tmp_lat1.nc${gext} corners_croco_v_lata.nc${gext}
ncrename -h -v lat,lat_a corners_croco_v_lata.nc${gext}

# Dimensions
ncks -O -F -h -d eta_v,1,${yind_fin} -d xi_v,2,${xind_fin} -v xi_v,eta_v corners_croco_v.nc${gext} corners_croco_v.nc${gext}
ncrename -h -d xi_v,x_${RVN} -d eta_v,y_${RVN} -v xi_v,x_${RVN} -v eta_v,y_${RVN} corners_croco_v.nc${gext} 

# 4 corners
cp corners_croco_v.nc${gext} corners1_croco_v.nc${gext}
ncks -h -A corners_croco_v_lona.nc${gext} corners1_croco_v.nc${gext}
ncks -h -A corners_croco_v_lata.nc${gext} corners1_croco_v.nc${gext}
ncrename -h -v lon_a,${RVN}_clo -v lat_a,${RVN}_cla corners1_croco_v.nc${gext}

cp corners_croco_v.nc${gext} corners2_croco_v.nc${gext}
ncks -h -A corners_croco_v_lonb.nc${gext} corners2_croco_v.nc${gext}
ncks -h -A corners_croco_v_lata.nc${gext} corners2_croco_v.nc${gext}
ncrename -h -v lon_b,${RVN}_clo -v lat_a,${RVN}_cla corners2_croco_v.nc${gext}

cp corners_croco_v.nc${gext} corners3_croco_v.nc${gext}
ncks -h -A corners_croco_v_lonb.nc${gext} corners3_croco_v.nc${gext}
ncks -h -A corners_croco_v_latb.nc${gext} corners3_croco_v.nc${gext}
ncrename -h -v lon_b,${RVN}_clo -v lat_b,${RVN}_cla corners3_croco_v.nc${gext}

mv corners_croco_v.nc${gext} corners4_croco_v.nc${gext}
ncks -h -A corners_croco_v_lona.nc${gext} corners4_croco_v.nc${gext}
ncks -h -A corners_croco_v_latb.nc${gext} corners4_croco_v.nc${gext}
ncrename -h -v lon_a,${RVN}_clo -v lat_b,${RVN}_cla corners4_croco_v.nc${gext}

ncecat -h -O corners?_croco_v.nc${gext} corners_croco_v.nc${gext}
ncrename -d record,corners corners_croco_v.nc${gext}
rm -f  corners?_croco_v.nc${gext} corners_croco_v_*  

# Duplicate and change longname
toto_lat="${RVP}"_cla="${RVN}"_cla;toto_lon="${RVP}"_clo="${RVN}"_clo
ncap2 -O -s $toto_lat -s $toto_lon corners_croco_v.nc${gext} corners_croco_v.nc${gext}
toto_lon="Longitudes of ${RVN} corners"; ncatted -h -a long_name,"${RVN}_clo",m,c,"${toto_lon}" corners_croco_v.nc${gext}
toto_lat="Latitudes of ${RVN} corners"; ncatted -h -a long_name,"${RVN}_cla",m,c,"${toto_lat}" corners_croco_v.nc${gext}
toto_lon="Longitudes of ${RVP} corners"; ncatted -h -a long_name,"${RVP}_clo",m,c,"${toto_lon}" corners_croco_v.nc${gext}
toto_lat="Latitudes of ${RVP} corners"; ncatted -h -a long_name,"${RVP}_cla",m,c,"${toto_lat}" corners_croco_v.nc${gext}
ncrename -v ${RVN}_clo,${RVN}.clo -v ${RVN}_cla,${RVN}.cla corners_croco_v.nc${gext}
ncrename -v ${RVP}_clo,${RVP}.clo -v ${RVP}_cla,${RVP}.cla corners_croco_v.nc${gext}
ncatted -h -O -a ,global,d,, corners_croco_v.nc${gext}


#--------------------
# 4. Merging in one file
#--------------------
mv corners_croco_rho.nc${gext} corners_croco.nc${gext}
ncks -h -A corners_croco_u.nc${gext} corners_croco.nc${gext}
ncks -h -A corners_croco_v.nc${gext} corners_croco.nc${gext}
rm -f corners_croco_u.nc${gext} corners_croco_v.nc${gext}
}