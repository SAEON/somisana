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
  rid serial not null primary key,
  rast public.raster null,
  filename text null
);

create index if not exists rasters_rast_st_convexhull_idx on public.rasters using gist (ST_ConvexHull (rast));

create table if not exists public.models (
  id serial not null primary key,
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
  id serial not null primary key,
  rasterid int not null unique references rasters (rid) on delete cascade,
  modelid int not null references models (id) on delete cascade,
  run_date date not null
);

create table if not exists public.coordinates (
  id serial not null primary key,
  modelid int not null references models (id) on delete cascade,
  lon_rasterid int not null references rasters (rid) on delete cascade,
  lat_rasterid int not null references rasters (rid) on delete cascade,
  pixel geometry(point, 0) not null,
  coord geometry(point, 4326) not null,
  longitude float not null,
  latitude float not null,
  bathymetry float not null,
  constraint unique_coordinates unique (modelid, pixel)
);


/**
 * VIEWS
 */
drop view if exists raster_grid;

create view raster_grid as
with polys as (
  select
    modelid,
    st_envelope (st_collect (coord)) grid_envelope,
    st_convexhull (st_collect (coord)) grid_convex_hull
  from
    coordinates c
  group by
    modelid,
    lon_rasterid,
    lat_rasterid
)
select
  modelid,
  grid_envelope::geometry(Polygon, 4326),
  grid_convex_hull::geometry(Polygon, 4326)
from
  polys
where
  st_geometrytype (grid_envelope) = 'ST_Polygon'
  and st_geometrytype (grid_convex_hull) = 'ST_Polygon';

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
  id serial primary key,
  modelid int not null references public.models (id) on delete cascade,
  depth_level int not null,
  time_step int not null,
  run_date date,
  coordinateid int not null references coordinates (id) on delete cascade,
  xyz geometry(PointZ, 4326) not null,
  depth float,
  temperature float,
  salinity float,
  u float,
  v float
);


/**
 * FUNCTIONS
 */
drop function if exists public.get_values cascade;

create function public.get_values (modelid int, rundate date, depth_level int, time_step int, variable text)
  returns table (
    pixel geometry,
    value float
  )
  as $$
declare
  band_no int;
  m int;
  rd date;
begin
  band_no := ((time_step - 1) * 20) + depth_level;
  m := modelid;
  rd := rundate;
  return query
  select
    t.geom pixel,
    t.val value
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
      and rxm.run_date = rd) t;
end;
$$
language 'plpgsql';

drop function if exists public.join_values cascade;

create function public.join_values (modelid int, rundate date, depth_level int, time_step int)
  returns table (
    coordinateid int,
    xyz geometry(point, 4326),
    depth float,
    temperature float,
    salinity float,
    u float,
    v float
  )
  as $$
begin
  return query with depths as (
    select
      modelid,
      depth_level,
      time_step,
      pixel,
      value
    from
      public.get_values (modelid, rundate, depth_level, time_step, variable => 'm_rho')
),
temperatures as (
  select
    modelid,
    depth_level,
    time_step,
    pixel,
    value
  from
    public.get_values (modelid, rundate, depth_level, time_step, variable => 'temperature')
),
salinity as (
  select
    modelid,
    depth_level,
    time_step,
    pixel,
    value
  from
    public.get_values (modelid, rundate, depth_level, time_step, variable => 'salt')
),
u as (
  select
    modelid,
    depth_level,
    time_step,
    pixel,
    value
  from
    public.get_values (modelid, rundate, depth_level, time_step, variable => 'u')
),
v as (
  select
    modelid,
    depth_level,
    time_step,
    pixel,
    value
  from
    public.get_values (modelid, rundate, depth_level, time_step, variable => 'v'))
select
  c.id coordinateid,
  st_makepoint (c.longitude, c.latitude, d.value * 35)::geometry(PointZ, 4326) xyz,
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
  join coordinates c on c.modelid = d.modelid
    and c.pixel = d.pixel;
end;
$$
language 'plpgsql';

drop function if exists public.upsert_values cascade;

create function public.upsert_values (modelid int, rundate date, depth_level int, time_step int)
  returns void
  as $$
begin
  merge into public.values t
  using (
    select
      modelid, depth_level, time_step, rundate run_date, coordinateid, xyz, depth, temperature, salinity, u, v
    from
      join_values (modelid, rundate, depth_level, time_step)) s on s.modelid = t.modelid
    and s.depth_level = t.depth_level
    and s.time_step = t.time_step
    and s.run_date = t.run_date
    and s.coordinateid = t.coordinateid
  when not matched then
    insert (modelid, depth_level, time_step, run_date, coordinateid, xyz, depth, temperature, salinity, u, v)
      values (s.modelid, s.depth_level, s.time_step, s.run_date, s.coordinateid, s.xyz, s.depth, s.temperature, s.salinity, s.u, s.v);
end;
$$
language 'plpgsql';

