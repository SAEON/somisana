# somisana

SOMISANA-related tooling

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Local development](#local-development)
- [Deployment](#deployment)
  - [Web application (visualizations)](#web-application-visualizations)
  - [Task server](#task-server)
  - [Persisted storage](#persisted-storage)
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

## Web application (visualizations)

The web application components (databases, and apps) are all deployed to a containerization platform. Currently this is Docker Swarm, but in the future will be some managed K8s installation (for example, maybe [Rancher](https://www.rancher.com/)). The goal is to support multiple container formats - for example Docker, and Singularly.

**_An application server_**

- 4GB memory
- 2CPUs
- 20GB storage (does not have to be backed up)

**_MongoDB database server_**

- 4GB memory
- 2CPUs
- 20GB storage (does not have to be backed up)

**_PostgreSQL database server_**

- 12GB memory
- 16 CPUs
- 500GB storage (does not have to be backed up)

**_Total_**

- 20GB memory
- 20 CPUs
- 540GB storage

## Task server

This server runs GitHub Actions pipelines on a self-hosted actions runner - it executes models. This configuration currently supports executing 2 models in serial. To execute 2 models in parallel, increase the number of CPUs to tha required for the 2 largest models, plus 1. Storage on this server is allocated for temporary storage (currently 7 days) of all model/product files/data. This allows for any archiving steps to fail up to 7 days in a row before data is lost

- 12GB memory
- 13 CPUs
- 1TB storage (does not have to be backed up)

## Persisted storage

Persisted storage should all be in the form of SAMBA mounts that can be mounted to multiple locations. This is for archiving purposes, and the amount required is (TODO - @giles to calculate).

- 5TB? (must be backed up)

# Documentation

## [Operational models](/models/)

## [Python toolkit](/toolkit/)

## [Web application](/web/)
