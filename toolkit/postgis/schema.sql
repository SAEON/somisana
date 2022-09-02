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
  run_date date not null
);

create index if not exists raster_xref_model_index_modelid on public.raster_xref_model using btree (modelid);

create index if not exists raster_xref_model_index_rasterid on public.raster_xref_model using btree (rasterid);

create table if not exists public.coordinates (
  id int primary key generated always as identity,
  modelid smallint not null references models (id) on delete cascade,
  pixel geometry(point, 0) not null,
  coord geometry(point, 4326) not null,
  longitude float4 not null,
  latitude float4 not null,
  bathymetry float4 not null,
  constraint unique_coordinates unique (modelid, pixel)
);

create index if not exists coordinates_modelid on public.coordinates using btree (modelid);

create index if not exists coordinates_pixel on public.coordinates using btree (pixel asc);

create index if not exists coordinates_coord on public.coordinates using gist (coord);


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
  st_convexhull (coords)::geometry(Polygon, 4326) convexhull,
  st_makeenvelope (min_x, min_y, max_x, max_y, 4326)::geometry(Polygon, 4326) envelope
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

create table if not exists public.values (
  id bigint primary key generated always as identity,
  modelid smallint not null references public.models (id) on delete cascade,
  depth_level smallint not null,
  time_step smallint not null,
  step_timestamp timestamp without time zone not null,
  run_date date,
  coordinateid int not null references coordinates (id) on delete cascade,
  xy geometry(point, 3857) not null,
  depth float4,
  temperature float4,
  salinity float4,
  u float4,
  v float4
);

create index if not exists values_index_modelid on public.values using btree (modelid asc);

create index if not exists values_index_depth_level on public.values using btree (depth_level asc);

create index if not exists values_index_time_step on public.values using btree (time_step asc);

create index if not exists values_index_run_date on public.values using btree (run_date asc);

create index if not exists values_index_coordinateid on public.values using btree (coordinateid asc);

create index if not exists values_index_xy on public.values using gist (xy);

create index if not exists values_index_step_timestamp on public.values using brin (step_timestamp);


/**
 * FUNCTIONS
 */
drop function if exists public.get_values cascade;

create function public.get_values (modelid smallint, rundate date, depth_level smallint, time_step smallint, variable text)
  returns table (
    pixel geometry,
    value float4
  )
  as $$
declare
  band_no int;
  m smallint;
  rd date;
begin
  band_no := ((time_step - 1) * 20) + depth_level;
  m := modelid;
  rd := rundate;
  return query
  select
    t.geom pixel,
    t.val::float4 value
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
      and rxm.run_date = rd) t
order by
  t.geom asc;
end;
$$
language 'plpgsql';

drop function if exists public.join_values cascade;

create function public.join_values (modelid smallint, rundate date, depth_level smallint, time_step smallint)
  returns table (
    coordinateid int,
    xy geometry(point, 4326),
    depth float4,
    temperature float4,
    salinity float4,
    u float4,
    v float4
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
      public.get_values (modelid, rundate, depth_level, time_step, variable => 'm_rho')
),
temperatures as (
  select
    pixel,
    value
  from
    public.get_values (modelid, rundate, depth_level, time_step, variable => 'temperature')
),
salinity as (
  select
    pixel,
    value
  from
    public.get_values (modelid, rundate, depth_level, time_step, variable => 'salt')
),
u as (
  select
    pixel,
    value
  from
    public.get_values (modelid, rundate, depth_level, time_step, variable => 'u')
),
v as (
  select
    pixel,
    value
  from
    public.get_values (modelid, rundate, depth_level, time_step, variable => 'v'))
select
  c.id coordinateid,
  c.coord xy,
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

drop function if exists public.upsert_values cascade;

create function public.upsert_values (modelid smallint, rundate date, depth_level smallint, time_step smallint, actual_time timestamp)
  returns void
  as $$
begin
  merge into public.values t
  using (
    select
      modelid, depth_level, time_step, actual_time step_timestamp, rundate run_date, coordinateid, xy, depth, temperature, salinity, u, v
    from
      join_values (modelid, rundate, depth_level, time_step)) s on s.modelid = t.modelid
    and s.depth_level = t.depth_level
    and s.time_step = t.time_step
    and s.run_date = t.run_date
    and s.coordinateid = t.coordinateid
  when not matched then
    insert (modelid, depth_level, time_step, step_timestamp, run_date, coordinateid, xy, depth, temperature, salinity, u, v)
      values (s.modelid, s.depth_level, s.time_step, s.step_timestamp, s.run_date, s.coordinateid, st_transform (s.xy, 3857), s.depth, s.temperature, s.salinity, s.u, s.v)
      when matched then
        update set
          step_timestamp = s.step_timestamp, run_date = s.run_date, coordinateid = s.coordinateid, xy = st_transform (s.xy, 3857), depth = s.depth, temperature = s.temperature, salinity = s.salinity, u = s.u, v = s.v;
end;
$$
language 'plpgsql';

