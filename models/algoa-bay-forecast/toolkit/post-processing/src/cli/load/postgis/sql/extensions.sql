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