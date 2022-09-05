;

with bounds as (
  select
    ST_MakeEnvelope (2762959.282145573, -4143697.8371514757, 3090976.049526693, -3905044.8816447025, 3857) as geom_clip,
    ST_MakeEnvelope (2762959.282145573, -4143697.8371514757, 3090976.049526693, -3905044.8816447025, 3857) as geom_query
),
points as (
  select distinct
    c.id,
    coord xy
  from
    coordinates c
    join
  values
    v on v.coordinateid = c.id
      and v.modelid = c.modelid
      and v.depth_level = 20
      and v.time_step = 1
  where
    c.modelid = 1
),
mvtgeom as (
  select
    "id",
    ST_AsMVTGeom (p.xy, bounds.geom_clip, 4096, 256, true) as "xy"
from
  points p,
  bounds
  where
    ST_Intersects (p.xy, bounds.geom_query)
  limit 50000
)
select
  ST_AsMVT (mvtgeom, 'coordinates', 4096, 'xy', 'id')
from
  mvtgeom
