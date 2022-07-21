FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
    mpich \
    make \
    libnetcdff-dev \
    libnetcdf-dev

WORKDIR /false-bay-forecast

# Copy the CROCO model source code
COPY croco/1.1/ croco-1.1/

# The overwrites (cppdefs.h and param.h) are
# needed both during compilation and during model execution
COPY croco/overwrites/ croco-1.1/
COPY croco/overwrites/ .

# Create the entrypoint to run the compiled model
#COPY croco/run-model/ .

# Compile the model
WORKDIR /false-bay-forecast/croco-1.1
RUN tar -xf croco-v1.1.tar.gz \
  && rm croco-v1.1.tar.gz \
  && chmod +x jobcomp \
  && ./jobcomp > jobcomp.log

# Move the compiled outputs
WORKDIR /false-bay-forecast
RUN mv \
  croco-1.1/croco \
  croco-1.1/Compile \
  croco-1.1/jobcomp.log \
  ./ \
  && rm -rf croco-1.1
