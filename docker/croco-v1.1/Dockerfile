FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
      mpich \
      make \
      libnetcdff-dev \
      libnetcdf-dev

WORKDIR /home/somisana

COPY croco/1.1/ .
RUN chmod +x jobcomp

RUN tar -xf croco-v1.1.tar.gz \
  && rm croco-v1.1.tar.gz

# CROCO needs to be compiled for every model. These are the compilation options specific to the Algoa Bay Forecast model
#  - cppdefs.h
#  - param.h 
COPY croco/algoa_bay_compile_options/ .

RUN chmod u+x run_jobcomp.sh
RUN mkdir /home/somisana/exe