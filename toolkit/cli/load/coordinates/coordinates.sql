do $$
begin
  if exists (
    select
      1
    from
      pg_matviews
    where
      matviewname = 'coordinates') then
  if not exists (
    select
      1
    from
      coordinates c
      join models m on m.id = c.modelid
    where
      m.name = %s) then
  refresh materialized view coordinates;
end if;
else
  create materialized view coordinates as
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
      where
        filename like '%lon_rho') lon
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
  where
    filename like '%lat_rho') lat
)
select
  lon.modelid,
  lon.pixel,
  lon.longitude,
  lat.latitude,
  st_point (lon.longitude, lat.latitude, 4326) coord
from
  lon
  join lat on lat.pixel = lon.pixel
    and lat.modelid = lon.modelid;
end if;
end
$$;

