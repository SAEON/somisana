# saeon/python:3.8.10
The python scripts used in this repository require GIS binaries that are unpleasant to install. As such, the python image we use for running Dockerized Python scripts is built on top of the osgeo/gdal image.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents** thlorenz/doctoc)*

- [Usage](#usage)
- [Testing](#testing)
- [TODO](#todo)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Usage

# Testing
Build and run the docker image on your local computer for testing purposes

```sh
# Build and image (from the directory with the Dockerfile)
docker build -t saeon/python_local .

# Execute an image as a container
docker run --rm saeon/python_local
```

# TODO
This should probably include GDAL as well