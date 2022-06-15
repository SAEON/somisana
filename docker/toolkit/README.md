# somisana/toolkit

Python scripts for pre-processing, and post-processing CROCO model output

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Scripts](#scripts)
  - [Pre-processing](#pre-processing)
  - [Post-processing](#post-processing)
- [Testing](#testing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# TODO
Include somewhere in the docs that the docker toolkit image must be built for a specific user on a specific server (i.e the userId of an existing user must be passed to the docker build as an argument). Alternatively a different volume mount can be used to the default one included in the GitHub actions yml file of this repo
# Scripts

## Pre-processing

TODO

## Post-processing

TODO

# Testing

Build and run the docker image on your local computer for testing purposes

```sh
# Build and image (from the directory with the Dockerfile)
docker build -t saeon/somisana_scripts .

# Execute an image as a container
docker run --rm saeon/somisana_scripts <script>
```
