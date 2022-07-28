;

create extension if not exists postgis;

create extension if not exists postgis_raster;

create extension if not exists postgis_topology;

create extension if not exists postgis_sfcgal;

create extension if not exists fuzzystrmatch;

create extension if not exists address_standardizer;

create extension if not exists address_standardizer_data_us;

create extension if not exists postgis_tiger_geocoder;

create table if not exists public.rasters (
  rid serial not null primary key,
  rast public.raster null,
  filename text null
);

create table if not exists public.models (
  id serial primary key,
  name varchar(255),
  constraint models_unique_name unique (name)
);

insert into public.models (name)
  values ('algoa-bay-forecast'), ('false-bay-forecast')
on conflict on constraint models_unique_name
  do nothing;

create table if not exists public.raster_xref_model (
  id serial primary key,
  rasterid int references rasters (rid) on delete cascade,
  modelid int references models (id) on delete cascade,
  constraint raster_xref_filename_unique_rasterid unique (rasterid)
);

