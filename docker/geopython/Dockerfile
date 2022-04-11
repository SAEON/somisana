FROM osgeo/gdal:ubuntu-full-3.4.2

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

# TODO
# The GDAL image already contains proj 9.0.0
# But I get -lproj errors when trying to install
# cartopy, that I don't know how to fix

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

# Clean up the image (TODO - I'm sure this can be improved)
RUN rm -rf /proj-9.0.0.tar.gz
RUN rm -rf /proj-9.0.0
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*