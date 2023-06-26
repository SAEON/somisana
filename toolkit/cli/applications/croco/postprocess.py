import numpy as np
from datetime import timedelta
import xarray as xr
from datetime import timedelta, datetime

def hour_rounder(t):
    """
    Rounds to nearest hour by adding a timedelta hour if minute >= 30
    """
    return t.replace(second=0, microsecond=0, minute=0, hour=t.hour) + timedelta(
        hours=t.minute // 30
    )

def u2rho(u):
    """
    regrid the croco u-velocity from it's native u grid to the rho grid
    u can be 2D, 3D or 4D
    """
    Num_dims=len(u.shape)
    if Num_dims==4:
        # T: Time 
        # D: Depth
        # Mp: Grid y
        # L:  Grid x
        [T, D, Mp, L] = u.shape

        # The u grid is length - 1 compared to rho grid
        # Because u values represent mid points between the rho grid
        # Create a new grid for interpolated u values that is equivalent to the rho grid
        u_rho = np.zeros((T, D, Mp, L + 1))
        
        # Interpolate from u grid to rho grid by summing adjacent u points, and divide by 2
        u_rho[:, :, :, 1 : L] = 0.5 * np.squeeze(
            [u[:, :, :, 0 : L - 1] + u[:, :, :, 1 : L]]
        )

        # On the edges of the new u grid, you can't interpolate values.
        # So just copy the closest values for the cells on the edge of the grid
        u_rho[:, :, :, 0] = u_rho[:, :, :, 1]
        u_rho[:, :, :, L] = u_rho[:, :, :, L - 1]
        
    elif Num_dims==3:
        # TorD: Temperature or depth
        [TorD, Mp, L] = u.shape # works if first dimension is time or depth
        u_rho = np.zeros((TorD, Mp, L + 1))
        u_rho[:, :, 1 : L] = 0.5 * np.squeeze(
            [u[:, :, 0 : L - 1] + u[ :, :, 1 : L]]
        )
        u_rho[:, :, 0] = u_rho[:, :, 1]
        u_rho[:, :, L] = u_rho[:, :, L - 1]
        
    else: # Num_dims==2:
        # 2D grid - no time/depth information (possibly a surface level at a single time step)
        [Mp, L] = u.shape
        u_rho = np.zeros((Mp, L + 1))
        u_rho[:, 1 : L] = 0.5 * np.squeeze(
            [u[:, 0 : L - 1] + u[ :, 1 : L]]
        )
        u_rho[:, 0] = u_rho[:, 1]
        u_rho[:, L] = u_rho[:, L - 1]
        
    return u_rho

def v2rho(v):
    """
    regrid the croco v-velocity from it's native v grid to the rho grid
    v can be 2D, 3D or 4D

    Refer to u2rho for helpful descriptions and comments
    """
    Num_dims=len(v.shape)
    if Num_dims==4:
        [T, D, M, Lp] = v.shape
        v_rho = np.zeros((T, D, M + 1, Lp))

        v_rho[:, :, 1 : M, :] = 0.5 * np.squeeze(
            [v[:, :, 0 : M - 1, :] + v[:, :, 1 : M, :]]
        )
        v_rho[:, :, 0, :] = v_rho[:, :, 1, :]
        v_rho[:, :, M, :] = v_rho[:, :, M - 1, :]
        
    elif Num_dims==3:
        [TorD, M, Lp] = v.shape # works if first dimension is time or depth
        v_rho = np.zeros((TorD, M + 1, Lp))

        v_rho[:, 1 : M, :] = 0.5 * np.squeeze(
            [v[:, 0 : M - 1, :] + v[:, 1 : M, :]]
        )
        v_rho[:, 0, :] = v_rho[:, 1, :]
        v_rho[:, M, :] = v_rho[:, M - 1, :]

        
    else: # Num_dims==2:
        [M, Lp] = v.shape
        v_rho = np.zeros((M + 1, Lp))

        v_rho[1 : M, :] = 0.5 * np.squeeze(
            [v[0 : M - 1, :] + v[1 : M, :]]
        )
        v_rho[0, :] = v_rho[1, :]
        v_rho[M, :] = v_rho[M - 1, :]
        
    return v_rho


def csf(sc, theta_s, theta_b):
    """
    Allows use of theta_b > 0 (July 2009)
    is required in zlevs.py
    """
    one64 = np.float64(1)

    if theta_s > 0.0:
        csrf = (one64 - np.cosh(theta_s * sc)) / (np.cosh(theta_s) - one64)
    else:
        csrf = -(sc**2)
    sc1 = csrf + one64
    if theta_b > 0.0:
        Cs = (np.exp(theta_b * sc1) - one64) / (np.exp(theta_b) - one64) - one64
    else:
        Cs = csrf

    return Cs


def z_levels(h, zeta, theta_s, theta_b, hc, N, type, vtransform):
    """
    this provides a 3D grid of the depths of the sigma levels
    h = 2D bathymetry of your grid
    zeta = zeta at particular timestep that you are interested in
    theta_s = surface stretching parameter
    theta_b = bottom stretching parameter
    hc = critical depth
    N = number of sigma levels
    type = 'w' or 'rho'
    vtransform = 1 (OLD) or 2 (NEW)

    this is adapted (by J.Veitch - Feb 2022) from zlevs.m in roms_tools (by P. Penven)
    """

    [M, L] = np.shape(h)

    sc_r = np.zeros((N, 1))
    Cs_r = np.zeros((N, 1))
    sc_w = np.zeros((N + 1, 1))
    Cs_w = np.zeros((N + 1, 1))

    if vtransform == 2:
        ds = 1 / N

        if type == "w":
            sc_r[0, 0] = -1.0
            sc_w[N, 0] = 0
            Cs_w[0, 0] = -1.0
            Cs_w[N, 0] = 0

            sc_w[1:-1, 0] = ds * (np.arange(1, N, 1) - N)

            Cs_w = csf(sc_w, theta_s, theta_b)
            N = N + 1
        else:
            sc = ds * (np.arange(1, N + 1, 1) - N - 0.5)
            Cs_r = csf(sc, theta_s, theta_b)
            sc_r = sc

    else:
        cff1 = 1.0 / np.sinh(theta_s)
        cff2 = 0.5 / np.tanh(0.5 * theta_s)

        if type == "w":
            sc = (np.arange(0, N + 1, 1) - N) / N
            N = N + 1
        else:
            sc = (np.arange(1, N + 1, 1) - N - 0.5) / N

        Cs = (1.0 - theta_b) * cff1 * np.sinh(theta_s * sc) + theta_b * (
            cff2 * np.tanh(theta_s * (sc + 0.5)) - 0.5
        )

    z = np.empty((int(N),) + h.shape, dtype=np.float64)

    h[h == 0] = 1e-2
    Dcrit = 0.01
    zeta[zeta < (Dcrit - h)] = Dcrit - h[zeta < (Dcrit - h)]
    hinv = 1 / h

    z = np.zeros((N, M, L))

    if vtransform == 2:
        if type == "w":
            cff1 = Cs_w
            cff2 = sc_w + 1
            sc = sc_w
        else:
            cff1 = Cs_r
            cff2 = sc_r + 1
            sc = sc_r
        h2 = h + hc
        cff = hc * sc
        h2inv = 1 / h2

        for k in np.arange(N, dtype=int):
            z0 = cff[k] + cff1[k] * h
            z[k, :, :] = z0 * h / (h2) + zeta * (1.0 + z0 * h2inv)
    else:
        cff1 = Cs
        cff2 = sc + 1
        cff = hc * (sc - Cs)
        cff2 = sc + 1
        for k in np.arange(N, dtype=int):
            z0 = cff[k] + cff1[k] * h
            z[k, :, :] = z0 + zeta * (1.0 + z0 * hinv)

    return z.squeeze()


def hlev(var, z, depth):
    """
    this extracts a horizontal slice

    var = 3D extracted variable of interest (assuming mask is already nan - use get_var() method in this file)
    z = depths (in m) of sigma levels, also 3D array (use get_depths() method in this file)
    depth = the horizontal depth you want (should be negative)

    Adapted (by J.Veitch and G.Fearon) from vinterp.m in roms_tools (by P.Penven)
    """
    [N, Mp, Lp] = np.shape(z)

    a = z.copy()
    a[a >= depth] = 0
    a[a < depth] = 1
    
    # 2D variable containing the sigma level index directly above the constant depth level
    levs = np.sum(a, axis=0)
    # values of zero indicate the depth level is below our sigma levels so set to nan
    levs[levs==0] = np.nan
    # make levs the sigma level index directly below the constant depth level
    levs = levs -1

    vnew = np.zeros((Mp, Lp))
    vnew[np.isnan(levs)]=np.nan
    
    # looping through every horizontal grid point makes this slow
    # TODO: understand how the matlab croco_tools function does this without a loop
    for m in np.arange(Mp):
        for l in np.arange(Lp):
            
            if not np.isnan(levs[m,l]):
            
                ind1 = int(levs[m, l])
                ind2 = int(levs[m, l]) + 1
                
                if ind1 == N-1: # there is no level above to interpolate between
                    # so I'd rather use the surface layer than extrapolate
                    vnew[m, l] = var[ind1, m, l]
                else:
    
                    v1 = var[ind1, m, l]
                    v2 = var[ind2, m, l]
        
                    z1 = z[ind1, m, l]
                    z2 = z[ind2, m, l]
        
                    vnew[m, l] = ((v1 - v2) * depth + v2 * z1 - v1 * z2) / (z1 - z2)

    return vnew

def get_depths(fname,tstep=None):
    '''
        extract the depth levels (in metres, negative downward) of the sigma levels in a CROCO file
        fname = CROCO output file
        tstep = time step index to extract (integer starting at zero). If None, then all time-steps are extracted
    '''
    
    # get the surface and bottom levels
    ssh=get_var(fname,'zeta',tstep)
    h = get_var(fname,'h')
    
    with xr.open_dataset(fname) as ds:
    
        # get the variables used to calculate the sigma levels
        # CROCO uses these params to determine how to deform the grid
        s_rho = ds.s_rho.values  # Vertical levels
        theta_s = ds.theta_s
        theta_b = ds.theta_b
        hc = ds.hc.values
        N = np.shape(ds.s_rho)[0]
        type_coordinate = "rho"
        vtransform = (
            2 if ds.VertCoordType == "NEW" else 1 if ds.VertCoordType == "OLD" else -1
        )
        if vtransform == -1:
            raise Exception("Unexpected value for vtransform (" + vtransform + ")")
    
        if tstep:
            depth_rho = z_levels(
                h, ssh, theta_s, theta_b, hc, N, type_coordinate, vtransform
            )
        else:
            T,M,L = np.shape(ssh)
            depth_rho = np.zeros((T,N,M,L))
            for x in np.arange(T):
                depth_rho[x, ::] = z_levels(
                    h, ssh[x, :, :], theta_s, theta_b, hc, N, type_coordinate, vtransform
                )
    
    return depth_rho
    
def get_time(fname,ref_date):
    '''         
        ref_date = reference date for the croco run as a datetime object
    '''
    with xr.open_dataset(fname) as data:
        time = data.time.values

        time_dt = []
        for t in time:
            date_now = ref_date + timedelta(seconds=np.float64(t))
            # date_round = hour_rounder(date_now) # GF: I'd rather keep the croco dates as they are saved in the raw output
            time_dt.append(date_now)
        
        return time_dt

def get_lonlatmask(fname,type='r'):
    with xr.open_dataset(fname) as ds:
        lon = ds.lon_rho.values 
        lat = ds.lat_rho.values 
        mask = ds.mask_rho.values
    mask[np.where(mask == 0)] = np.nan
    [Mp,Lp]=mask.shape;
    
    # croco output files don't have lon_u,lat_u, mask_u written to them.
    # We could get these from the grid file but I'm rather computing them
    # from lon_rho, lat_rho and mask_rho for the convenience of not having to 
    # specify two input files in functions like get_var()
    
    if type=='u':
        #lon = ds_grid.lon_u.values 
        #lat = ds_grid.lat_u.values
        #mask = ds_grid.mask_u.values
        lon=0.5*(lon[:,0:Lp-1]+lon[:,1:Lp]);
        lat=0.5*(lat[:,0:Lp-1]+lat[:,1:Lp]);
        mask=mask[:,0:Lp-1]*mask[:,1:Lp];
        
    if type=='v':
        #lon = ds_grid.lon_v.values 
        #lat = ds_grid.lat_v.values
        #mask = ds_grid.mask_v.values
        lon=0.5*(lon[0:Mp-1,:]+lon[1:Mp,:]);
        lat=0.5*(lat[0:Mp-1,:]+lat[1:Mp,:]);
        mask=mask[0:Mp-1,:]*mask[1:Mp,:];
        
    return lon,lat,mask

def get_var(fname,var_str,tstep=None):
    '''
        extract a variable from a CROCO file
        fname = CROCO output file
        var_str = variable name (string) in the CROCO output file
        tstep = time step index to extract (integer starting at zero). If None, then all time-steps are extracted
    '''
    with xr.open_dataset(fname) as ds:
        if tstep:
            var = ds[var_str].values[tstep,::]
        else:
            var = ds[var_str].values
            
        lon,lat,mask=get_lonlatmask(fname,var_str) # var_str will define the mask type (u,v, or rho)
        
        # it looks like numpy is clever enough to use the 2D mask on a 3D or 4D variable
        # that's useful!
        var=var*mask
        
        return var

def get_uv(fname,tstep=None):
    '''
    extract u and v components from a CROCO output file, regrid onto the 
    rho grid and rotate from grid-aligned to east-north components
    
    fname = CROCO output file
    tstep = time step index to extract (starting at zero). If None, then all time-steps are extracted
    '''
    u=get_var(fname,'u',tstep)
    v=get_var(fname,'v',tstep)
    u=u2rho(u)
    v=v2rho(v)
    angle=get_var(fname, 'angle') # grid angle
    
    # Use the grid angle to rotate the vectors
    cos_a = np.cos(angle)
    sin_a = np.sin(angle)

    # Refer to https://en.wikipedia.org/wiki/Rotation_matrix
    # although 'angle' is 2D, numpy is clever enough for this to work even if u_rho and v_rho are 3D or 4D
    u_out = u*cos_a - v*sin_a
    v_out = v*cos_a + u*sin_a
    
    # Return east / north vector vector components instead of x / y components
    return u_out,v_out



def get_boundary(fname):
        '''
        Return lon,lat of perimeter around a CROCO grid (i.e. coordinates of bounding cells)
        '''
        lon_rho,lat_rho,_=get_lonlatmask(fname,type='r')
        lon = np.hstack((lon_rho[0:, 0], lon_rho[-1, 1:-1],
                         lon_rho[-1::-1, -1], lon_rho[0, -2::-1]))
        lat = np.hstack((lat_rho[0:, 0], lat_rho[-1, 1:-1],
                         lat_rho[-1::-1, -1], lat_rho[0, -2::-1]))
        return lon, lat