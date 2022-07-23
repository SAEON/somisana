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
-- alter database <db> set postgis.enable_outdb_rasters = true;
-- alter database <db> SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
/*********************************************************/

-- model dimension
create table if not exists model (
  id serial primary key,
  "name" varchar(255)
);

-- dept dimension
create table if not exists depth (
  id serial primary key,
  depth decimal
);

-- location dimension
create table if not exists "location" (
  id serial primary key,
  xy geometry not null unique
);

-- temperature (fact)
create table if not exists temperatures (
  id serial primary key,
  "value" decimal not null,
  location_id int references "location" (id),
  model_id int references "model" (id),
  forecast_datetime timestamp,
  forecast_offset int not null
);

-- salinities (fact)
create table if not exists salinities (
  id serial primary key,
  "value" decimal not null,
  location_id int not null references "location" (id),
  model_id int not null references "model" (id),
  forecast_datetime timestamp,
  forecast_offset int not null
);