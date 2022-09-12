;

with ref as (
  select
    %s filename,
    %s runid)
    
insert into raster_xref_run (rasterid, runid)
select
  r.rid rasterid,
  ref.runid
from
  ref
  join rasters r on r.filename = ref.filename
where
  not exists (
    select
      1
    from
      raster_xref_run x
    where
      x.rasterid = r.rid
      and x.runid = ref.runid);

