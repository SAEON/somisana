create materialized view if not exists wms_abf_temperature as
  select
    *
  from temperatures;