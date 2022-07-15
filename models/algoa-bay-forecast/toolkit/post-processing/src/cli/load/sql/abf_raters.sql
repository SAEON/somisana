;with rasters as (
  select
    rid,
    (regexp_match(filename, '[^:]*$')) [1] variable,
    (regexp_match(filename, '(?=\d).*?(?=\-)')) [1] :: int run_date,
    rast
  from
    algoa_bay_forecast
)

select
  rid,
  variable,
  run_date,
  st_dumpvalues(rast, 1)
from
  rasters
where
  run_date = 20220715
  and variable = 'temperature'