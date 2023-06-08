"""
Created on Wed Mar 31 13:43:00 2021

@author: cristinarusso
"""

from cli.applications.lacce.detect_lacce.LACCE_function import (
    LACCE as LACCE,
)

#from LACCE_function import LACCE

# Added by matt so script is dynamic
# Name of path and filename
path_in = ''
file_name_in = ''
# Path where output netcdf is stored
path_out = ''

LACCE(path_in       =  path_in+file_name_in,
      path_out      =  path_out,
      lat_var_name  = 'latitude',
      lon_var_name  = 'longitude',
      v_var_name    = 'vgos',
      u_var_name    = 'ugos',
      ssh_var_name  = 'adt',
      east          = 36, 
      west          = 12, 
      south         = -43.875, 
      north         = -25,
      model         = False,
      map_figure    = False)