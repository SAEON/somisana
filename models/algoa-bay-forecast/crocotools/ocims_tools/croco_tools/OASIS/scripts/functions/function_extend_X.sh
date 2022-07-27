function_extend_X()
#--------------------
# Add a last column
# 1= file_name
#--------------------
{
fname=$1
xname=$2
yname=$3
line=$xname' ='

ncatted -h -O -a ,global,d,, $fname
(( xmax = `ncdump -h $fname | grep "$line" | cut -d ' ' -f3` - 1 ))
(( xmaxm = `ncdump -h $fname | grep "$line" | cut -d ' ' -f3` - 2 ))

# 1. Make $xname a record dimension
ncpdq -O -a $xname,$yname $fname x_out.nc
ncks -O --mk_rec_dmn $xname x_out.nc x_out.nc
toto=dx="$xname"'('"$xmax"')-'"$xname"'('"$xmaxm"')'
ncap2 -O -s $toto x_out.nc x_out.nc

# 2. Extract last column
ncks -O -d $xname,$xmax x_out.nc xx.nc
ncks -A -v dx x_out.nc xx.nc
toto1="$xname"="$xname"+dx; ncap2 -O -s $toto1 xx.nc xx.nc

# 3. merge 
ncrcat -O x_out.nc xx.nc xx_out.nc

rm -f x_out.nc; nccopy -u xx_out.nc x_out.nc
ncpdq -O -a $yname,$xname x_out.nc $fname

# 4. clean
rm -f x_out.nc xx_out.nc xx.nc
}

function_extend_X_corners()
#--------------------
# Add a last column
# 1= file_name
#--------------------
{
fname=$1
xname=$2
yname=$3
cname=$4
line=$xname' ='

ncatted -h -O -a ,global,d,, $fname
(( xmax = `ncdump -h $fname | grep "$line" | cut -d ' ' -f3` - 1 ))
(( xmaxm = `ncdump -h $fname | grep "$line" | cut -d ' ' -f3` - 2 ))

# 1. Make $xname a record dimension
nccopy -u $fname x_out.nc
ncpdq -O -a $xname,$yname,$cname x_out.nc xx_out.nc
ncks -O --mk_rec_dmn $xname xx_out.nc x_out.nc
toto=dx="$xname"'('"$xmax"')-'"$xname"'('"$xmaxm"')'
ncap2 -O -s $toto x_out.nc x_out.nc

# 2. Extract last column
ncks -O -d $xname,$xmax x_out.nc xx.nc
ncks -A -v dx x_out.nc xx.nc
toto1="$xname"="$xname"+dx; ncap2 -O -s $toto1 xx.nc xx.nc

# 3. merge 
ncrcat -O x_out.nc xx.nc xx_out.nc
rm -f x_out.nc; nccopy -u xx_out.nc x_out.nc
ncpdq -O -a $cname,$yname,$xname x_out.nc xx_out.nc
ncks -O --mk_rec_dmn $cname xx_out.nc $fname

# 4. clean
rm -f x_out.nc xx_out.nc xx.nc
}