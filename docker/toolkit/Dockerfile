FROM ghcr.io/saeon/somisana_geopython:0.0.8

# BUILD TIME

ARG SOMISANA_USER_ID=1999
ARG PG_HOST
ARG PG_PORT=5432
ARG PG_USERNAME=admin
ARG PG_PASSWORD=password
ARG MONGO_HOST=localhost:27017
ARG MONGO_USERNAME=admin
ARG MONGO_PASSWORD=password
ARG COPERNICUS_USERNAME
ARG COPERNICUS_PASSWORD

# RUNTIME

ENV PG_HOST=$PG_HOST
ENV PG_PORT=$PG_PORT
ENV PG_USERNAME=$PG_USERNAME
ENV PG_PASSWORD=$PG_PASSWORD
ENV MONGO_HOST=$MONGO_HOST
ENV MONGO_USERNAME=$MONGO_USERNAME
ENV MONGO_PASSWORD=$MONGO_PASSWORD
ENV COPERNICUS_USERNAME=$COPERNICUS_USERNAME
ENV COPERNICUS_PASSWORD=$COPERNICUS_PASSWORD

# Setup a non-root user (Python complains about this)
RUN useradd -u ${SOMISANA_USER_ID} -m -s /bin/bash somisana
USER somisana
WORKDIR /home/somisana

# Setup pipenv environment
ENV PATH="/home/somisana/.local/bin:$PATH"
ENV LANG="en_US.UTF-8"

COPY --chown=somisana:somisana . .

# Install pipenv
RUN pip install --user pipenv

##
# pipenv install --system is used instead of
# pipenv sync --system because that way
# depdendencies can be shared
#
# That means that lockfiles are NOT used in this build
# process, but for now it would be too expensive in
# terms of storage space to install deps multiple times
##

# Install algoa Bay
WORKDIR /home/somisana/python/algoa-bay-forecast
RUN pipenv install --system

# Install download-forcing-inputs script
WORKDIR /home/somisana/python/download-forcing-inputs
RUN pipenv install --system

RUN mkdir /home/somisana/python/download-forcing-inputs/download-output
#RUN mkdir /home/somisana/python/download-forcing-inputs/download-output/gfs
#RUN mkdir /home/somisana/python/download-forcing-inputs/download-output/mercator
#RUN mkdir /home/somisana/python/download-forcing-inputs/download-output/mercator
WORKDIR /home/somisana

ENTRYPOINT [ "bin/exe" ]
CMD [ "default" ]
