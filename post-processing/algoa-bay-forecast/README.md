# Algoa Bay forecasting post-processing

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** 

- [Algoa Bay forecasting post-processing](#algoa-bay-forecasting-post-processing)
  - [Quick start](#quick-start)
  - [Deployment](#deployment)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->



# Quick start
Follow the instructions in the root of this repository to setup a Python environment by installing `pyenv` and `pipenv`. Then:

```sh
# Setup this directory as a virtual environment
pipenv --python 3.10.4

# Install dependencies
pipenv install

# Execute the post-processing script
pipenv run script
```

# Deployment

## Docker

```sh
# Build and image (from the directory with the Dockerfile)
docker build -t script_name .

# Execute an image as a container
docker run --rm script_name
```