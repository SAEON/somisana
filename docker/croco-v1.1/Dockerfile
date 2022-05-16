FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  apt-get install -y \
    mpich \
    make \
    libnetcdff-dev \
    libnetcdf-dev

WORKDIR /somisana

COPY croco/1.1/ .
RUN chmod +x jobcomp

#Copy cppdef.h and param.h from algoa_bay_compile_options [cppdefs.h and param.h for algoa bay have been added to croco/algoa_bay_compile_options] 
COPY croco/algoa_bay_compile_options/ .

RUN tar -xf croco-v1.1.tar.gz && rm  croco-v1.1.tar.gz

RUN ./jobcomp>jobcomp.log