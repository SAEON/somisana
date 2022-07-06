create materialized view if not exists wms_abf_salinity as
  select
    *
  from salinities;