create or replace function public.get_models (z integer, x integer, y integer, query_params json)
  returns bytea
  as $$
declare
  result bytea;
begin
  with bounds as (
    select
      ST_TileEnvelope (z, x, y) as geom
),
mvtgeom as (
  select
    ST_AsMVTGeom (ST_Transform (extent, 3857), bounds.geom) geom
  from
    metadata m,
    bounds
)
select
  ST_AsMVT (mvtgeom, 'default') into result
from
  mvtgeom;
  return result;
end;
$$
language 'plpgsql'
stable PARALLEL SAFE;

