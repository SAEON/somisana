FROM ubuntu:20.04

# Disable apt prompts for the duration of the build only
ARG DEBIAN_FRONTEND=noninteractive

# Install basic utils
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
    libsqlite3-dev \
    libtiff-dev \
    curl \
    wget \
    libssl-dev \
    libcurl4-openssl-dev \
    libgeos++-dev \
    libgeos-3.8.0 \
    libgeos-c1v5 \
    libgeos-dev \
    libgeos-doc \
    python3-pip

# Install CMAKE
RUN curl -sSL https://cmake.org/files/v3.23/cmake-3.23.0-linux-x86_64.tar.gz | tar -xzC /opt
ENV PATH="/opt/cmake-3.23.0-linux-x86_64/bin:$PATH"

# Build proj from source
RUN wget https://download.osgeo.org/proj/proj-9.0.0.tar.gz
RUN tar xzvf proj-9.0.0.tar.gz
WORKDIR /proj-9.0.0
RUN mkdir build
WORKDIR /proj-9.0.0/build
RUN cmake ..
RUN cmake --build .
RUN cmake --build . --target install
RUN cp -a /proj-9.0.0/build/lib/. /usr/lib/

# Alias the python/pip commands to the distros python3/pip3
RUN rm /usr/bin/pip
RUN ln -s $(which python3) /usr/bin/python
RUN ln -s $(which pip3) /usr/bin/pip

# Clean the image footprint
RUN apt-get clean
RUN rm -rf /var/cache/apt/lists