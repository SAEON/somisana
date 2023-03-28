# SOMISANA Toolkit

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Documentation](#documentation)
  - [Install the CLI](#install-the-cli)
  - [Update the CLI](#update-the-cli)
  - [Examples](#examples)
    - [Algoa Bay operational model](#algoa-bay-operational-model)
    - [Marine Heat Waves](#marine-heat-waves)
- [Local development](#local-development)
  - [Configure Python](#configure-python)
    - [Conda](#conda)
    - [Pyenv](#pyenv)
  - [Install the Toolkit dependencies](#install-the-toolkit-dependencies)
    - [Install pipenv](#install-pipenv)
    - [Install 3rd party dependencies](#install-3rd-party-dependencies)
    - [Install the Python dependencies as defined in `Pipfile.lock`](#install-the-python-dependencies-as-defined-in-pipfilelock)
  - [Run the CLI from source](#run-the-cli-from-source)
    - [Setup script-environment variables](#setup-script-environment-variables)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Documentation

The SOMISANA toolkit CLI (Command Line Interface) is packaged as a Docker image, and can be used without configuring a local dev environment.

## Install the CLI

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

## Update the CLI

Use the CLI to update itself, referencing a newer version. choose the version of the CLI to use from the listed versions https://github.com/SAEON/somisana/pkgs/container/somisana_toolkit_stable (for example, `sha-89a5f54`), and then run the update command:

```sh
somisana update --version sha-89a5f54

# Or to reset to the original installed version
somisana update --reset
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
  ghcr.io/saeon/somisana_algoa_bay_forecast_croco_stable:$TOOLKIT_VERSION \
    ./run_croco.bash \
      /algoa-bay-forecast/current \
      $TODAY \
      $YESTERDAY
```

### Marine Heat Waves

TODO

# Local development

## Configure Python

You need to be able to specify specific Python versions for the toolkit. Here are instructions for achieving this with `pyenv` or `conda`

### Conda

Install Conda and and create a virtual environment with the correct Python version. Note the `conda`-specific instructions below for running the app and managing deps with `pipenv`

### Pyenv

The pyenv tool adds entries to the beginning of your $PATH variable. So that when you type in the "python" or "pip" commands, you actually run the "pyenv" tool instead of python or pip (since the first entries on $PATH are from pyenv). Pyenv then manages python versions, and you can easily switch between python versions in your terminal. The pyenv tool just redirects the python/pip commands to specific Python versions.

- First [Install Python build dependencies](https://github.com/pyenv/pyenv/wiki#suggested-build-environment). These are required in order for Pyenv to install and build Python (I'm not sure why it's necessary for Pyenv to build Python as opposed to downloading an executable)
- Then [Install Pyenv](https://github.com/pyenv/pyenv#automatic-installer)

After installing Pyenv, follow [the instructions for configuring your shell environment](https://github.com/pyenv/pyenv#set-up-your-shell-environment-for-pyenv). Then install the correct Python version (for example `3.10.6` at the time of writing)

```sh
PYTHON_VERSION=3.10.6
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION
```

## Install the Toolkit dependencies

Python dependencies are managed as part of the source code. Some of the libraries reuire 3rd party binaries to be installed separately

### Install pipenv

Pipenv is a wrapper over the regular pip package manager, but with a slightly better mechanism for locking dependencies of referenced libraries (I believe). Dependencies are managed via the `Pipfile` and the `Pipfile.lock`

```sh
# This is the same for both Pyenv and Conda
pip install --user pipenv
```

### Install 3rd party dependencies

These are dependencies that should be installed using the OS package manager and don't get bundled with Python libraries

```sh
sudo apt update
sudo apt install -y \
  libpq-dev \
  postgis

# libpq is a binary file required by the PostgreSQL driver
# postgis is required for the `raster2pgsql` application
```

### Install the Python dependencies as defined in `Pipfile.lock`

Now install the application Python dependencies

```sh
cd toolkit

# If you are using Pyenv
mkdir .venv # This is optional, and will force pipenv to create a venv directory locally
pipenv install
source env.sh # Run this on every new terminal session
toolkit --version # Should print out 'development'

# If you are using Conda
pipenv install --system # Specify the pipenv dependency manager to use the system Python install (which is the conda environment in this case)
python __main__.py # Should print out 'development'
```

## Run the CLI from source

Run the CLI via the command `pipenv run script`. In the `Pipfile` there is a script called `script` that is executed by this command. Running Python via the `pipenv` CLI will ensure that the correct virtual environment is used. As a shortcut to this cumbersome command, you can register the `toolkit` command on your `$PATH` environment variable that will handle the CLI entry point for you.

**_In a Pyenv environment_**

```sh
cd toolkit
pipenv run script --version # Should print out 'development'
source env.sh
toolkit --version # Should print out 'development'
toolkit -h # This should list all the available commands
```

**_In a Conda environment_**

```sh
cd toolkit
python __main__.py --version # Should print out 'development'
python __main__.py -h # This should list all the available commands
```

### Setup script-environment variables

The CLI is configured via flags and environment variables (in the case of passwords/etc.). Copy the example config into you directory as `.env` and adjust accordingly. The `.env` file is kept out of source control.

```sh
cp .env.example .env
```

NOTE: There is also a `env.sh` script in the root of the repo that can be sourced so that you don't have to be in the toolkit directory to run the CLI. All path-argument inputs that are relative paths are treated as relative to `<repo root>/toolkit`
