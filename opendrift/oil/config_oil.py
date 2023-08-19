from datetime import datetime

# -------------------
# configuration name
# -------------------
#
# the model output will be written to a directory with this name
# which will be accessible via the somisana thredds or mnemosyne file server
config_name = 'test_01' 

# -----------
# spill info
# -----------
#
# coordinates of the spill (in geographical degrees)
lon_spill=27.987155 # 25.74
lat_spill=-33.300464  #-33.855
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
oil_type='GENERIC INTERMEDIATE FUEL OIL 180'
#
# start time of spill - use local time (UTC+2)
spill_start_time=datetime.now() # change to whenever the spill should be e.g. spill_start_time=datetime(2023,8,10,5,30,0)
#
# duration of the release of oil in hours
release_dur=6
#
# volume of oil spilled in m3
# This is not used directly in the model - it's only used here to get the oil flow rate below
# so you can also specify the 'oil_flow_rate' directly and comment 'oil_volume' if that is convenient 
oil_volume=500
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
# you shouldn't have to change this section, apart from the croco_run_date if you want to use something 
# other than the latest croco run, or if you want to do sensitivity tests on the forcing
#
# the croco run to be used 
# by default this will use the latest run
# but you can change it to specify a previous run by changing this e.g. croco_run_date=datetime(2023,8,10)
# note that only runs from the last 5 days are stored for running opendrift 
croco_run_date = datetime.now() 
#
# the reference datetime used in setting up the croco simulations (you shouldn't have to ever change this, unless we reconfigure it in the croco preprocessing)
croco_ref_time = datetime(2000,1,1)
#
# the directories in which the croco files are stored
# this is an array of dir names to allow for the inclusion of multiple croco runs
# The order is important - preference will be given to those which appear first in the array
croco_dirs = ['/tmp/algoa-bay/']
#
# the directory where the global data downloaded for our eez are sitting
eez_data_dir='/tmp/global-data/'
#
# the opendrift run directory
run_dir = '/tmp/run/'+croco_run_date.strftime("%Y%m%d")+'/'+config_name+'/'

# ------------------
# numerical settings
# ------------------
#
# run duration in days
# this should automatically have a limit based on 'croco_run_date' and 'spill_start_time'
run_dur=8
#
# number of particles to release
# generally the more the better, but there are computational limits
# the more particles, the smoother the result will be
# you can calculate the volume of oil per particle upon release as oil_volume/num_part
num_part=2000
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