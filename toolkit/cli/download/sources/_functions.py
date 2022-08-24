def yyyymmdd(dt):
  return dt.strftime("%Y") \
    + dt.strftime("%m") \
    + dt.strftime("%d")