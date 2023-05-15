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
    - [Install 3rd party dependencies](#install-3rd-party-dependencies)
    - [Conda](#conda-1)
    - [Pyenv](#pyenv-1)
  - [Run the CLI from source](#run-the-cli-from-source)
    - [Conda](#conda-2)
    - [Pyenv](#pyenv-2)
    - [Shortcut for both Conda and Pyenv](#shortcut-for-both-conda-and-pyenv)
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
  download \
  --workdir $WORKDIR/forcing-inputs \
  --matlab-env $WORKDIR/.env \
  --provider gfs \
  --domain 22,31,-37,-31
```

**_(3) Download Mercator boundary data_**

```sh
somisana \
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

**(5) _Compile and run the CROCO model_**

For this step you do need the source code currently. From the root of the repository:

```sh
export NP_ETA=4
export NP_XI=3
export TODAY=$(date +"%Y%m%d")
export YESTERDAY=$(date -d "yesterday" +"%Y%m%d")

# Build the docker image
docker build \
  -t abf_local \
  --build-arg NP_ETA=$NP_ETA \
  --build-arg NP_XI=$NP_XI \
  .

# Run the docker image
docker run \
  --rm \
  -v $WORKDIR:/algoa-bay-forecast/current \
  -v $(pwd)/models/algoa-bay-forecast/lib/grd.nc:/algoa-bay-forecast/current/croco/forcing/grd.nc \
  --cpus $(expr $NP_ETA \* $NP_XI) \
  abf_local \
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

Nothing to do here

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

### Install 3rd party dependencies

These are dependencies that should be installed using the OS package manager and don't get bundled with Python libraries

```sh
# for both Pyenv and Conda (postgis is required for the `raster2pgsql` application)
sudo apt update
sudo apt install -y postgis

# NOTE - if there are errors try "sudo apt update && sudo apt install -y libpq-dev
```

### Conda

Create a new conda environment called 'somisana' with all the dependencies via the `Condafile.yml` file

```sh
cd toolkit
conda env create -f Condafile.yml
```

Then activate the environment

```sh
conda activate somisana
```

### Pyenv

Pipenv is a wrapper over the regular pip package manager, but with a slightly better mechanism for locking dependencies of referenced libraries (I believe). Dependencies are managed via the `Pipfile` and the `Pipfile.lock`

```sh
pip install --user pipenv
```

Now install the application Python dependencies as defined in `Pipfile.lock`

```sh
cd toolkit

mkdir .venv # This is optional, and will force pipenv to create a venv directory locally
pipenv install
```

## Run the CLI from source

### Conda

With the `somisana` environment activated

```sh
cd toolkit
python __main__.py <options>
# for example
python __main__.py --version # Should print out 'development'
python __main__.py -h # This should list all the available commands
```

### Pyenv

In the case of a Pyenv environment, the `pipenv run script` command ensures the correct virtual environment is used (see the script called `script` in the `Pipfile`).

```sh
cd toolkit
pipenv run script <options>
# for example
pipenv run script --version # Should print out 'development'
pipenv run script -h # This should list all the available commands
```

### Shortcut for both Conda and Pyenv

As a shortcut to these cumbersome commands, you can register the `toolkit` command on your `$PATH` environment variable that will handle the CLI entry point for you. This checks if you're in a Conda or Pyenv environment so that the same `toolkit` command can be used in either case. The `toolkit` command should then work the same as the `somisana` command used to run the CLI via the docker image.

```sh
cd toolkit
source env.sh
toolkit --version # Should print out 'development'
toolkit -h # This should list all the available commands
```

### Setup script-environment variables

The CLI is configured via flags and environment variables (in the case of passwords/etc.). Copy the example config into you directory as `.env` and adjust accordingly. The `.env` file is kept out of source control.

```sh
cp .env.example .env
```

NOTE: There is also a `env.sh` script in the root of the repo that can be sourced so that you don't have to be in the toolkit directory to run the CLI. All path-argument inputs that are relative paths are treated as relative to `<repo root>/toolkit`
