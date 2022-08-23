from pydoc import describe
import xarray as xr
import numpy as np
from datetime import timedelta, datetime
from cli.transform.depth_functions import z_levels

# All dates in the CROCO output are represented
# in seconds from 1 Jan 2000 (i.e. the reference date)
REFERENCE_DATE = datetime(2000, 1, 1, 0, 0, 0)

# Rounds to nearest hour by adding a timedelta hour if minute >= 30


def hour_rounder(t):
    return (t.replace(second=0, microsecond=0, minute=0, hour=t.hour) + timedelta(hours=t.minute//30))

# Converts the v current component to the correct (rho) grid


def v2rho_4d(var_v):
    [T, D, M, Lp] = var_v.shape
    var_rho = np.zeros((T, D, M+1, Lp))
    var_rho[:, :, 1:M-1, :] = 0.5 * \
        np.squeeze([var_v[:, :, 0:M-2, :]+var_v[:, :, 1:M-1, :]])
    var_rho[:, :, 0, :] = var_rho[:, :, 1, :]
    var_rho[:, :, M, :] = var_rho[:, :, M-1, :]
    return var_rho

# Converts the u current component to the correct (rho) grid


def u2rho_4d(var_u):
    [T, D, Mp, L] = var_u.shape
    var_rho = np.zeros((T, D, Mp, L+1))
    var_rho[:, :, :, 1:L-1] = 0.5 * \
        np.squeeze([var_u[:, :, :, 0:L-2]+var_u[:, :, :, 1:L-1]])
    var_rho[:, :, :, 0] = var_rho[:, :, :, 1]
    var_rho[:, :, :, L] = var_rho[:, :, :, L-1]
    return var_rho

# Model variables use the dimensions time (time from reference date),
# eta_rho (lat) and xi_rho (lon). We are changing eta_rho and xi_rho
# from grid points to real lat and lon data.


def transform(options, arguments):
    now = datetime.now()

    grid_input_path = options.grid_input_path
    nc_input_path = options.nc_input_path
    nc_output_path = options.nc_output_path
    zarr_output_path = options.zarr_output_path

    print('\n== Running Algoa Bay Forecast post-processing ==')
    print('nc-input-path', nc_input_path)
    print('grid-input-path', grid_input_path)
    print('nc-output-path', nc_output_path)
    print('zarr-output-path', zarr_output_path)

    data = xr.open_dataset(nc_input_path)
    data_grid = xr.open_dataset(grid_input_path)

    # Dimensions that need to be transformed
    time = data.time.values  # Time steps
    lon_rho = data.lon_rho.values  # Longitude (4326)
    lat_rho = data.lat_rho.values  # Latitude (4326)

    # Convert time to human readable
    time_steps = []
    for t in time:
        date_now = REFERENCE_DATE + timedelta(seconds=np.float64(t))
        date_round = hour_rounder(date_now)
        time_steps.append(date_round)
    print('\n-> Generated time steps', str(datetime.now() - now))

    # Variables used in the visualisations
    temperature = data.temp.values
    salt = data.salt.values
    ssh = data.zeta.values  # Sea-surface height
    u = data.u.values  # East-West velocity
    v = data.v.values  # North-South velocity
    h = data.h.values  # Bathymetry elevation model

    # Variables used to calculate depth levels
    # CROCO uses these params to determine how to deform the grid
    s_rho = data.s_rho.values  # Vertical levels
    theta_s = data.theta_s
    theta_b = data.theta_b

    # Variables used to calculate depth levels from grid (bathymetry)
    h = data_grid.h.values

    # Convert u and v current components to the rho grid (otherwise these values are on cell edges and not the center of the cells)
    # use the function u2rho_4d and v2rho_4d
    print('-> Normalizing u/v model output variables', str(datetime.now() - now))
    u_rho = u2rho_4d(u)
    v_rho = v2rho_4d(v)

    print('-> Masking 0 values (land) from variables', str(datetime.now() - now))
    temperature[np.where(temperature == 0)] = np.nan
    salt[np.where(salt == 0)] = np.nan
    u[np.where(u == 0)] = np.nan
    v[np.where(v == 0)] = np.nan
    

    # Variables hard coded set during model configuration
    # Relative to each model
    # Critical depth. Convergence of surface layers with bottom layers due to grid squeezing
    hc = data.hc.values
    N = np.shape(data.s_rho)[0]
    type_coordinate = 'rho'
    vtransform = 2 if data.VertCoordType == 'NEW' else 1 if data.VertCoordType == 'OLD' else -1

    if (vtransform == -1):
        raise Exception('Unexpected value for vtransform (' + vtransform + ')')

    # m_rho refers to the depth level in meters
    print('-> Converting depth levels to depth in meters', str(datetime.now() - now))
    m_rho = np.zeros(np.shape(temperature))
    for x in np.arange(np.size(temperature, 0)):
        depth_temp = z_levels(
            h, ssh[x, :, :], theta_s, theta_b, hc, N, type_coordinate, vtransform)
        m_rho[x, ::] = depth_temp

    # Create new xarray dataset with selected variables
    print('-> Generating dataset', str(datetime.now() - now))
    data_out = xr.Dataset(
        attrs=dict(
            description="CROCO output from algoa Bay model transformed lon/lat/depth/time"),
        data_vars=dict(
            temperature=xr.Variable(["time", "depth", "lat", "lon"], temperature, dict(
                long_name=data.temp.long_name, units=data.temp.units, description="Temperature at grid points")),
            salt=xr.Variable(["time", "depth", "lat", "lon"], salt, dict(
                long_name=data.salt.long_name, units=data.salt.units, description="Salinity at grid points")),
            u=xr.Variable(["time", "depth", "lat", "lon"], u_rho, dict(
                long_name=data.u.long_name, units=data.u.units, description="@MATT TODO at grid points")),
            v=xr.Variable(["time", "depth", "lat", "lon"], v_rho, dict(
                long_name=data.v.long_name, units=data.v.units, description="@MATT TODO at grid points")),
            m_rho=xr.Variable(["time", "depth", "lat", "lon"], m_rho, dict(
                description="Depth level of grid points in meters, centred in grid cells")),
            h=xr.Variable(['lat', 'lon'], h, dict(long_name=data.h.long_name,
                          units=data.h.units, description="Bathymetry elevation at grid XY points"))
        ),
        coords=dict(
            lon_rho=xr.Variable(["lat", "lon"], lon_rho, dict(long_name=data.lon_rho.long_name,
                                units=data.lon_rho.units, description="Longitude coordinate values of curvilinear grid cells")),
            lat_rho=xr.Variable(["lat", "lon"], lat_rho, dict(long_name=data.lat_rho.long_name,
                                units=data.lat_rho.units, description="Latitude coordinate values of curvilinear grid cells")),
            depth=xr.Variable(['depth'], s_rho, dict(description="Depth levels (grid levels)")),
            time=xr.Variable(['time'], time_steps, dict(description="Time steps in hours - TODO improve this description")),
        ),
    )

    print('-> outputting NetCDF', str(datetime.now() - now))
    data_out.to_netcdf(nc_output_path, encoding={
        'temperature': {},
        'salt': {},
        'u': {},
        'v': {},
        'm_rho': {},
        'lon_rho': {},
        'lat_rho': {},
        'depth': {},
        'time': {'dtype': 'i4'}
    })

    print('-> outputting Zarr', str(datetime.now() - now))
    data_out.to_zarr(zarr_output_path, mode='w')

    print('\nComplete! If you don\'t see this message there was a problem')
