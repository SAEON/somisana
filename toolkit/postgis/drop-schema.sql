-- MATERIALIZED VIEWS
drop materialized view if exists public.coordinates cascade;

-- TABLES
drop table if exists public.raster_xref_model cascade;
drop table if exists public.models cascade;
drop table if exists public.rasters cascade;