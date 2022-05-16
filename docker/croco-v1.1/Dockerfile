#Using base ubuntu 20.04
FROM ubuntu:20.04

#Needed to avoid tzdata interaction
ARG DEBIAN_FRONTEND=noninteractive
#ENV TZ=Europe/Moscow

#Updates recommended seems like it's needed to install the below packages
RUN apt-get update -y

#Install netcdf libaries and mpi for complier [mpich make libnetcdf-dev libnetcdff-dev]
RUN apt-get install -y mpich make libnetcdff-dev libnetcdf-dev

#Create and cd to directory call somisana
WORKDIR /somisana

#Copy croco source dir to somisana dir 
COPY croco/1.1/ .

#Copy cppdef.h and param.h from algoa_bay_compile_options [cppdefs.h and param.h for algoa bay have been added to croco/algoa_bay_compile_options] 
COPY croco/algoa_bay_compile_options/ .

#Unzip croco-v1.1 to access ocean dir and remove zipped dir 
RUN tar -xf croco-v1.1.tar.gz && rm  croco-v1.1.tar.gz

#Make the jobcomp script excutable 
RUN chmod +x jobcomp

#Complie the croco model and write to log file 
RUN ./jobcomp>jobcomp.log
RUN pwd
RUN ls
