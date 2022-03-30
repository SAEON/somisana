# somisana
SOMISANA-related tooling

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Quick start](#quick-start)
  - [Setup repository tooling](#setup-repository-tooling)
  - [Setup Python](#setup-python)
    - [Install pyenv](#install-pyenv)
    - [Set global Python version](#set-global-python-version)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

## Setup repository tooling
I'm fond of the NPM tooling for managing source code - including README formatting/table-of-contents, etc. As such please install Node.js so that you can use the tools associated with managing this repository (refer to `package.json.dependencies` for more information).

```sh
# Install Node.js

# Install chomp via NPM (or install chomp via RUST (not recommended)
npm install -g chomp

# Install packages
npm install
```

## Setup Python

### Install pyenv
- Follow the instructions for [installing prerequisites](https://github.com/pyenv/pyenv#installation)
- Install pyenv via the [Automatic installer](https://github.com/pyenv/pyenv#automatic-installer)

The automatic installer concludes with instructions on adding something to `.bashrc`. However, I found that I also had to add the location of the `pyenv` installation to $PATH (`pyenv` installs a binary to `$HOME/.pyenv/`). So, make sure that `~/.bashrc` includes the following lines:

```sh
# Make the pyenv CLI available via $PATH
export PATH="$HOME/.pyenv/bin:$PATH"

# Configure pyenv virtual environment on shell start (I think this just ensures that you use Python via pyenv environments)
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Alias the 'python' and 'pip' commands to use pyenv
alias python="pyenv exec python"
alias pip="pyenv exec pip"
```

Run `source ~/.bashrc` so that changes to your shell environment take effect, and then install and set a Python version via `pyenv` to use

### Set global Python version

```sh
pyenv install --list # Shows the available versions to install
pyenv install 3.10.4 # I chose 3.10.4
pyenv global 3.10.4 # Set your global python version to 3.10.4 (could also be locally set)
```