with temperature as (
  select
    x,
    y,
    geom pixel,
    val temperature,
    extent
  from
    (
      select
        distinct rid,
        st_metadata(rast) extent,
        (ST_PixelAsCentroids(rast, 1)).*
      from
        rasters
      where
        filename like '%%temperature'
    ) t
)

select * from temperature