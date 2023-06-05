import numpy as np
from datetime import timedelta



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
        [T, D, Mp, L] = u.shape
        u_rho = np.zeros((T, D, Mp, L + 1))
        u_rho[:, :, :, 1 : L - 1] = 0.5 * np.squeeze(
            [u[:, :, :, 0 : L - 2] + u[:, :, :, 1 : L - 1]]
        )
        u_rho[:, :, :, 0] = u_rho[:, :, :, 1]
        u_rho[:, :, :, L] = u_rho[:, :, :, L - 1]
        
    elif Num_dims==3:
        [TorD, Mp, L] = u.shape # works if first dimension is time or depth
        u_rho = np.zeros((TorD, Mp, L + 1))
        u_rho[:, :, 1 : L - 1] = 0.5 * np.squeeze(
            [u[:, :, 0 : L - 2] + u[ :, :, 1 : L - 1]]
        )
        u_rho[:, :, 0] = u_rho[:, :, 1]
        u_rho[:, :, L] = u_rho[:, :, L - 1]
        
    elif Num_dims==2:
        [Mp, L] = u.shape
        u_rho = np.zeros((Mp, L + 1))
        u_rho[:, 1 : L - 1] = 0.5 * np.squeeze(
            [u[:, 0 : L - 2] + u[ :, 1 : L - 1]]
        )
        u_rho[:, 0] = u_rho[:, 1]
        u_rho[:, L] = u_rho[:, L - 1]
        
    return u_rho

def v2rho(v):
    """
    regrid the croco v-velocity from it's native v grid to the rho grid
    v can be 2D, 3D or 4D

    """
    Num_dims=len(v.shape)
    if Num_dims==4:
        [T, D, M, Lp] = v.shape
        v_rho = np.zeros((T, D, M + 1, Lp))

        v_rho[:, :, 1 : M - 1, :] = 0.5 * np.squeeze(
            [v[:, :, 0 : M - 2, :] + v[:, :, 1 : M - 1, :]]
        )
        v_rho[:, :, 0, :] = v_rho[:, :, 1, :]
        v_rho[:, :, M, :] = v_rho[:, :, M - 1, :]
        
    elif Num_dims==3:
        [TorD, M, Lp] = v.shape # works if first dimension is time or depth
        v_rho = np.zeros((TorD, M + 1, Lp))

        v_rho[:, 1 : M - 1, :] = 0.5 * np.squeeze(
            [v[:, 0 : M - 2, :] + v[:, 1 : M - 1, :]]
        )
        v_rho[:, 0, :] = v_rho[:, 1, :]
        v_rho[:, M, :] = v_rho[:, M - 1, :]

        
    elif Num_dims==2:
        [M, Lp] = v.shape
        v_rho = np.zeros((M + 1, Lp))

        v_rho[1 : M - 1, :] = 0.5 * np.squeeze(
            [v[0 : M - 2, :] + v[1 : M - 1, :]]
        )
        v_rho[0, :] = v_rho[1, :]
        v_rho[M, :] = v_rho[M - 1, :]
        
    return v_rho

def uv2rho(u,v,angle):
    """
    regrid the croco u- and v-velocities from their native grids to the rho grid
    and rotate them from being grid-aligned to being eastward and northward components
    u and v can be 2D, 3D or 4D

    """
    u_rho=u2rho(u)
    v_rho=v2rho(v)
    
    # use the grid angle to rotate the vectors
    cosa = np.cos(angle);
    sina = np.sin(angle);
    u = u_rho*cosa - v_rho*sina;
    v = v_rho*cosa + u_rho*sina;
    
    return u,v    


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

    var = 3D extracted variable of interest
    z = depths (in m) of sigma levels, also 3D array (this is done using zlevs)
    depth = the horizontal depth you want (should be negative)

    Adapted (by J.Veitch) from vinterp.m in roms_tools (by P.Penven)
    """
    [N, Mp, Lp] = np.shape(z)

    a = z.copy()
    a[a < depth] = 1
    a[a != 1] = 0
    levs = np.sum(a, axis=0)
    levs[levs == N] = N - 1
    mask = levs / levs

    vnew = np.zeros((Mp, Lp))

    for m in np.arange(Mp):
        for l in np.arange(Lp):
            ind1 = levs[m, l]
            ind2 = levs[m, l] + 1

            v1 = var[int(ind1), m, l]
            v2 = var[int(ind2), m, l]

            z1 = z[int(ind1), m, l]
            z2 = z[int(ind2), m, l]

            vnew[m, l] = ((v1 - v2) * depth + v2 * z1 - v1 * z2) / (z1 - z2)

        vnew = vnew * mask

    return vnew
