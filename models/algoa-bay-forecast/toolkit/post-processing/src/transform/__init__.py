import xarray as xr
import numpy as np
from datetime import timedelta, datetime
from config import MODEL_OUTPUT_PATH

# All dates in the CROCO output are represented
# in seconds from 1 Jan 2000 (i.e. the reference date)
REFERENCE_DATE = datetime(2000, 1, 1, 0, 0, 0)

# Rounds to nearest hour by adding a timedelta hour if minute >= 30
def hour_rounder(t):
    return (t.replace(second=0, microsecond=0, minute=0, hour=t.hour) + timedelta(hours=t.minute//30))

# Converts the v current component to the correct (rho) grid
def v2rho_4d(var_v):
      [T,D,M,Lp]=var_v.shape
      var_rho=np.zeros((T,D,M+1,Lp))
      var_rho[:,:,1:M-1,:]=0.5*np.squeeze([var_v[:,:,0:M-2,:]+var_v[:,:,1:M-1,:]])
      var_rho[:,:,0,:]=var_rho[:,:,1,:]
      var_rho[:,:,M,:]=var_rho[:,:,M-1,:]
      return var_rho

# Converts the u current component to the correct (rho) grid
def u2rho_4d(var_u):
      [T,D,Mp,L]=var_u.shape
      var_rho=np.zeros((T,D,Mp,L+1))
      var_rho[:,:,:,1:L-1]=0.5*np.squeeze([var_u[:,:,:,0:L-2]+var_u[:,:,:,1:L-1]])
      var_rho[:,:,:,0]=var_rho[:,:,:,1]
      var_rho[:,:,:,L]=var_rho[:,:,:,L-1]
      return var_rho

# Model variables use the dimesions time (time from reference date),
# eta_rho (lat) and xi_rho (lon). We are changing eta_rho and xi_rho 
# from grid pionts to real lat and lon data.

def transform():
    data = xr.open_dataset(MODEL_OUTPUT_PATH)

    print(data)

    # Dimensions that need to be transformed
    time = data.time.values
    lon_rho = data.lon_rho.values
    lat_rho = data.lat_rho.values

    # Convert time to human readable 
    dates = []
    for t in time:
        date_now = REFERENCE_DATE + timedelta(seconds=np.float64(t))
        date_round = hour_rounder(date_now)
        dates.append(date_round)

    # Variables used in the visualtions
    temperature = data.temp.values
    salt = data.salt.values
    u = data.u.values
    v = data.v.values

    # Convert u and v current components to the rho grid
    # use the function u2rho_4d and v2rho_4d
    u_rho = u2rho_4d(u)
    v_rho = v2rho_4d(v)

    # Replace temperatures = 0 celsius with nan
    # In this dataset a temperature of 0 is representative
    # of a grid location that is not water (over land)
    temperature[np.where(temperature == 0)] = np.nan
    salt[np.where(salt == 0)] = np.nan
    u[np.where(u == 0)] = np.nan
    v[np.where(v == 0)] = np.nan

    # Create new xarray dataset with selected variable 
    data_out = xr.Dataset(
        data_vars=dict(
            temperature=(["time","lat", "lon"], temperature[:,0,:,:]),
            salt=(["time","lat", "lon"], salt[:,0,:,:]),
            u=(["time","lat", "lon"], u_rho[:,0,:,:]),
            v=(["time","lat", "lon"], v_rho[:,0,:,:]),
        ),
        coords=dict(
            lon_rho=(["lat", "lon"], lon_rho),
            lat_rho=(["lat", "lon"], lat_rho),
            time=dates,
        ),
        attrs=dict(description="CROCO output from algoa Bay model transformed lon/lat/depth/time"),
    )

    #Print output 
    print(data_out)