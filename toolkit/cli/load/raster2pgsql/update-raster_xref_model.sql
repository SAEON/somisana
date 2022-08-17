;

with ref as (
  select
    %s filename,
    %s model
)

insert into raster_xref_model (rasterid, modelid, run_date)
select
  r.rid rasterid,
  m.id modelid,
  %s run_date
from
  ref
  left join rasters r on r.filename = ref.filename
  left join models m on m.name = ref.model

where not exists (
  select 1
  from raster_xref_model x
  where x.rasterid = r.rid and x.modelid = m.id
);


