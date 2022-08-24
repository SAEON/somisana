def yyyymmdd(dt):
    return dt.strftime("%Y") \
        + dt.strftime("%m") \
        + dt.strftime("%d")


def time_param(dt):
    return yyyymmdd(dt) \
        + '/' \
        + dt.strftime("%H") \
        + '/atmos'
