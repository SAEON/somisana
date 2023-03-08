# somisana

SOMISANA-related tooling

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Local development](#local-development)
- [Deployment](#deployment)
- [Documentation](#documentation)
  - [Operational models](#operational-models)
  - [Python toolkit](#python-toolkit)
  - [Web application](#web-application)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Local development

Please install Node.js, then in the root of the repo, run the following commands to configure global settings (such as git pre-commit hooks):

```sh
npm install -g chomp
chomp init
```

Look in the `chompfile.toml` file to see available scripts, and feel free to add your own! The pre-commit hook is defined in [.husky/pre-commit](/.husky/pre-commit). This is just a shell script and can easily be extended.

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
