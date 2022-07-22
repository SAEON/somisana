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


/**
;with rasts as (
  select
	rid,
	st_band(rast, 1) rast
  from r
  where rid in (1)
)

,joined as (
	select
	st_union(rast) rast
	from rasts
)

select
	st_numbands(rast),
	st_contour(
		rast,
		bandnumber => 1,
		level_interval => 10,
		level_base => 5,
		fixed_levels => Array[5, 15, 25]
	)
from joined
**/