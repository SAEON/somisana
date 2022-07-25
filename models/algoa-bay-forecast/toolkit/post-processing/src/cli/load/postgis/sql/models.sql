create
or replace view models as with models as (
  select
    distinct (regexp_match(filename, '.*?(?=-\d)')) [1] "name"
  from
    rasters
)
select
  "name"
  -- max / min x/y, for vectors
from
  models;