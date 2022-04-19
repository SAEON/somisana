# Algoa Bay forecasting post-processing

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Quick start](#quick-start)
  - [Setup your local dev environment](#setup-your-local-dev-environment)
    - [Install binaries](#install-binaries)
    - [Setup the project](#setup-the-project)
    - [Setup your environment variables](#setup-your-environment-variables)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

First follow the instructions in the root of this repository to setup a Python environment by installing `pyenv`.

## Setup your local dev environment

The python libraries included in this project require binaries that need to be installed explicitly. Apparently... conda does this for you (I'll believe it when I see it!). Here are the steps to setup a local dev environment

### Install binaries

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

# If this doesn't work, your may have to copy the build/lib output somewhere - or at least update your PATH
```

### Setup the project

```sh
# Setup this directory as a virtual environment
pipenv --python 3.8.10

# Install dependencies
pipenv install

# Execute the post-processing script (running the script via pipenv doesn't require activating the venv)
pipenv run script
```

### Setup your environment variables

Run this command `cp .env.example .env`, and the adjust the environment variables accordingly in the `.env` file
