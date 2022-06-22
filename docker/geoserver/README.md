# Geoserver

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Usage](#usage)
- [Testing](#testing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Usage
```sh
# Build the image
docker image build -t geoserver .

# Run the image
docker run \
  --name geoserver \
  --rm \
  -d \
  -e GEOSERVER_ADMIN_USER=admin  \
  -e GEOSERVER_ADMIN_PASSWORD=password \
  -p 8080:8080 \
  geoserver
```
