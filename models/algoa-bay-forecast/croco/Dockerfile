FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
      mpich \
      make \
      libnetcdff-dev \
      libnetcdf-dev

WORKDIR /croco-1.1

COPY 1.1/ .
RUN chmod +x jobcomp

RUN tar -xf croco-v1.1.tar.gz \
  && rm croco-v1.1.tar.gz

# Customize the compiliation (cppdefs.h, param.h)
COPY overwrites/ .

RUN chmod u+x run_jobcomp.sh
RUN mkdir /croco-exe
RUN ./run_jobcomp.sh