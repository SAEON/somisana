FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG NP_ETA=2
ARG NP_XI=2

ENV NP_ETA=$NP_ETA
ENV NP_XI=$NP_XI

RUN apt-get update \
  && apt-get install -y \
    mpich \
    make \
    libnetcdff-dev \
    libnetcdf-dev

WORKDIR /algoa-bay-forecast

# Copy the CROCO model source code
COPY croco/1.1/ croco-1.1/

# The overwrites (cppdefs.h and param.h) are
# needed both during compilation and during model execution
COPY croco/overwrites/ croco-1.1/
COPY croco/overwrites/ .

# Configure param.h
# TODO - next, refactor this to be at container run time (along with compilication)
RUN sed -e "s/\$NP_XI/3/g" -e "s/\$NP_ETA/4/g" _param.h > croco-1.1/param.h
RUN sed -e "s/\$NP_XI/3/g" -e "s/\$NP_ETA/4/g" _param.h > param.h
RUN rm _param.h
RUN rm croco-1.1/_param.h

# Create the entrypoint to run the compiled model
COPY croco/run-model/ .

# Compile the model
WORKDIR /algoa-bay-forecast/croco-1.1
RUN tar -xf croco-v1.1.tar.gz \
  && rm croco-v1.1.tar.gz \
  && chmod +x jobcomp \
  && ./jobcomp > jobcomp.log

# Move the compiled outputs
WORKDIR /algoa-bay-forecast
RUN mv \
  croco-1.1/croco \
  croco-1.1/Compile \
  croco-1.1/jobcomp.log \
  ./ \
  && rm -rf croco-1.1
