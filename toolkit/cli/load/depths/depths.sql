with depths as (
  select
    geom pixel,
    val depth,
    modelid,
    b
  from
    (
      select
      	rxm.modelid,
      	rid,
      	st_numbands(rast) b,
        (ST_PixelAsCentroids(rast, 4800)).*
      from
        rasters r
        join raster_xref_model rxm on rxm.rasterid = r.rid 
      where
        filename like '%m_rho%'
    ) temp
)

select
c.id coordinateId,
c.coord,
d.*
from depths d
join coordinates c on c.pixel = d.pixel and c.modelid = d.modelid

order by d.depth asc

limit 100
