# Algoa Bay forecasting post-processing

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Quick start](#quick-start)
  - [Setup your local dev environment](#setup-your-local-dev-environment)
    - [Install 3rd party dependencies](#install-3rd-party-dependencies)
    - [Install pipenv (for dependency management/locks)](#install-pipenv-for-dependency-managementlocks)
    - [Run the script](#run-the-script)
    - [Setup script-environment variables](#setup-script-environment-variables)
    - [Setup 3rd party services for local development](#setup-3rd-party-services-for-local-development)
      - [MongoDB](#mongodb)
      - [PostGIS](#postgis)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

First follow the instructions in the root of this repository to setup a Python environment by installing `pyenv`.

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
