/**
 * The grid is split into many tiles
 *  => "x|y" is a coordinate in a tile
 *  => "pixel" is a coordinate in the grid
 *
 * The coordinates don't change between days
 */
;

drop materialized view if exists coordinates;

create materialized view coordinates as with longitudes as (
  select
    x,
    y,
    geom pixel,
    val longitude
  from
    (
      select
        distinct (regexp_match(filename, '[^:]*$')) [1] variable,
        (ST_PixelAsCentroids(rast, 1)).*
      from
        algoa_bay_forecast
      where
        filename like '%lon%'
    ) lon
),
latitudes as (
  select
    x,
    y,
    geom pixel,
    val latitude
  from
    (
      select
        distinct (regexp_match(filename, '[^:]*$')) [1] variable,
        (ST_PixelAsCentroids(rast, 1)).*
      from
        algoa_bay_forecast
      where
        filename like '%lat%'
    ) lon
)
select
  lng.x,
  lng.y,
  lng.pixel,
  lng.longitude,
  lat.latitude,
  st_point(lng.longitude, lat.latitude, 4326) coord
from
  longitudes lng
  join latitudes lat on lat.pixel = lng.pixel