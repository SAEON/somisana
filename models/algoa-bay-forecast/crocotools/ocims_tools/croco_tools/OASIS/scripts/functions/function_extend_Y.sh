function_extend_Y()
#--------------------
# Add a last column
# 1= file_name
#--------------------
{
fname=$1
xname=$2
yname=$3
line=$yname' ='

ncatted -h -O -a ,global,d,, $fname
(( ymax = `ncdump -h $fname | grep "$line" | cut -d ' ' -f3` - 1 ))
(( ymaxm = `ncdump -h $fname | grep "$line" | cut -d ' ' -f3` - 2 ))

# 1. Make $yname a record dimension
ncks -O --mk_rec_dmn $yname $fname y_out.nc
toto=dy="$yname"'('"$ymax"')-'"$yname"'('"$ymaxm"')'
ncap2 -O -s $toto y_out.nc y_out.nc

# 2. Extract last column
ncks -O -d $yname,$ymax y_out.nc yy.nc
ncks -A -v dy y_out.nc yy.nc
toto1="$yname"="$yname"+dy; ncap2 -O -s $toto1 yy.nc yy.nc

# 3. merge 
ncrcat -O y_out.nc yy.nc yy_out.nc
rm -f y_out.nc; nccopy -u yy_out.nc $fname

# 4. clean
rm -f y_out.nc yy_out.nc yy.nc

}

function_extend_Y_corners()
#--------------------
# Add a last column
# 1= file_name
#--------------------
{
fname=$1
xname=$2
yname=$3
cname=$4
line=$yname' ='

ncatted -h -O -a ,global,d,, $fname
(( ymax = `ncdump -h $fname | grep "$line" | cut -d ' ' -f3` - 1 ))
(( ymaxm = `ncdump -h $fname | grep "$line" | cut -d ' ' -f3` - 2 ))

# 1. Make $yname a record dimension
nccopy -u $fname y_out.nc
ncpdq -O -a $yname,$xname,$cname y_out.nc yy_out.nc
ncks -O --mk_rec_dmn $yname yy_out.nc y_out.nc
toto=dy="$yname"'('"$ymax"')-'"$yname"'('"$ymaxm"')'
ncap2 -O -s $toto y_out.nc y_out.nc

# 2. Extract last column
ncks -O -d $yname,$ymax y_out.nc yy.nc
ncks -A -v dy y_out.nc yy.nc
toto1="$yname"="$yname"+dy; ncap2 -O -s $toto1 yy.nc yy.nc

# 3. merge 
ncrcat -O y_out.nc yy.nc yy_out.nc
rm -f y_out.nc; nccopy -u yy_out.nc y_out.nc
ncpdq -O -a $cname,$yname,$xname y_out.nc yy_out.nc
ncks -O --mk_rec_dmn $cname yy_out.nc $fname

# 4. clean
rm -f y_out.nc yy_out.nc yy.nc

}