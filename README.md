# somisana

SOMISANA-related tooling

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Quick start](#quick-start)
  - [Setup repository tooling](#setup-repository-tooling)
  - [Setup Python](#setup-python)
    - [Install pyenv](#install-pyenv)
    - [Set global Python version](#set-global-python-version)
    - [Install pipenv (for dependency management/locks)](#install-pipenv-for-dependency-managementlocks)
- [Publishing](#publishing)
  - [saeon/somisana_geopython](#saeonsomisana_geopython)
  - [saeon/somisana_python-scripts](#saeonsomisana_python-scripts)
- [Deployment](#deployment)
  - [Docker](#docker)
  - [saeon/somisana_geopython](#saeonsomisana_geopython-1)
  - [saeon/somisana_python-scripts](#saeonsomisana_python-scripts-1)
    - [Pre processing scripts](#pre-processing-scripts)
    - [Post processing scripts](#post-processing-scripts)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

Follow this guide to setup the source code on your local computer for development

## Setup repository tooling

I'm fond of the NPM tooling for managing source code - including README formatting/table-of-contents, etc. As such please install Node.js so that you can use the tools associated with managing this repository (refer to `package.json.dependencies` for more information).

```sh
# Install Node.js

# Install chomp via NPM (or install chomp via RUST (not recommended)
# NOTE - The chomp binary downloads in the background after installing
# If chomp commands hang after the npm install, just wait a little while
# The binary is about 60mb
npm install -g chomp

# Initialize repository
chomp init
```

## Setup Python

I'm sure there are lots of ways to setup Python. I'm currently following the `pyenv` approach.

### Install pyenv

- Follow the instructions for [installing prerequisites](https://github.com/pyenv/pyenv#installation)
- Install pyenv via the [Automatic installer](https://github.com/pyenv/pyenv#automatic-installer)

The automatic installer concludes with instructions on adding something to `.bashrc`. However, I found that I had to add the location of the `pyenv` installation to $PATH (`pyenv` installs a binary to `$HOME/.pyenv/`). So, I ignored the output instructions of the installer and instead adjusted `~/.bashrc` to include the following lines:

```sh
# Make the pyenv CLI available via $PATH
export PATH="$HOME/.pyenv/bin:$PATH"

# Configure pyenv virtual environment on shell start
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Alias the 'python' and 'pip' commands to use pyenv
alias python="pyenv exec python"
alias pip="pyenv exec pip"
```

Run `source ~/.bashrc` so that changes to your shell environment take effect.

### Set global Python version

Install and set a Python version via `pyenv` to use

```sh
pyenv install --list
pyenv install 3.8.10
pyenv global 3.8.10
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

# Publishing

Code is bundled as Docker images. To publish versions of the tooling in this repository tag and push code appropriately.

- All the python scripts are packed as a single Docker image. Whenever the Python scripts change, a new version of the saeon/somisana_python-scripts Docker image must be pushed
- The Python scripts base image should only need to be updated when a new version of python is desired

## saeon/somisana_geopython

The tag format is `geopython.v*`

## saeon/somisana_python-scripts

The tag format is `python-scripts.v*`

# Deployment

## [Docker](docker/)
All Dockerfiles are defined in the [docker/](docker/) directory of this repository.

## saeon/somisana_geopython

## saeon/somisana_python-scripts

All python scripts are bundled to the same Docker image. To execute these scripts, run a Docker container from this image and specify the name of the script to run as an environment variables

### Pre processing scripts

### Post processing scripts

```sh
# Algoa Bay forecast
docker run \
  --rm
  -e SCRIPT_NAME=popr_algoa-bay-forecast \
  ghcr.io/saeon/somisana_python-scripts:latest
```
## saeon/somisana_web 
