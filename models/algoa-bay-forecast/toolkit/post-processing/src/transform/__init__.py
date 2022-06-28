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


# Model variables use the dimesions time (time from reference date),
# eta_rho (lat) and xi_rho (lon). We are changing eta_rho and xi_rho 
# from grid pionts to real lat and lon data.

def transform():
    data = xr.open_dataset(MODEL_OUTPUT_PATH)

    print(data)

    # Dimensions that need to be transformed
    time = data.time.values

    # Variables
    sst = data.surf_t.values
    
    # Replace temperatures = 0 celsius with nan
    # In this dataset a temperature of 0 is representative
    # of a grid location that is not water (over land)
    sst[np.where(sst == 0)] = np.nan
    


    # dates = []
    # dates_check = []
    # for t in time:
    #     date_now = REFERENCE_DATE + timedelta(seconds=np.float64(t))
    #     date_round = hour_rounder(date_now)
    #     dates_check.append(date_round)
    #     dates.append(date_round.timestamp())
