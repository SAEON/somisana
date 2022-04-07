FROM osgeo/gdal:ubuntu-full-3.4.2

# Disable apt prompts for the duration of the build only
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
    apt-utils \
    software-properties-common

# Upgrade apt lists
RUN apt-get update \
  && apt-get upgrade -y

# Install additional binaries
RUN apt-get update \
  && apt-get install -y \
    sqlite3 \
    libtiff-dev \
    curl \
    libssl-dev \
    libcurl4-openssl-dev \
    libgeos++-dev \
    libgeos-3.8.0 \
    libgeos-c1v5 \
    libgeos-dev \
    libgeos-doc \
    python3-pip

RUN echo $PATH

# Clean the image footprint
RUN apt-get clean
RUN rm -rf /var/cache/apt/lists