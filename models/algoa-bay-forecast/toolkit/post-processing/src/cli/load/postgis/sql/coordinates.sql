/**
 * The grid is split into many tiles
 *  => "x|y" is a coordinate in a tile
 *  => "pixel" is a coordinate in the grid
 *
 * The coordinates don't change between days
 */
drop materialized view if exists coordinates;

create materialized view coordinates as with lon as (
  select
    m.id modelId,
    variable,
    geom pixel,
    val longitude
  from
    (
      select
        distinct (regexp_match(filename, '.*?(?=-\d)')) [1] model,
        (regexp_match(filename, '[^:]*$')) [1] variable,
        (ST_PixelAsCentroids(rast, 1)).*
      from
        rasters
      where
        filename like '%lon_rho'
    ) lon
    join models m on m.name = lon.model
),
lat as (
  select
    m.id modelId,
    variable,
    geom pixel,
    val latitude
  from
    (
      select
        distinct (regexp_match(filename, '.*?(?=-\d)')) [1] model,
        (regexp_match(filename, '[^:]*$')) [1] variable,
        (ST_PixelAsCentroids(rast, 1)).*
      from
        rasters
      where
        filename like '%lat_rho'
    ) lat
    join models m on m.name = lat.model
)
select
  lon.modelId,
  lon.pixel,
  lon.longitude,
  lat.latitude,
  st_point(lon.longitude, lat.latitude, 4326) coord
from
  lon
  join lat on lat.pixel = lon.pixel
  and lat.modelId = lon.modelId