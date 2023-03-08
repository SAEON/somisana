# somisana

SOMISANA-related tooling

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Quick start](#quick-start)
  - [Configure the repository](#configure-the-repository)
- [Deployment](#deployment)
- [Documentation](#documentation)
  - [Operational models](#operational-models)
  - [Python toolkit](#python-toolkit)
  - [Web application](#web-application)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

Follow this guide to setup the source code on your local computer for development

## Configure the repository

There are some general tools that require Node.js - please install Node.js `v19.7.0`. Then in the root of the repo, run the following:

```sh
npm install -g chomp
chomp init
```

Look in the `chompfile.toml` file to see available scripts. Running `chomp init` should configure a default Git commit message template and register some pre-commit hooks.

# Deployment

The following infrastructure is required:

**_An application server_**

- 4GB memory
- 2CPUs

**_MongoDB database server_**

- 4GB memory
- 2CPUs

**_PostgreSQL database server_**

- 12GB memory
- 16 CPUs

**_Dedicated task server_**
This server runs GitHub Actions pipelines on a self-hosted actions runner.

- 12GB memory
- 16 CPUs

**_Volume mounts_**
Volumes should be mounted to the GitHub runner server for temporary files, to the application server for archiving products, and to the PostgreSQL server for a working dataset

- 1TB for GitHub Runner
- Several TB for the application server
- 1TB for PostgreSQL

# Documentation

## [Operational models](/models/)

## [Python toolkit](/toolkit/)

## [Web application](/web/)
