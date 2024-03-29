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

create table if not exists public.rasters(
  rid int primary key generated by default as identity,
  rast public.raster null,
  filename text null
);

create index if not exists rasters_rast_st_convexhull_idx on public.rasters using gist(ST_ConvexHull(rast));

create table if not exists public.models(
  id smallint primary key generated by default as identity,
  name varchar(255) not null unique,
  title varchar(255),
  description text,
  creator text,
  creator_contact_email text,
  type text,
  grid_width int,
  grid_height int,
  sigma_levels int,
  min_x float,
  max_x float,
  min_y float,
  max_y float,
  convexhull geometry(polygon, 3857),
  envelope geometry(polygon, 4326)
);

create table if not exists public.coordinates(
  id int primary key generated by default as identity,
  modelid smallint not null references models(id),
  pixel geometry(point, 0) not null,
  coord geometry(point, 3857) not null,
  longitude float not null,
  latitude float not null,
  bathymetry decimal(7, 2) null
);

create unique index if not exists unique_coordinates on public.coordinates using btree(modelid, pixel);

create index if not exists coordinates_modelid on public.coordinates using btree(modelid);

create index if not exists coordinates_coord on public.coordinates using gist(coord);

create index if not exists coordinates_pixel on public.coordinates using gist(pixel);

create table if not exists public.runs(
  id smallint primary key generated by default as identity,
  run_date date not null,
  modelid smallint not null references public.models(id),
  step1_timestamp timestamp null,
  timestep_attrs json null,
  successful boolean default null
);

create unique index if not exists unique_runs_per_model on public.runs using btree(run_date desc, modelid);

create table if not exists public.raster_xref_run(
  id int primary key generated by default as identity,
  rasterid int not null unique references public.rasters(rid) on delete cascade,
  runid smallint not null references public.runs(id) on delete cascade
);

create unique index if not exists unique_rasters_per_model on public.raster_xref_run using btree(rasterid, runid);

create table if not exists public.values(
  id bigint generated by default as identity,
  runid smallint not null references public.runs(id),
  depth_level smallint not null,
  time_step smallint not null,
  coordinateid int not null references public.coordinates(id),
  depth decimal(7, 2),
  temperature decimal(4, 2),
  salinity decimal(6, 4),
  u decimal(5, 4),
  v decimal(5, 4),
  primary key (id, runid)
)
partition by list (runid);

create table if not exists public.interpolated_values(
  coordinateid int not null references public.coordinates(id),
  time_step smallint not null,
  depth decimal(7, 2),
  runid smallint not null references public.runs(id),
  temperature decimal(4, 2),
  salinity decimal(6, 4),
  u decimal(5, 4),
  v decimal(5, 4),
  primary key (coordinateid, time_step, depth, runid)
)
partition by list (runid);


/**
 * FUNCTIONS
 */
drop function if exists public.somisana_get_pixel_values;

create function public.somisana_get_pixel_values(runid int, depth_level int, time_step int, variable text, total_depth_levels int default 20)
  returns table(
    pixel geometry,
    value numeric
  )
  as $$
declare
  band_no int;
  rd int;
begin
  band_no :=((time_step - 1) * total_depth_levels) + depth_level;
  rd := runid;
  return query with centroids as (
    select
      (ST_PixelAsCentroids(r.rast, band_no)).*
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

create function public.somisana_join_values(runid int, depth_level int, time_step int, total_depth_levels int default 20)
  returns table(
    coordinateid int,
    depth decimal(7, 2),
    temperature decimal(4, 2),
    salinity decimal(6, 4),
    u decimal(5, 4),
    v decimal(5, 4)
  )
  as $$
begin
  return query with _coordinates as(
    select
      id,
      pixel
    from
      public.coordinates c
    where
      c.modelid =(
        select
          modelid
        from
          runs
        where
          runs.id = runid)
),
depths as(
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values(runid => runid, depth_level => depth_level, time_step => time_step, variable => 'depth', total_depth_levels => total_depth_levels)
),
temperatures as(
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values(runid => runid, depth_level => depth_level, time_step => time_step, variable => 'temp', total_depth_levels => total_depth_levels)
),
salinity as(
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values(runid => runid, depth_level => depth_level, time_step => time_step, variable => 'salt', total_depth_levels => total_depth_levels)
),
u as(
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values(runid => runid, depth_level => depth_level, time_step => time_step, variable => 'u', total_depth_levels => total_depth_levels)
),
v as(
  select
    pixel,
    value
  from
    public.somisana_get_pixel_values(runid => runid, depth_level => depth_level, time_step => time_step, variable => 'v', total_depth_levels => total_depth_levels))
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
  join _coordinates c on c.pixel = d.pixel;
end;
$$
language 'plpgsql'
stable parallel safe;

drop function if exists public.somisana_upsert_values cascade;

create function public.somisana_upsert_values(run_id int, depth_level int, time_step int, total_depth_levels int default 20)
  returns void
  as $$
begin
  merge into public.values t
  using(
    select
      depth_level, time_step, run_id runid, coordinateid, depth, temperature, salinity, u, v
    from
      somisana_join_values(runid => run_id, depth_level => depth_level, time_step => time_step, total_depth_levels => total_depth_levels)) s on s.runid = t.runid
    and s.time_step = t.time_step
    and s.depth_level = t.depth_level
    and s.coordinateid = t.coordinateid
  when not matched then
    insert(depth_level, time_step, runid, coordinateid, depth, temperature, salinity, u, v)
      values(s.depth_level, s.time_step, s.runid, s.coordinateid, s.depth, s.temperature, s.salinity, s.u, s.v)
      when matched then
        update set
          depth = s.depth, temperature = s.temperature, salinity = s.salinity, u = s.u, v = s.v;
end;
$$
language 'plpgsql'
parallel safe;

drop function if exists public.somisana_interpolate_values cascade;

create function public.somisana_interpolate_values(target_depth integer default 0, runid integer default 1, time_step integer default 1)
  returns table(
    coordinateid int,
    long float,
    lat float,
    interpolated_temperature decimal(4, 2),
    interpolated_salinity decimal(6, 4),
    interpolated_u decimal(5, 4),
    interpolated_v decimal(5, 4),
    _depth decimal(7, 2)
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
  return query with _values as (
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
      public.values v
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
    v.depth,
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
from _values v
  left join _values v_upper on v_upper.coordinateid = v.coordinateid
    and v_upper.depth_level =(v.depth_level + 1)
  left join _values v_lower on v_lower.coordinateid = v.coordinateid
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
_interpolated_values as (
  select
    e.coordinateid,
    e.depth,
(("Δy_temp" / "Δx") * x) + c_temp interpolated_temperature,
(("Δy_salt" / "Δx") * x) + c_salt interpolated_salinity,
(("Δy_u" / "Δx") * x) + c_u interpolated_u,
(("Δy_v" / "Δx") * x) + c_u interpolated_v
  from
    equation_vals e
),
grid as (
  select
    c.id coordinateid,
    v.depth,
    c.latitude lat,
    c.longitude long,
    v.interpolated_temperature,
    v.interpolated_salinity,
    v.interpolated_u,
    v.interpolated_v
  from
    _interpolated_values v
    join coordinates c on c.id = v.coordinateid
  where
    c.modelid =(
      select
        modelid
      from
        runs
      where
        id = r))
select
  g.coordinateid,
  g.long,
  g.lat,
  g.interpolated_temperature,
  g.interpolated_salinity,
  g.interpolated_u,
  g.interpolated_v,
  g.depth _depth
from
  grid g;
end;
$$
language 'plpgsql'
stable parallel safe;

