# somisana

SOMISANA-related tooling

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Local development](#local-development)
- [Deployment](#deployment)
  - [Web application (visualizations)](#web-application-visualizations)
  - [Task server](#task-server)
  - [Mounted storage](#mounted-storage)
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

- 8GB memory
- 4CPUs
- Minimum configurable (see below for mount requirements)

**_MongoDB database server_**

- 4GB memory
- 2CPUs
- Minimum configurable (see below for mount requirements)

**_PostgreSQL database server_**

- 12GB memory
- 16 CPUs
- Minimum configurable (see below for mount requirements)

**_Total_**

- 24GB memory
- 22 CPUs
- Minimum configurable (maybe 100GB to be safe, allow for SWAP, etc)

**NOTE:** There is still some uncertainty here depending on where various components are hosted. For example, if THREDDS or the somisana.ac.za website is hosted on SAEON infrastructure rather than on MIMS infrastructure, that effects these requirements. Also, on the SAEON infrastructure, similar resources are spread between 5 web applications (and the same resources can support a lot more web applications). These requirements for simply hosting somisana.ac.za are costly, but this is cost effective when the same infrastructure is shared.

## Task server

This server runs GitHub Actions pipelines on a self-hosted actions runner - it executes models. This configuration currently supports executing 2 models in serial. To execute 2 models in parallel, increase the number of CPUs to tha required for the 2 largest models, plus 1. Storage on this server is allocated for temporary storage (currently 7 days) of all model/product files/data. This allows for any archiving steps to fail up to 7 days in a row before data is lost

- 12GB memory
- 13 CPUs
- 1TB storage (does not have to be backed up)

## Mounted storage

Most storage requirements are in the form of SAMBA mounts that can be mounted to multiple locations

- Data archive: 5TB? (must be backed up. TODO - @giles to calculate)
- PostgreSQL: 500GB (does not have to be backed up, but should be mounted if possible)
- MongoDB: 100GB

# Documentation

## [Operational models](/models/)

## [Python toolkit](/toolkit/)

## [Web application](/web/)
