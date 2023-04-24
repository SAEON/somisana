from datetime import timedelta
import numpy as np

"""
Rounds to nearest hour by adding a timedelta hour if minute >= 30
"""


def hour_rounder(t):
    return t.replace(second=0, microsecond=0, minute=0, hour=t.hour) + timedelta(
        hours=t.minute // 30
    )


"""
Converts the v current component to the correct (rho) grid
"""


def v2rho_4d(var_v):
    [T, D, M, Lp] = var_v.shape
    var_rho = np.zeros((T, D, M + 1, Lp))
    var_rho[:, :, 1 : M - 1, :] = 0.5 * np.squeeze(
        [var_v[:, :, 0 : M - 2, :] + var_v[:, :, 1 : M - 1, :]]
    )
    var_rho[:, :, 0, :] = var_rho[:, :, 1, :]
    var_rho[:, :, M, :] = var_rho[:, :, M - 1, :]
    return var_rho


"""
Converts the u current component to the correct (rho) grid
"""


def u2rho_4d(var_u):
    [T, D, Mp, L] = var_u.shape
    var_rho = np.zeros((T, D, Mp, L + 1))
    var_rho[:, :, :, 1 : L - 1] = 0.5 * np.squeeze(
        [var_u[:, :, :, 0 : L - 2] + var_u[:, :, :, 1 : L - 1]]
    )
    var_rho[:, :, :, 0] = var_rho[:, :, :, 1]
    var_rho[:, :, :, L] = var_rho[:, :, :, L - 1]
    return var_rho
