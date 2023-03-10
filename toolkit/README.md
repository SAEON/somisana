# SOMISANA Toolkit

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Documentation](#documentation)
  - [Install](#install)
  - [Examples](#examples)
    - [Algoa Bay operational model](#algoa-bay-operational-model)
    - [Marine Heat Waves](#marine-heat-waves)
- [Local development](#local-development)
  - [Configure Python](#configure-python)
    - [Install pyenv](#install-pyenv)
    - [Install pipenv](#install-pipenv)
  - [Install 3rd party dependencies](#install-3rd-party-dependencies)
  - [Start the CLI](#start-the-cli)
  - [Setup script-environment variables](#setup-script-environment-variables)
  - [3rd party services](#3rd-party-services)
    - [PostGIS](#postgis)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Documentation

The SOMISANA toolkit is packaged as a Docker image, and can be used without configuring a local dev environment.

## Install

Ensure that [docker](https://www.docker.com/) is installed on your system, and install the CLI:

```sh
# Download and execute the install script
wget -qO- https://raw.githubusercontent.com/SAEON/somisana/stable/toolkit/install.sh | bash

# Reload your terminal configuration
source ~/.bashrc

# Start Docker if it's not running
sudo service docker start

# Run the CLI
somisana -h
```

## Examples

### Algoa Bay operational model

**_(1) Create a directory workspace_**

```sh
export SOMISANA_DIR="/home/$USER/temp/somisana"
export WORKDIR=$SOMISANA_DIR/local-run

mkdir -p $WORKDIR/{croco/{forcing,forecast,scratch},forcing-inputs}
touch $SOMISANA_DIR/.env
echo COPERNICUS_USERNAME=username >> $SOMISANA_DIR/.env
echo COPERNICUS_PASSWORD=password >> $SOMISANA_DIR/.env
touch $WORKDIR/.env
chmod -R 777 $SOMISANA_DIR
cd $SOMISANA_DIR
```

**_(2) Download GFS boundary data_**

```sh
somisana \
  ops \
    download \
    --workdir $WORKDIR/forcing-inputs \
    --matlab-env $WORKDIR/.env \
    --provider gfs \
    --domain 22,31,-37,-31
```

**_(3) Download Mercator boundary data_**

```sh
somisana \
  ops \
    download \
    --workdir $WORKDIR/forcing-inputs \
    --matlab-env $WORKDIR/.env \
    --provider mercator \
    --domain 22,31,-37,-31
```

**_(4) Create forcing files_**

For this step you do need the source code currently. From the root of the repository (and on the SAEON VPN):

```sh
docker run \
  --rm \
  -v $(pwd)/models/algoa-bay-forecast/crocotools:/crocotools/ \
  -v $(pwd)/models/algoa-bay-forecast/lib/grd.nc:/crocotools/croco/forcing/grd.nc \
  -v $WORKDIR:/tmp/somisana/current \
  -e MLM_LICENSE_FILE=27000@matlab-license-manager.saeon.int \
  ghcr.io/saeon/somisana_matlab:r2022a \
    -batch "run('/crocotools/run.m')"
```

**(5) _Run the compiled CROCO model_**

For this step you do need the source code currently. From the root of the repository:

```sh
export TODAY=$(date +"%Y%m%d")
export YESTERDAY=$(date -d "yesterday" +"%Y%m%d")

docker run \
  --rm \
  -v $WORKDIR:/algoa-bay-forecast/current \
  -v $(pwd)/models/algoa-bay-forecast/lib/grd.nc:/algoa-bay-forecast/current/croco/forcing/grd.nc \
  ghcr.io/saeon/somisana_algoa_bay_forecast_croco_stable:sha-c2a9c9f \
    ./run_croco.bash \
      /algoa-bay-forecast/current \
      $TODAY \
      $YESTERDAY
```

### Marine Heat Waves

TODO

# Local development

## Configure Python

You need to be able to specify specific Python versions for the toolkit. I use the `pyenv` tool for this, though there are other options for achieving this.

### Install pyenv

The pyenv tool adds entries to the beginning of your $PATH variable. So that when you type in the "python" or "pip" commands, you actually run the "pyenv" tool instead of python or pip (since the first entries on $PATH are from pyenv). Pyenv then manages python versions, and you can easily switch between python versions in your terminal. The pyenv tool just redirects the python/pip commands to specific Python versions.

To install, [follow the instructions](https://github.com/pyenv/pyenv#installation) (including first installing dependencies)

The automatic installer concludes with instructions on adding something to `.bashrc`. However, I found that I had to add the location of the `pyenv` installation to $PATH (`pyenv` installs a binary to `$HOME/.pyenv/`). So, I ignored the output instructions of the installer and instead adjusted `~/.bashrc` to include the following lines:

```sh
# Make the pyenv CLI available via $PATH, and set $PYENV_VERSION
export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_VERSION=3.10.6

# Configure pyenv virtual environment on shell start
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Alias the 'python' and 'pip' commands to use pyenv
alias python="pyenv exec python"
alias pip="pyenv exec pip"
```

Run `source ~/.bashrc` so that changes to your shell environment take effect.

Install and set a Python version via `pyenv` to use

```sh
PYENV_VERSION=3.10.6
pyenv install --list
pyenv install $PYENV_VERSION
```

### Install pipenv

Pipenv is a wrapper over the regular pip package manager, but with a slightly better mechanism for locking dependencies of referenced libraries (I believe). Dependencies are managed via the `Pipfile` and the `Pipfile.lock`.

```sh
pip install --user pipenv
```

And then update `~/.bashrc`

```sh
export PATH="$HOME/.local/bin:$PATH"
export PIPENV_VENV_IN_PROJECT="enabled"
```

Run `source ~/.bashrc` so that changes to your shell environment take effect.

## Install 3rd party dependencies

The python libraries included in this project require binaries that need to be installed explicitly. Run the following commands to install required dependencies in an Ubuntu environment.

```sh
# Install required binaries
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
  sqlite3 \
  libtiff-dev \
  curl \
  libssl-dev \
  libpq-dev \
  libcurl4-openssl-dev \
  libgeos++-dev \
  libgeos-3.8.0 \
  libgeos-c1v5 \
  libgeos-dev \
  libgeos-doc

# Build proj from source
wget https://download.osgeo.org/proj/proj-9.0.0.tar.gz
tar xzvf proj-9.0.0.tar.gz && cd proj-9.0.0
mkdir build && cd build
cmake ..
cmake --build .
sudo cmake --build . --target install

# Then I had to copy the build libraries to /usr/lib so that Python can use them
sudo cp -a proj-9.0.0/build/lib/. /usr/lib/

# Install PostGIS (for the raster2pgsql CLI)
sudo apt install postgis
```

## Start the CLI

Finally, start the CLI by installing dependencies as configured in `Pipfile`, and register the `toolkit` keyword on your `$PATH`.

```sh
# In the toolkit directory, create the ".venv" directory. This hints to pipenv that you want your virtual environment to be local
mkdir .venv
pipenv install
pipenv run script # This executes Python in the context of your virtual environment
```

Because starting the script via `pipenv run script` seems a little cumbersome, that command is used via the `bin/toolkit` file. This file is just a bash script, and needs to be configured to be executable and on the `$PATH` variable. The commands to register `bin/toolkit` as an executable script are in the `env.sh` file, which can be sourced:

```sh
# From the toolkit (or repo root) directory run:
source env.sh

# And then try the CLI
toolkit -h
```

## Setup script-environment variables

The CLI is configured via flags and environment variables (in the case of passwords/etc.). Copy the example config into you directory as `.env` and adjust accordingly. The `.env` file is kept out of source control.

```sh
cp .env.example .env
```

NOTE: There is also a `env.sh` script in the root of the repo that can be sourced so that you don't have to be in the toolkit directory to run the CLI. All path-argument inputs that are relative paths are treated as relative to `<repo root>/toolkit`

## 3rd party services

Run 3rd party services via Docker. These commands setup Docker containers that should work with default configuration.

### PostGIS

Please read the instructions at [https://github.com/SAEON/postgis](https://github.com/SAEON/postgis#local-development) for setting up a local PostGIS server (and PGAdmin4 interface) via Docker
