# SOMISANA Web

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Quick start](#quick-start)
  - [Start a local MongoDB server](#start-a-local-mongodb-server)
  - [Start a local PostGIS server](#start-a-local-postgis-server)
  - [Start a local `pg_tileserv` server](#start-a-local-pg_tileserv-server)
  - [Add an HTML page to the app](#add-an-html-page-to-the-app)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

From the `somisana/web` directory, setup your environment:

```sh
# Install Node.js (v16.14.2 - higher versions not supported yet)

# Install chomp
npm install -g chomp
# (this downloads a large binary in the background - run "chomp --version", which will output once the binary is downloaded)

# Install dependencies
npm install
```

To start the application run the default chomp task as defined in [chompfile.toml](chompfile.toml):

```sh
chomp --watch
```

`chomp` is a CLI tool that allows for defining task graphs. It's an improvement of using the `scripts` field via `npm` as defined in `package.json` (the latter doesn't allow splitting strings onto multiple lines and/or defining serial/concurrent dependencies). The `chomp --watch` command runs this series of tasks (the `--watch` flag restarts the task chain on file changes):

1. Transpile the client source code (`JSX`) to regular JavaScript. This is done via `Rollup`/`SWC`. Look at the [rollup.config.js](rollup.config.js) for more information
2. Link the transpiled source code to the HTML entry points using `JSPM` (look at the `html` task in [chompfile.toml](chompfile.toml))
3. Start the `Koa` app (Node.js)

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

## Add an HTML page to the app

The build process will automatically configure routes from specific files in the `client/` directory. To add a new HTML route:

1. Add a new file - `client/html/your-new-route.html` - in the same style as the other HTML files in `client/html`. Note that the `<script>` tag should have `src="index.your-new-route.js"`.
2. Add a new folder `client/pages/your-new-route` with 2 files (`index.js` and `ssr.js`). This folder should be of the same format of other folders in `client/pages/*`
3. Update `index.importmap.js` to include an import to `.cache/ssr.<your-new-route>.js` so that the imports defined in the client are available at SSR time

The `Rollup` build will look for the `index.js` and `ssr.js` files and process them so that the Node.js application can find them. Note that the `ssr.js` file should not run code except via invoking functions (otherwise browser-specific APIs cause the SSR process to fail) and there should be a default export that is the entry point to the React code.
