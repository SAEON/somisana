FROM ghcr.io/saeon/somisana_geopython:0.0.8

ARG PG_HOST
ENV PG_HOST=$PG_HOST

ARG PG_PORT=5432
ENV PG_PORT=$PG_PORT

ARG PG_USERNAME=admin
ENV PG_USERNAME=$PG_USERNAME

ARG PG_PASSWORD=password
ENV PG_PASSWORD=$PG_PASSWORD

ARG MONGO_HOST=localhost:27017
ENV MONGO_HOST=$MONGO_HOST

ARG MONGO_USERNAME=admin
ENV MONGO_USERNAME=$MONGO_USERNAME

ARG MONGO_PASSWORD=password
ENV MONGO_PASSWORD=$MONGO_PASSWORD

ARG SCRIPT_NAME=default
ENV SCRIPT_NAME=$SCRIPT_NAME

ARG COPERNICUS_USERNAME
ENV COPERNICUS_USERNAME=$COPERNICUS_USERNAME

ARG COPERNICUS_PASSWORD
ENV COPERNICUS_PASSWORD=$COPERNICUS_PASSWORD

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

# Install algoa Bay
WORKDIR /home/somisana/python/algoa-bay-forecast
RUN pipenv sync --system

# Install download-forcing-inputs script
WORKDIR /home/somisana/python/download-forcing-inputs
RUN pipenv sync --system

# Set working directory again to $HOME
WORKDIR /home/somisana

# Set the entry point
CMD bin/exe $SCRIPT_NAME