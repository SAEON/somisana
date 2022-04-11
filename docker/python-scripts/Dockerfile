FROM ghcr.io/saeon/somisana_geopython:latest

ARG PG_USERNAME=admin
ENV PG_USERNAME=$PG_USERNAME

ARG PG_PASSWORD=password
ENV PG_PASSWORD=$PG_PASSWORD

ARG SCRIPT_NAME=default
ENV SCRIPT_NAME=$SCRIPT_NAME

# Setup a non-root user (Python complains about this)
RUN useradd -m -s /bin/bash somisana
USER somisana
WORKDIR /home/somisana

# Setup pipenv environment
ENV PATH="/home/somisana/.local/bin:$PATH"
ENV LANG="en_US.UTF-8"

COPY --chown=somisana:somisana . .

# Install pipenv
RUN pip install --user pipenv

# Algoa Bay post-processing
WORKDIR /home/somisana/post-processing/algoa-bay-forecast
RUN pipenv sync --system

# Set working directory again to $HOME
WORKDIR /home/somisana

# Set the entry point
CMD bin/exe $SCRIPT_NAME