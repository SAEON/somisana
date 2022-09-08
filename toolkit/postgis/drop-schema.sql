-- FUNCTIONS
drop function if exists public.somisana_get_values cascade;

drop function if exists public.somisana_join_values cascade;

drop function if exists public.somisana_upsert_values cascade;

drop function if exists public.somisana_interpolated_values cascade;

-- VIEWS

drop view if exists public.metadata cascade;

-- TABLES

drop table if exists public.values cascade;

drop table if exists public.model_runs cascade;

drop table if exists public.coordinates cascade;

drop table if exists public.raster_xref_model cascade;

drop table if exists public.models cascade;

drop table if exists public.rasters cascade;
