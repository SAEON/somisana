# somisana

SOMISANA-related tooling

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Quick start](#quick-start)
  - [Setup the repository for local development](#setup-the-repository-for-local-development)
- [Deployment](#deployment)
  - [Infrastructure Requirements](#infrastructure-requirements)
    - [Application server](#application-server)
    - [MongoDB](#mongodb)
    - [PostgreSQL server](#postgresql-server)
    - [Dedicated task server](#dedicated-task-server)
  - [Deploy model-run workflows](#deploy-model-run-workflows)
  - [Deploy the visualization website](#deploy-the-visualization-website)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Quick start

Follow this guide to setup the source code on your local computer for development

## Setup the repository for local development

```sh
# Install Node.js 16.14.2 (exactly this version). I recommend doing this via nvm (https://github.com/nvm-sh/nvm)

# Install chomp
npm install -g chomp

# Initialize repository
chomp init
```

# Deployment

## Infrastructure Requirements

### Application server
The application server is a Node.js application with no special requirements
### MongoDB
TODO
### PostgreSQL server
- 8GB memory (or more)
- 8CPUs (or more)
- 1TB HD space (500GB operational data + 500GB spare for upgrades, etc). SSDs work best and will perform noticeably better, although the storage setup for the somisana.ac.za works fine to (spinners). TODO: work out how far back in time 500GB allows

### Dedicated task server
This server runs the CROCO application, as well as executing the CROCOTOOLS scripts. As a generalized runner it is integrated with the GitHub Actions tools and also handles deployment of the application server.

- 24 CPUS
- 16 GB memory
- 1TB HD space (TBC)



## Deploy model-run workflows
TODO
## Deploy the visualization website
TODO
