;

with lon as (
  select
    modelid,
    geom pixel,
    val longitude
  from ( select distinct
      m.id modelid,
      (ST_PixelAsCentroids (rast, 1)).*
    from
      rasters r
      join raster_xref_model rxm on rxm.rasterid = r.rid
      join models m on m.id = rxm.modelid
        and m.name = %s
    where
      filename like '%%lon_rho') lon
),
lat as (
  select
    modelid,
    geom pixel,
    val latitude
  from ( select distinct
      m.id modelid,
      (ST_PixelAsCentroids (rast, 1)).*
    from
      rasters r
    left join raster_xref_model rxm on rxm.rasterid = r.rid
    left join models m on m.id = rxm.modelid
      and m.name = %s
  where
    filename like '%%lat_rho') lat) merge into public.coordinates t using (
  select
    lon.modelid, lon.pixel, st_point (lon.longitude, lat.latitude, 4326) coord, lon.longitude, lat.latitude from lon
  join lat on lat.pixel = lon.pixel
    and lat.modelid = lon.modelid) s on s.modelid = t.modelid
  and s.pixel = t.pixel
  when not matched then
    insert (modelid, pixel, coord, longitude, latitude)
      values (s.modelid, s.pixel, s.coord, s.longitude, s.latitude);

