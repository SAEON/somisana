;

--create extension if not exists pg_trgm;
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

create table if not exists public.runs (
  id smallint primary key generated always as identity,
  run_date date not null unique,
  modelid smallint not null references public.models (id)
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

create table if not exists public.raster_xref_run (
  id int primary key generated always as identity,
  rasterid int not null unique references public.rasters (rid) on delete cascade,
  runid smallint not null references public.runs (id) on delete cascade,
  constraint unique_rasters_per_model unique (rasterid, runid)
);

create table if not exists public.coordinates (
  id int primary key generated always as identity,
  modelid smallint not null references models (id) on delete cascade,
  pixel geometry(point, 0) not null,
  coord geometry(point, 3857) not null,
  longitude float not null,
  latitude float not null,
  bathymetry decimal(7, 2) not null,
  has_value boolean default false,
  constraint unique_coordinates unique (modelid, pixel)
);

create index if not exists coordinates_has_value on public.coordinates using btree (has_value);

create index if not exists coordinates_modelid on public.coordinates using btree (modelid);

create index if not exists coordinates_coord on public.coordinates using gist (coord);

create index if not exists coordinates_pixel on public.coordinates using gist (pixel);

create table if not exists public.values (
  id bigint primary key generated always as identity,
  runid smallint not null references public.runs (id) on delete cascade,
  depth_level smallint not null,
  time_step smallint not null,
  coordinateid int not null references public.coordinates (id) on delete cascade,
  depth decimal(7, 2),
  temperature decimal(4, 2),
  salinity decimal(6, 4),
  u decimal(5, 4),
  v decimal(5, 4),
  constraint values_unique_cols unique (runid, time_step, depth_level, coordinateid)
);

create index if not exists values_coordinateid on public.values using btree (coordinateid asc);


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
  (st_makeenvelope (min_x, min_y, max_x, max_y, 4326))::geometry(Polygon, 4326) envelope,
  (
    select
      json_agg(runs)
    from
      runs
    where
      modelid = modelid) runs
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
drop function if exists public.somisana_get_pixel_values cascade;

create function public.somisana_get_pixel_values (runid int, depth_level int, time_step int, variable text)
  returns table (
    pixel geometry,
    value numeric
  )
  as $$
declare
  band_no int;
  rd int;
begin
  band_no := ((time_step - 1) * 20) + depth_level;
  rd := runid;
  return query with centroids as (
    select
      (ST_PixelAsCentroids (r.rast, band_no)).*
    from
      rasters r
      join raster_xref_run x on x.rasterid = r.rid
    where
      x.runid = rd
      and filename like ('%:' || variable))
  select
    geom pixel,
    val::numeric value
  from
    centroids;
end;
$$
language 'plpgsql'
stable parallel safe;

drop function if exists public.somisana_join_values cascade;

create function public.somisana_join_values (runid smallint, depth_level smallint, time_step smallint)
  returns table (
    coordinateid int,
    depth decimal(7, 2),
    temperature decimal(4, 2),
    salinity decimal(6, 4),
    u decimal(5, 4),
    v decimal(5, 4)
  )
  as $$
begin
  return query with depths as (
    select
      pixel,
      value
    from
      public.somisana_get_pixel_values (runid, depth_level, time_step, variable => 'm_rho')
),
temperatures as (
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values (runid, depth_level, time_step, variable => 'temperature')
),
salinity as (
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values (runid, depth_level, time_step, variable => 'salt')
),
u as (
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values (runid, depth_level, time_step, variable => 'u')
),
v as (
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values (runid, depth_level, time_step, variable => 'v'))
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
  join coordinates c on c.pixel = d.pixel;
end;
$$
language 'plpgsql'
stable parallel safe;

drop function if exists public.somisana_upsert_values cascade;

create function public.somisana_upsert_values (run_id smallint, depth_level smallint, time_step smallint)
  returns void
  as $$
begin
  merge into public.values t
  using (
    select
      depth_level, time_step, run_id runid, coordinateid, depth, temperature, salinity, u, v
    from
      somisana_join_values (run_id, depth_level, time_step)) s on s.runid = t.runid
    and s.time_step = t.time_step
    and s.depth_level = t.depth_level
    and s.coordinateid = t.coordinateid
  when not matched then
    insert (depth_level, time_step, runid, coordinateid, depth, temperature, salinity, u, v)
      values (s.depth_level, s.time_step, s.runid, s.coordinateid, s.depth, s.temperature, s.salinity, s.u, s.v)
      when matched then
        update set
          depth = s.depth, temperature = s.temperature, salinity = s.salinity, u = s.u, v = s.v;
end;
$$
language 'plpgsql'
parallel safe;

drop function if exists public.somisana_interpolate_values cascade;

create function public.somisana_interpolate_values (target_depth integer default 0, runid integer default 1, time_step integer default 1)
  returns table (
    coordinateid int,
    interpolated_temperature decimal(4, 2),
    interpolated_salinity decimal(6, 4),
    interpolated_u decimal(5, 4),
    interpolated_v decimal(5, 4)
  )
  as $$
declare
  t int;
  declare r int;
  declare ts int;
  declare m int;
begin
  t := target_depth;
  r := runid;
  ts := time_step;
  return query with
values
  as (
    select
      v.id,
      v.coordinateid,
      v.depth_level,
      v.temperature temp,
      v.salinity salt,
      v.u,
      v.v,
      v.depth,
      t target_depth
    from
    values
      v
    where
      v.runid = r
      and v.time_step = ts
),
bounded_values as (
  select
    b.*,
    row_number() over (partition by b.coordinateid order by interpolation_distance asc) "r#"
  from (
  select
    v.id,
    v.coordinateid,
    v.depth_level,
    v.target_depth,
    abs(v.depth - v.target_depth) interpolation_distance,
    case when v.target_depth between v.depth and coalesce(v_upper.depth, 0) then
      'UP'
    when v.target_depth between v_lower.depth and v.depth then
      'DOWN'
    else
      'UP'
    end interp_direction,
    coalesce(v_upper.depth, 0) depth_upper,
  v.depth,
  v_lower.depth depth_lower,
  coalesce(v_upper.temp, v.temp) temp_upper,
  v.temp,
  v_lower.temp temp_lower,
  coalesce(v_upper.salt, v.salt) salt_upper,
  v.salt,
  v_lower.salt salt_lower,
  coalesce(v_upper.u, v.u) u_upper,
  v.u,
  v_lower.u u_lower,
  coalesce(v_upper.v, v.v) v_upper,
  v.v,
  v_lower.v v_lower
from
values v
  left join
values v_upper on v_upper.coordinateid = v.coordinateid
  and v_upper.depth_level = (v.depth_level + 1)
  left join
values v_lower on v_lower.coordinateid = v.coordinateid
  and v_lower.depth_level = case when v.depth_level < 2 then
    v.depth_level
  else
    (v.depth_level - 1)
  end) b
where depth_lower is not null
and b.target_depth between b.depth_lower and b.depth_upper
),
equation_vals as (
  select
    *,
    -- DEPTH
    b.target_depth - depth x,
    case interp_direction
    when 'UP' then
      depth - coalesce(depth_upper, 0)
    when 'DOWN' then
      depth - depth_lower
    end "Δx",
    -- TEMP
    temp c_temp,
    case interp_direction
    when 'UP' then
      temp - temp_upper
    when 'DOWN' then
      temp - temp_lower
    end "Δy_temp",
    -- SALINITY
    salt c_salt,
    case interp_direction
    when 'UP' then
      salt - salt_upper
    when 'DOWN' then
      salt - salt_lower
    end "Δy_salt",
    -- U
    u c_u,
    case interp_direction
    when 'UP' then
      u - u_upper
    when 'DOWN' then
      u - u_lower
    end "Δy_u",
    -- V
    v c_v,
    case interp_direction
    when 'UP' then
      v - v_upper
    when 'DOWN' then
      v - v_lower
    end "Δy_v"
  from
    bounded_values b
  where
    "r#" = 1
),
interpolated_values as (
  select
    e.coordinateid,
    (("Δy_temp" / "Δx") * x) + c_temp interpolated_temperature,
    (("Δy_salt" / "Δx") * x) + c_salt interpolated_salinity,
    (("Δy_u" / "Δx") * x) + c_u interpolated_u,
    (("Δy_v" / "Δx") * x) + c_u interpolated_v
  from
    equation_vals e
)
select
  *
from
  interpolated_values;
end;
$$
language 'plpgsql'
stable parallel safe;

