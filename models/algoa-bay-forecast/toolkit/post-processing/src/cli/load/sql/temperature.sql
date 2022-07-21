/**
 * The grid is split into many tiles
 *  => "x|y" is a coordinate in a tile
 *  => "pixel" is a coordinate in the grid
 *  => "extent" identifies the tile 
 */
;

with longitudes as (
  select
    x,
    y,
    geom pixel,
    val longitude,
    extent
  from
    (
      select
        distinct rid,
        (regexp_match(filename, '[^:]*$')) [1] variable,
        st_metadata(rast) extent,
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
    val latitude,
    extent
  from
    (
      select
        distinct rid,
        (regexp_match(filename, '[^:]*$')) [1] variable,
        st_metadata(rast) extent,
        (ST_PixelAsCentroids(rast, 1)).*
      from
        algoa_bay_forecast
      where
        filename like '%lat%'
    ) lon
),
temperature as (
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
        (regexp_match(filename, '[^:]*$')) [1] variable,
        st_metadata(rast) extent,
        (ST_PixelAsCentroids(rast, 1)).*
      from
        algoa_bay_forecast
      where
        filename like '%temperature%'
    ) temp
)
select
  lng.extent,
  lng.x,
  lng.y,
  lng.pixel,
  lng.longitude,
  lat.latitude,
  temp.temperature,
  st_point(lng.longitude, lat.latitude, 4326) coord
from
  longitudes lng
  join latitudes lat on lat.pixel = lng.pixel
  join temperature temp on temp.pixel = lng.pixel