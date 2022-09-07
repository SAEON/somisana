;

create extension if not exists postgis;

create extension if not exists postgis_raster;

create extension if not exists postgis_topology;

create extension if not exists postgis_sfcgal;

create extension if not exists fuzzystrmatch;

create extension if not exists address_standardizer;

create extension if not exists address_standardizer_data_us;

create extension if not exists postgis_tiger_geocoder;

create table if not exists public.rasters (
  rid int primary key generated always as identity,
  rast public.raster null,
  filename text null
);

create index if not exists rasters_rast_st_convexhull_idx on public.rasters using gist (ST_ConvexHull (rast));

create table if not exists public.models (
  id smallint primary key generated always as identity,
  name varchar(255) not null unique
);

create table if not exists public.model_runs (
  id smallint primary key generated always as identity,
  run_date date unique not null
);

create index if not exists model_runs_date on public.model_runs using btree (run_date asc);

merge into public.models t
using (
  select
    'algoa-bay-forecast' name
  union
    select
      'false-bay-forecast' name) s on s.name = t.name
when not matched then
  insert (name)
    values (s.name);

create table if not exists public.raster_xref_model (
  id int primary key generated always as identity,
  rasterid int not null unique references rasters (rid) on delete cascade,
  modelid smallint not null references models (id) on delete cascade,
  runid smallint not null references model_runs (id) on delete cascade
);

create index if not exists raster_xref_model_index_modelid on public.raster_xref_model using btree (modelid);

create index if not exists raster_xref_model_index_rasterid on public.raster_xref_model using btree (rasterid);

create table if not exists public.coordinates (
  id int primary key generated always as identity,
  modelid smallint not null references models (id) on delete cascade,
  pixel geometry(point, 0) not null,
  coord geometry(point, 3857) not null,
  longitude float not null,
  latitude float not null,
  bathymetry decimal(7, 2) not null,
  constraint unique_coordinates unique (modelid, pixel)
);

create index if not exists coordinates_modelid on public.coordinates using btree (modelid);

create index if not exists coordinates_pixel on public.coordinates using gist (pixel);

create index if not exists coordinates_coord on public.coordinates using gist (coord);

create table if not exists public.values (
  id bigint primary key generated always as identity,
  modelid smallint not null references public.models (id) on delete cascade,
  runid smallint not null references public.model_runs (id) on delete cascade,
  depth_level smallint not null,
  time_step smallint not null,
  coordinateid int not null references public.coordinates (id) on delete cascade,
  depth decimal(7, 2),
  temperature decimal(4, 2),
  salinity decimal(6, 4),
  u decimal(5, 4),
  v decimal(5, 4)
);

create index if not exists values_composite_key on public.values using brin (modelid, runid, depth_level, time_step, coordinateid, depth);


/**
 * VIEWS
 */
drop view if exists public.metadata;

create view public.metadata as
select
  modelid id,
  name,
  min_x,
  max_x,
  min_y,
  max_y,
  st_convexhull (coords)::geometry(Polygon, 3857) convexhull,
  (st_makeenvelope (min_x, min_y, max_x, max_y, 4326))::geometry(Polygon, 4326) envelope
from (
  select
    c.modelid,
    m."name",
    min(c.longitude) min_x,
    max(c.longitude) max_x,
    max(c.latitude) max_y,
    min(c.latitude) min_y,
    st_collect (coord) coords
  from
    coordinates c
    join models m on m.id = c.modelid
  group by
    modelid,
    name) t;


/**
 * FUNCTIONS
 */
drop function if exists public.somisana_get_values cascade;

create function public.somisana_get_values (modelid smallint, runid smallint, depth_level smallint, time_step smallint, variable text)
  returns table (
    pixel geometry,
    value numeric
  )
  as $$
declare
  band_no int;
  m smallint;
  rd smallint;
begin
  band_no := ((time_step - 1) * 20) + depth_level;
  m := modelid;
  rd := runid;
  return query
  select
    t.geom pixel,
    t.val::numeric value
  from (
    select
      r.rid,
      rxm.modelid,
      (ST_PixelAsCentroids (r.rast, band_no)).*
    from
      rasters r
      join raster_xref_model rxm on rxm.rasterid = r.rid
    where
      filename like ('%:' || variable)
      and rxm.modelid = m
      and rxm.runid = rd) t
order by
  t.geom asc;
end;
$$
language 'plpgsql';

drop function if exists public.somisana_join_values cascade;

create function public.somisana_join_values (modelid smallint, runid smallint, depth_level smallint, time_step smallint)
  returns table (
    coordinateid int,
    depth decimal(7, 2),
    temperature decimal(4, 2),
    salinity decimal(6, 4),
    u decimal(5, 4),
    v decimal(5, 4)
  )
  as $$
declare
  m smallint;
begin
  m := modelid;
  return query with depths as (
    select
      pixel,
      value
    from
      public.somisana_get_values (modelid, runid, depth_level, time_step, variable => 'm_rho')
),
temperatures as (
  select
    pixel,
    value
  from
    public.somisana_get_values (modelid, runid, depth_level, time_step, variable => 'temperature')
),
salinity as (
  select
    pixel,
    value
  from
    public.somisana_get_values (modelid, runid, depth_level, time_step, variable => 'salt')
),
u as (
  select
    pixel,
    value
  from
    public.somisana_get_values (modelid, runid, depth_level, time_step, variable => 'u')
),
v as (
  select
    pixel,
    value
  from
    public.somisana_get_values (modelid, runid, depth_level, time_step, variable => 'v'))
select
  c.id coordinateid,
  d.value depth,
  t.value temperature,
  s.value salinity,
  u.value u,
  v.value v
from
  depths d
  join temperatures t on t.pixel = d.pixel
  join salinity s on s.pixel = d.pixel
  join u on u.pixel = d.pixel
  join v on v.pixel = d.pixel
  join coordinates c on c.modelid = m
    and c.pixel = d.pixel;
end;
$$
language 'plpgsql';

drop function if exists public.somisana_upsert_values cascade;

create function public.somisana_upsert_values (modelid smallint, run_id smallint, depth_level smallint, time_step smallint)
  returns void
  as $$
begin
  merge into public.values t
  using (
    select
      modelid, depth_level, time_step, run_id runid, coordinateid, depth, temperature, salinity, u, v
    from
      somisana_join_values (modelid, run_id, depth_level, time_step)) s on
        s.modelid = t.modelid
        and s.runid = t.runid
        and s.depth_level = t.depth_level
        and s.time_step = t.time_step
        and s.coordinateid = t.coordinateid
  when not matched then
    insert (modelid, depth_level, time_step, runid, coordinateid, depth, temperature, salinity, u, v)
      values (s.modelid, s.depth_level, s.time_step, s.runid, s.coordinateid, s.depth, s.temperature, s.salinity, s.u, s.v)
      when matched then
        update set
          runid = s.runid, coordinateid = s.coordinateid, depth = s.depth, temperature = s.temperature, salinity = s.salinity, u = s.u, v = s.v;
end;
$$
language 'plpgsql';

drop function if exists public.somisana_model_coordinates cascade;

create function public.somisana_model_coordinates (z integer, x integer, y integer, mid integer default 1)
  returns bytea
  as $$
declare
  result bytea;
begin
  with bounds as (
    select
      ST_TileEnvelope (z, x, y) geom_clip
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
      and v.modelid = mid
      and v.depth_level = 20
      and v.time_step = 1
  where
    c.modelid = mid
),
mvtgeom as (
  select
    id,
    ST_AsMVTGeom (p.xy, bounds.geom_clip, 4096, 256, true) as xy
  from
    points p,
    bounds
  where
    ST_Intersects (p.xy, bounds.geom_clip)
  limit 50000
)
select
  ST_AsMVT (mvtgeom, 'default', 4096, 'xy', 'id') into result
from
  mvtgeom;
  return result;
end;
$$
language 'plpgsql'
stable PARALLEL SAFE;

