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

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

## Install Python

### Install pyenv
First, follow the instructions for [installing pyenv dependencies](https://github.com/pyenv/pyenv#installation). Then install `pyenv` via the [Automatic installer](https://github.com/pyenv/pyenv#automatic-installer). *Note - `pypenv` is NOT the same as `pyvenv`. See [this Stack Overflow answer](https://stackoverflow.com/a/41573588/3114742)*

The automatic installer concludes with instructions on adding something to `.bashrc`. However, I found that I had to add the location of the `pyenv` installation to $PATH (`pyenv` installs a binary to `$HOME/.pyenv/`). So, I ignored the output instructions of the installer and instead adjusted `~/.bashrc` to include the following lines:

```sh
# Make the pyenv CLI available via $PATH, and set $PYENV_VERSION
export PATH="$HOME/.pyenv/bin:$PATH"
export PYENV_VERSION=3.8.10

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
pyenv install 3.11.1
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
# First install python dependencies
pipenv install

# And then you can run the script
pipenv run script
```

### Setup script-environment variables 

Run this command `cp .env.example .env`, and the adjust the environment variables accordingly in the `.env` file

### Setup 3rd party services for local development

Run 3rd party services via Docker. These commands setup Docker containers that should work with default configuration.

#### MongoDB

Please read the instructions at [https://github.com/SAEON/mongo](https://github.com/SAEON/mongo#local-development) for setting up a local MongoDB server on a local computer

#### PostGIS

Please read the instructions at [https://github.com/SAEON/postgis](https://github.com/SAEON/postgis#local-development) for setting up a local PostGIS server (and PGAdmin4 interface) via Docker
