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
pyenv install --list # Shows the available versions to install
pyenv install 3.10.4 # I chose 3.10.4
pyenv global 3.10.4 # Set your global python version to 3.10.4 (could also be locally set)
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