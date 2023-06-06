FROM osgeo/gdal:ubuntu-small-3.6.2

# Disable apt prompts for the duration of the build only
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get upgrade -yq \
  && apt-get install -yq \
    apt-utils \
    software-properties-common

# Install additional binaries
RUN apt-get update \
  && apt-get install -yq \
    python3-pip \
    postgis \
    nco

# Clean up the image
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*