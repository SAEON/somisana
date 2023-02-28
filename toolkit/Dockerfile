FROM ghcr.io/saeon/somisana_geopython:3.10.6

# BUILD TIME

ARG PG_HOST
ARG PG_PORT=5432
ARG PG_USERNAME=admin
ARG PG_PASSWORD=password
ARG PG_DB=somisana_local
ARG MONGO_HOST=localhost:27017
ARG MONGO_USERNAME=admin
ARG MONGO_PASSWORD=password
ARG COPERNICUS_USERNAME
ARG COPERNICUS_PASSWORD
ARG PY_ENV=production

# RUNTIME

ENV PG_HOST=$PG_HOST
ENV PG_PORT=$PG_PORT
ENV PG_USERNAME=$PG_USERNAME
ENV PG_PASSWORD=$PG_PASSWORD
ENV PG_DB=$PG_DB
ENV MONGO_HOST=$MONGO_HOST
ENV MONGO_USERNAME=$MONGO_USERNAME
ENV MONGO_PASSWORD=$MONGO_PASSWORD
ENV COPERNICUS_USERNAME=$COPERNICUS_USERNAME
ENV COPERNICUS_PASSWORD=$COPERNICUS_PASSWORD
ENV PY_ENV=$PY_ENV

# Setup a non-root user with specific IDs
RUN groupadd -g 1999 runners \
  && useradd \
  -u 1003 \
  -g 1999 \
  -m \
  -s /bin/bash \
  somisana

USER somisana
WORKDIR /home/somisana

# Setup pipenv environment
ENV PATH="/home/somisana/.local/bin:$PATH"
ENV PIPENV_VENV_IN_PROJECT="enabled"
ENV LANG="en_US.UTF-8"
RUN pip install --user pipenv==2023.2.18

COPY --chown=somisana:somisana . .

# Bake the Toolkit CLI into the image
RUN rm -rf .venv && mkdir .venv
RUN pipenv sync

ENTRYPOINT [ "bin/somisana" ]
CMD [ "$@" ]
