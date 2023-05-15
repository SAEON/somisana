-- FUNCTIONS
drop function if exists public.somisana_join_values cascade;

drop function if exists public.somisana_upsert_values cascade;

drop function if exists public.somisana_interpolate_values cascade;

-- TABLES
drop table if exists public.values cascade;

drop table if exists public.interpolated_values;

drop table if exists public.runs cascade;

drop table if exists public.coordinates cascade;

drop table if exists public.raster_xref_run cascade;

drop table if exists public.models cascade;

drop table if exists public.rasters cascade;

