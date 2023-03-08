# SOMISANA Toolkit

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Quick start](#quick-start)
  - [Install Python](#install-python)
    - [Install pyenv](#install-pyenv)
    - [Install pipenv (for dependency management/locks)](#install-pipenv-for-dependency-managementlocks)
  - [Setup your local dev environment](#setup-your-local-dev-environment)
    - [Install 3rd party dependencies](#install-3rd-party-dependencies)
    - [Run the script](#run-the-script)
    - [Setup script-environment variables](#setup-script-environment-variables)
    - [Setup 3rd party services for local development](#setup-3rd-party-services-for-local-development)
      - [MongoDB](#mongodb)
      - [PostGIS](#postgis)
- [Usage examples](#usage-examples)
  - [Use compiled CLI](#use-compiled-cli)
  - [Locally](#locally)
  - [Marine Heat Wave analysis (somisana mhw)](#marine-heat-wave-analysis-somisana-mhw)
    - [somisana mhw](#somisana-mhw)
  - [Operational models (somisana ops)](#operational-models-somisana-ops)
    - [Downloading forcing data (somisana ops download)](#downloading-forcing-data-somisana-ops-download)
    - [Post-process CROCO NetCDF output (somisana ops transform)](#post-process-croco-netcdf-output-somisana-ops-transform)
    - [Load processed CROCO output into PostGIS (somisana ops load)](#load-processed-croco-output-into-postgis-somisana-ops-load)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

## Install Python

### Install pyenv
First, follow the instructions for [installing pyenv dependencies](https://github.com/pyenv/pyenv#installation). Then install `pyenv` via the [Automatic installer](https://github.com/pyenv/pyenv#automatic-installer). *Note - `pypenv` is NOT the same as `pyvenv`. See [this Stack Overflow answer](https://stackoverflow.com/a/41573588/3114742)*

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
pyenv install --list
pyenv install $PYENV_VERSION
```

### Install pipenv (for dependency management/locks)

```sh
pip install --user pipenv
```

And then update `~/.bashrc`

```sh
export PATH="$HOME/.local/bin:$PATH"
export PIPENV_VENV_IN_PROJECT="enabled"
```

Run `source ~/.bashrc` so that changes to your shell environment take effect.

## Setup your local dev environment

The python libraries included in this project require binaries that need to be installed explicitly. Apparently... conda does this for you (I'll believe it when I see it!). Here are the steps to setup a local dev environment

### Install 3rd party dependencies

```sh
# Install required binaries
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
  sqlite3 \
  libtiff-dev \
  curl \
  libssl-dev \
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

### Run the script
```sh
# In the toolkit directory, create the ".venv" directory. This hints to pipenv that you want your virtual environment to be local
mkdir .venv

# First install python dependencies
pipenv install

# And then you can run the script
pipenv run script

# Or register the somisana alias
# From the toolkit (or repo root) directory run:
source env.sh
```

### Setup script-environment variables 

Run this command `cp .env.example .env`, and the adjust the environment variables accordingly in the `.env` file

### Setup 3rd party services for local development

Run 3rd party services via Docker. These commands setup Docker containers that should work with default configuration.

#### MongoDB

Please read the instructions at [https://github.com/SAEON/mongo](https://github.com/SAEON/mongo#local-development) for setting up a local MongoDB server on a local computer

#### PostGIS

Please read the instructions at [https://github.com/SAEON/postgis](https://github.com/SAEON/postgis#local-development) for setting up a local PostGIS server (and PGAdmin4 interface) via Docker

# Usage examples

## Use compiled CLI
This is the easiest way to run the CLI, the only caveat is that all files must be in your `/home/$USER` directory, and all argument path references must be absolute paths (although you can also use command substitution `$(pwd)` in the pathname, so really not much of a caveat at all!).

Ensure that [docker](https://www.docker.com/) is installed on your system. Update your `.bash_profile` (or `.bashrc`) file with an alias to the [SOMISANA cli Docker image](https://github.com/SAEON/somisana/pkgs/container/somisana_toolkit_stable):

```sh
vi ~/.bash_profile

# Add the following line to the bottom of the file
alias somisana="docker run -v /home/$USER:/home/$USER --rm ghcr.io/saeon/somisana_toolkit_stable:latest"

# Re-source your profile configuration
source ~/.bash_profile

# Run the CLI
$ somisana
$ somisana ops download --input-path /abs/path/to/current/directory/file.nc
$ somisana ops download --input-path $(pwd)/file.nc
$ ... etc
```

NOTE: To update the docker image with a newer version, pull the image manaually:

```sh
docker pull ghcr.io/saeon/somisana_toolkit_stable:latest
```

## Locally
Working locally in the context of this repository, run `source env.sh` either from the root of the repo or from the `./toolkit` directory.

You should now be able to use the CLI via the `somisana` command:

```sh
$ somisana
```

NOTE: All path-argument inputs that are relative paths are treated as relative to `<repo root>/toolkit`

## Marine Heat Wave analysis (somisana mhw)
```sh
$ somisana mhw
```

### somisana mhw
This command is useful for downloading... TODO

```sh
$ somisana \
   mhw \
    start \
     --nc-output-path /path/to/output/file.nc
        
```

## Operational models (somisana ops)
```sh
$ somisana ops
```

### Downloading forcing data (somisana ops download)
By default, downloads are placed in `toolkit/.output/` (relative to the root of the repository). Read the CLI help output to see how to confiture this.

_**Access help**_
```sh
$ somisana ops download -h
```

_**Download Algoa Bay forcing inputs (determined by domain)**_
```sh
# GFS input data
$ somisana \
   ops \
    download \
     --provider gfs \
     --domain 22,31,-37,-31

# Mercator input data
$ somisana \
   ops \
    download \
     --provider mercator \
     --domain 22,31,-37,-31
```

### Post-process CROCO NetCDF output (somisana ops transform)
By default output is in your current directory (`output.zarr` and `output.nc`). Refer to the help to see how to configure this.

_**Access help**_
```sh
$ somisana ops transform -h
```

_**Transform Aloa Bay output**_
```sh
$ somisana \
   ops \
    transform \
     --nc-input-path /path/to/croco/output.nc \
     --grid-input-path /path/to/repo/models/algoa-bay-forecast/lib/grd.nc
```

### Load processed CROCO output into PostGIS (somisana ops load)
TODO

This CLI command needs to be re-worked to run operations on a PostgreSQL server in parallel. Currently this is achieved by running several instances of the command in parallel, which is cumbersome. Additionally alternative options to PostgreSQL are also being investigated (for example, a Zarr/client-only workflow)

_**Access help**_
```sh
$ somisana ops load -h
```