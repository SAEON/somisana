;

with m as (
  select
    *
  from
    public.models m
  where
    m.name = %s
),
lon as (
  select
    modelid,
    geom pixel,
    rasterid,
    val longitude
  from ( select distinct
      m.id modelid,
      r.rid rasterid,
      (ST_PixelAsCentroids (rast, 1)).*
    from
      rasters r
      join raster_xref_model rxm on rxm.rasterid = r.rid
      join m on m.id = rxm.modelid
    where
      filename like '%%lon_rho') lon
),
lat as (
  select
    modelid,
    geom pixel,
    rasterid,
    val latitude
  from ( select distinct
      m.id modelid,
      r.rid rasterid,
      (ST_PixelAsCentroids (rast, 1)).*
    from
      rasters r
    left join raster_xref_model rxm on rxm.rasterid = r.rid
    left join m on m.id = rxm.modelid
  where
    filename like '%%lat_rho') lat) merge into public.coordinates t using (
  select
    lon.modelid, lon.rasterid lon_rasterid, lat.rasterid lat_rasterid, lon.pixel, st_point (lon.longitude, lat.latitude, 4326) coord, lon.longitude, lat.latitude from lon
  join lat on lat.pixel = lon.pixel
    and lat.modelid = lon.modelid) s on s.modelid = t.modelid
  and s.pixel = t.pixel
  when not matched then
    insert (modelid, lon_rasterid, lat_rasterid, pixel, coord, longitude, latitude)
      values (s.modelid, s.lon_rasterid, s.lat_rasterid, s.pixel, s.coord, s.longitude, s.latitude);

