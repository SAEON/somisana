# SOMISANA Web

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Quick start](#quick-start)
  - [Start the API](#start-the-api)
  - [Start the React.js client](#start-the-reactjs-client)
  - [Load assets](#load-assets)
  - [Start a local MongoDB server](#start-a-local-mongodb-server)
  - [Start a local PostGIS server](#start-a-local-postgis-server)
  - [Start a local `pg_tileserv` server](#start-a-local-pg_tileserv-server)
  - [Start a local `pg_featureserv` server](#start-a-local-pg_featureserv-server)
- [Usage reports](#usage-reports)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

## Start the API
```sh
# Install Node.js (v20.3.1)

# Install chomp (wait for output, can take a while)
npm install -g chomp && chomp --version

cd api
npm install
chomp
```

## Start the React.js client
```sh
cd client
npm install
npm start
```

## Load assets

Navigate to `<repo root>/assets/` and follow the instructions on the README to load 3rd party assets into the database

## [Start a local MongoDB server](https://github.com/SAEON/mongo#local-development)

## [Start a local PostGIS server](https://github.com/SAEON/postgis#local-development)

## Start a local `pg_tileserv` server

Assuming you have a PostGIS server running as a docker container with the name `postgis` on a network called `postgis`:

```sh
docker run \
  -dt \
  --restart always \
  --name pg_tileserv \
  -p 7800:7800 \
  --net postgis \
  -e DATABASE_URL=postgres://admin:password@postgis:5432/somisana_local \
  pramsey/pg_tileserv:latest
```

## Start a local `pg_featureserv` server

Assuming you have a PostGIS server running as a docker container with the name `postgis` on a network called `postgis`:

```sh
docker run \
  -dt \
  --restart always \
  --name pg_featureserv \
  -p 9000:9000 \
  --net postgis \
  -e DATABASE_URL=postgres://admin:password@postgis:5432/somisana_local \
  -e PGFS_PAGING_LIMITDEFAULT=50000 \
  -e PGFS_PAGING_LIMITMAX=50000 \
  pramsey/pg_featureserv:latest
```
# Usage reports
Usage reports are accessible as MongoDB views that are registered with the database on API startup