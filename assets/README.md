# List of assets

These are required resources for the system to run as expected

## SAMPAZ_OR_2022_Q3

MPAs downloaded from the [DFFE website](https://egis.environment.gov.za/data_egis/data_download/current). To install, from the root of the somisana repository run:

```sh
# Replace as necessary
POSTGIS_HOST=localhost
USERNAME=admin
PASSWORD=password
POSTGIS_DB=somisana_local
SCHEMA=public
PORT=5432

docker \
  run \
    --rm \
    -v $PWD/assets:/assets \
    osgeo/gdal:ubuntu-full-3.6.3 \
      ogr2ogr \
      -skipfailures \
      -overwrite \
      -f PostgreSQL \
      -lco PRECISION=NO \
      -nlt PROMOTE_TO_MULTI \
      -nln mpas \
      "PG:host=$POSTGIS_HOST port=$PORT user=$USERNAME password=$PASSWORD dbname=$POSTGIS_DB active_schema=$SCHEMA" \
      /vsizip/assets/SAMPAZ_OR_2022_Q3.zip
```
