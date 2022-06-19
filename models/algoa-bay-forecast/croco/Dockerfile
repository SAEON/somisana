FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
      mpich \
      make \
      libnetcdff-dev \
      libnetcdf-dev

WORKDIR /home/somisana

COPY models/algoa-bay-forecast/croco/1.1/ .
RUN chmod +x jobcomp

RUN tar -xf croco-v1.1.tar.gz \
  && rm croco-v1.1.tar.gz

# Customize the compiliation (cppdefs.h, param.h)
COPY models/algoa-bay-forecast/croco/overwrites/ .

RUN chmod u+x run_jobcomp.sh
RUN mkdir /home/somisana/exe