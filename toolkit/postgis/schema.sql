/**************** ENABLE spatial extensions ******************/
create extension if not exists postgis;

create extension if not exists postgis_raster;

create extension if not exists postgis_topology;

create extension if not exists postgis_sfcgal;

create extension if not exists fuzzystrmatch;

create extension if not exists address_standardizer;

create extension if not exists address_standardizer_data_us;

create extension if not exists postgis_tiger_geocoder;

set postgis.gdal_enabled_drivers = 'ENABLE_ALL';

set postgis.enable_outdb_rasters = 1;

-- Allow access to external data and formats permnently
-- alter database somisana_local set postgis.enable_outdb_rasters = true;
-- alter database somisana_local SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
/*********************************************************/
create table if not exists public.rasters (
  rid serial not null primary key,
  rast public.raster null,
  filename text null
);

create table if not exists public.models (
  id serial primary key,
  name varchar(255),
  constraint models_unique_name unique ("name")
);

insert into public.models ("name")
  values ('algoa-bay-forecast'), ('false-bay-forecast')
on conflict on constraint models_unique_name
  do nothing;

create table if not exists public.raster_xref_model (
  id serial primary key,
  rasterId int references rasters (rid),
  modelId int references models (id),
  constraint raster_xref_filename_unique unique ("rasterId", "modelId")
);

