# Configuration file for running an OpenOil simulation 
#
from datetime import datetime, timedelta
#
# ---------------------------------------
# configuration name and run date to use
# ---------------------------------------
#
# give a name for your configuration
# output will be written to a directory with this name
# which will be accessible via the somisana thredds or mnemosyne file server
config_name = 'JennyTest'
#
# croco run date
# this is intentionally a string in 'yyyymmdd' format so it can also be easily read by the github workflow (needed for creating an appropriate directory on the public facing file server) 
# note that only runs from the last 5 days are stored for running opendrift
# the croco model is configured to produce output from 5 days before to 5 days after the run date
croco_run_date = '20240122'

# -----------
# spill info
# -----------
#
# coordinates of the spill (in geographical degrees)
lon_spill=26.43
lat_spill=-33.8
#
# depth of the release
# For a surface release I prefer to put a small negative number like z=-0.001
# this effectively means the weathering is applied after mixing in the first time-step
# for a subsurface release you can also specify a distance off the seabed like z='seafloor+100' for 100m off the bottom
z=-0.001
#
# radius to be used in initialising the particles
# particles will be initialised around 'lon_spill,lat_spill' using a standard deviation of 'radius'
# this allows for some initial spreading at location of the initialised particles 
# for a subsea blowout this could be hundereds of meters, but a surface spill it will be small, in the order of meters
radius=5
#
# specify the oil type - important for weathering properties
# Can choose any oil name from https://adios.orr.noaa.gov/oils/
# Or some Norgegain oils from https://opendrift.github.io/oil_types.html
# Or a few other generic oil types added as part of opendrift, such as 'GENERIC INTERMEDIATE FUEL OIL 180'
oil_type='GENERIC DIESEL'
#
# start time of spill - use local time (UTC+2)
#spill_start_time=datetime.now() # change to whenever the spill should be 
spill_start_time=datetime(2024,1,21,21,0,0)
#
# duration of the release of oil in hours
release_dur=10
#
# volume of oil spilled in m3
# This is not used directly in the model - it's only used here to get the oil flow rate below
# so you can also specify the 'oil_flow_rate' directly and comment 'oil_volume' if that is convenient 
oil_volume=41.71633
# (35 tonnes, using density of 839 kg/m3 for generic diesel)
#
# oil flow rate in m3/hr
oil_flow_rate=oil_volume/release_dur

# -------------
# forcing files
# -------------
#
# the directories are all under /tmp/, which refers to the directory inside the container running opendrift
# the actual paths on the server where this is being run need to be mounted to /tmp/ when running the opendrift docker image
#
# you shouldn't have to change this section, apart from if you want to do sensitivity tests on the forcing
#
# the reference datetime used in setting up the croco simulations (you shouldn't have to ever change this, unless we reconfigure it in the croco preprocessing)
croco_ref_time = datetime(2000,1,1)
#
# the directories in which the croco files are stored
# this is an array of dir names to allow for the inclusion of multiple croco runs
# The order is important - preference will be given to those which appear first in the array
# When run as a docker image we use "-v /home/runner/somisana/:/tmp/" so everything in 
# /home/runner/somisana/ on the server is mounted to /tmp/ in the docker container running the image
croco_dirs = ['/tmp/algoa-bay-forecast/']
#
# the directory where the global data downloaded for our eez are sitting
eez_data_dir = '/tmp/global_data/'

# ------------------
# numerical settings
# ------------------
#
# run duration in days
# limit this automatically to avoid run crash at the end of the available model data
run_dur = 10
run_time_max = datetime.strptime(croco_run_date, '%Y%m%d')+timedelta(days=5)
run_dur_max = (run_time_max - spill_start_time).total_seconds()/86400
run_dur=min(run_dur,run_dur_max)
#
# number of particles to release
# generally the more the better, but there are computational limits
# the more particles, the smoother the result will be
# you can calculate the volume of oil per particle upon release as oil_volume/num_part
num_part=5000
#
# opendrift timestep for particle integration in minutes
time_step=15
#
# output timestep in minutes
time_step_output=60
#
# constant horizontal diffusivity (m2/s)
# this is applied to the random walk component of the particle motion
hz_diff = 1
#
# wind drift factor
# fraction of the 10 m wind speed used to advect surface particles
wind_drift_factor=0.03

# -------------
# grdding info
# -------------
#
# placeholder for now - we can have options for gridding the output here 
# e.g. what grid size to use, what spatial extent

# --------------
# plotting info
# --------------
plot_extents=[23,26,-35,-33.6] # [lon1,lon2,lat1,lat2]
figsize=(8,4) # resize as needed to match the shape of extents below
time_x=0.1 # placement of time label, in axes coordinates
time_y=0.9
vmin=-50   # the z variable is animated so this is your max depth
cmap='Spectral_r' #'Spectral_r' 
plot_cbar=True #True
cbar_loc=(0.9, 0.15, 0.01, 0.7)
croco_dirs_plot=None # croco_dirs
