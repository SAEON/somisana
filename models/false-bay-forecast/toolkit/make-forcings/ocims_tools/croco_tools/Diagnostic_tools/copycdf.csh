#!/bin/csh
#
#  copy the header and the grid variables of a netcdf CROCO history file 
#  to generate a new history file (to store diagnostics)
#
#  Further Information:  
#  http://www.croco-ocean.org
#  
#  This file is part of CROCOTOOLS
#
#  CROCOTOOLS is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published
#  by the Free Software Foundation; either version 2 of the License,
#  or (at your option) any later version.
#
#  CROCOTOOLS is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
#  MA  02111-1307  USA
#
#  Copyright (c) 2005-2006 by Pierrick Penven 
#  e-mail:Pierrick.Penven@ird.fr  
#
######################################################################
if ($#argv != 3) then
   echo Usage: $0 inputfile outputfile \"type\"
   exit 127
endif
#
set inputfile = $1
set outputfile = $2
set newtype = "$3"
echo $newtype
#
ncdump -v spherical,xl,el,h,f,pm,pn,lon_rho,lat_rho,angle,mask_rho $inputfile > tmp1.cdl
#
cat > msg1 << EOF1
/:type = /{
        c\
                :type = "`echo $newtype`" ;
}
EOF1
#
cat > msg2 << EOF2
/:date = /{
        c\
                :date = "`date`" ;
}
EOF2

sed -f msg1 < tmp1.cdl > tmp2.cdl
sed -f msg2 < tmp2.cdl > tmp1.cdl
rm -f msg1 msg2
ncgen -o $outputfile tmp1.cdl
rm -f tmp1.cdl tmp2.cdl


