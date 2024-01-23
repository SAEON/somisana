FROM ubuntu:16.04
# starting with this old version of ubuntu
# don't sure if it makes a difference to use a newer one?

#
# Based on Dockerfiles from 
# Andres Sepulveda (https://github.com/AndresSepulveda/docker-croco-public)
# RSoutelino (http://github.com/metocean/docker-roms-public)
# Solene Le Gac (http://forum.croco-ocean.org/question/708/croco-in-a-docker-container/#709)
#

RUN apt-get update \
&&  apt-get upgrade -y \
&&  apt-get install gfortran -y \
&&  apt-get install make -y \
&&  apt-get install libopenmpi-dev -y \
&&  apt-get install libhdf5-openmpi-dev -y \
&&  apt-get install libnetcdf-dev -y \
&&  apt-get install libnetcdff-dev -y \
&&  apt-get install bc -y \
&&  apt-get install git -y \
&&  apt-get install curl -y \
&&  apt-get install netcdf-bin -y \
&&  apt-get install nco -y \
&&  apt-get install unzip -y \
&&  apt-get install wget -y \
&&  apt-get install sudo -y \
&&  apt-get install vim -y \
&&  apt-get install octave -y \
&&  apt-get install octave-octcdf -y \
&&  apt-get clean -y

RUN useradd -m croco && echo "croco:croco" | chpasswd && adduser croco sudo

RUN mkdir -p /home/croco
RUN chown -R croco:croco /home/croco

USER croco
WORKDIR /home/croco/
RUN wget https://gitlab.inria.fr/croco-ocean/croco/-/archive/v1.3.1/croco-v1.3.1.tar.gz
RUN gzip -d croco-v1.3.1.tar.gz
RUN tar -xvf croco-v1.3.1.tar
RUN rm croco-v1.3.1.tar

WORKDIR /home/croco/
