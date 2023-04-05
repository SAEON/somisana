<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [List of assets](#list-of-assets)
  - [SAMPAZ_OR_2022_Q3](#sampaz_or_2022_q3)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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
