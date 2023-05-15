;

with run as (
  select
    r.id,
    m.id modelid
  from
    public.models m
    join public.runs r on r.modelid = m.id
  where
    m.name = $1
  order by
    r.id asc
  limit 1
),
lon as (
  select distinct
    (ST_PixelAsCentroids(rast, 1)).*
  from
    rasters r
    join raster_xref_run x on x.rasterid = r.rid
    join run on run.id = x.runid
  where
    filename like '%:lon_rho'
    and run.id = x.runid
),
lat as (
  select distinct
    (ST_PixelAsCentroids(rast, 1)).*
  from
    rasters r
    join raster_xref_run x on x.rasterid = r.rid
    join run on run.id = x.runid
  where
    filename like '%:lat_rho'
    and run.id = x.runid
),
h as (
  select distinct
    (ST_PixelAsCentroids(rast, 1)).*
  from
    rasters r
    join raster_xref_run x on x.rasterid = r.rid
    join run on run.id = x.runid
  where
    filename like '%:h'
    and run.id = x.runid) merge into public.coordinates t
  using (
    select
      (
        select
          modelid
        from
          run) modelid, lat.geom pixel, st_transform(st_point(lon.val, lat.val, 4326), 3857) coord, lon.val longitude, lat.val latitude, h.val bathymetry
          from
            lat
            join lon on lon.geom = lat.geom
            join h on h.geom = lat.geom) s on s.modelid = t.modelid
    and s.pixel = t.pixel
  when not matched then
      insert
        (modelid, pixel, coord, longitude, latitude, bathymetry)
        values (s.modelid, s.pixel, s.coord, s.longitude, s.latitude, s.bathymetry);

