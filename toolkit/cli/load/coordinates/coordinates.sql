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
    val
  from ( select distinct
      m.id modelid,
      r.rid rasterid,
      (ST_PixelAsCentroids (rast, 1)).*
    from
      rasters r
      join raster_xref_model rxm on rxm.rasterid = r.rid
      join m on m.id = rxm.modelid
    where
      filename like '%%:lon_rho') lon
),
lat as (
  select
    modelid,
    geom pixel,
    rasterid,
    val
  from ( select distinct
      m.id modelid,
      r.rid rasterid,
      (ST_PixelAsCentroids (rast, 1)).*
    from
      rasters r
    left join raster_xref_model rxm on rxm.rasterid = r.rid
    left join m on m.id = rxm.modelid
  where
    filename like '%%:lat_rho') lat) 
    
    
,h as (
  select
    modelid,
    geom pixel,
    rasterid,
    (val * -1) val
  from ( select distinct
      m.id modelid,
      r.rid rasterid,
      (ST_PixelAsCentroids (rast, 1)).*
    from
      rasters r
    left join raster_xref_model rxm on rxm.rasterid = r.rid
    left join m on m.id = rxm.modelid
  where
    filename like '%%:h') h)   
    
merge into public.coordinates t using (
  select
    lon.modelid,
    lon.rasterid lon_rasterid,
    lat.rasterid lat_rasterid,
    lon.pixel,
    st_point (lon.val, lat.val, 4326) coord,
    lon.val longitude,
    lat.val latitude,
    h.val bathymetry
  from lon
  join lat on lat.pixel = lon.pixel and lat.modelid = lon.modelid
  join h on h.pixel = lon.pixel and h.modelid = lon.modelid
) s on
  s.modelid = t.modelid
  and s.pixel = t.pixel
  when not matched then
    insert (modelid, lon_rasterid, lat_rasterid, pixel, coord, longitude, latitude, bathymetry)
      values (s.modelid, s.lon_rasterid, s.lat_rasterid, s.pixel, s.coord, s.longitude, s.latitude, s.bathymetry);

