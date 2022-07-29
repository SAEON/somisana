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
  id serial not null primary key,
  name varchar(255) not null unique
);

merge into public.models t
using (
  select
    'algoa-bay-forecast' name
  union
    select
      'false-bay-forecast' name) s on s.name = t.name
when not matched then
  insert (name)
    values (s.name);

create table if not exists public.raster_xref_model (
  id serial not null primary key,
  rasterid int not null unique references rasters (rid) on delete cascade,
  modelid int not null references models (id) on delete cascade
);

create table if not exists public.coordinates (
  id serial not null primary key,
  modelid int not null references models (id) on delete cascade,
  pixel geometry not null,
  coord geometry not null,
  longitude float not null,
  latitude float not null,
  constraint unique_coordinates unique (modelid, pixel)
);

