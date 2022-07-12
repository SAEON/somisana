FROM ubuntu:20.04

##############
# BUILD CONFIG
##############

ARG API
ARG NODE_ENV
ARG DEPLOYMENT_ENV
ARG TZ
ARG ALLOWED_ORIGINS
ARG MONGO_HOST
ARG MONGO_DB
ARG MONGO_USERNAME
ARG MONGO_PASSWORD
ARG TECHNICAL_CONTACT

##############
# USER CONFIG (runtime)
##############

ENV NODE_ENV=$NODE_ENV
ENV DEPLOYMENT_ENV=$DEPLOYMENT_ENV
ENV TZ=$TZ
ENV ALLOWED_ORIGINS=$ALLOWED_ORIGINS
ENV MONGO_HOST=$MONGO_HOST
ENV MONGO_DB=$MONGO_DB
ENV MONGO_USERNAME=$MONGO_USERNAME
ENV MONGO_PASSWORD=$MONGO_PASSWORD

##############
# NODE.JS
##############

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base dependencies
RUN apt-get update \
  && apt-get install \
    -yq \
    --no-install-recommends \
      apt-transport-https \
      build-essential \
      ca-certificates \
      curl \
      git \
      libssl-dev \
      wget \
        && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /root/.nvm
ENV NODE_VERSION 16.14.2

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

##############
# SOMISANA WEB
##############

WORKDIR /somisana

COPY web/ .

# Configure client (build time only)
RUN echo "API=${API}" > .env
RUN echo "NODE_ENV=${NODE_ENV}" >> .env
RUN echo "TECHNICAL_CONTACT=${TECHNICAL_CONTACT}" >> .env
RUN echo "DEPLOYMENT_ENV=${DEPLOYMENT_ENV}" >> .env

# Install deps
RUN npm install -g chomp
RUN npm ci --only=production

# Clear any caches
RUN chomp clear-cache

# Rollup the client
RUN chomp .cach

# Rollup the SSR
RUN chomp rollup:ssr

# Create import maps
RUN chomp jspm:client
RUN chomp jspm:node

# Copy static files
RUN cp -r public/* .cache/

# Expose the Noode.js HTTP port
EXPOSE 3000

# Start command
CMD \
  DEPLOYMENT_ENV=$DEPLOYMENT_ENV \
  TZ=$TZ \
  NODE_LOADER_CONFIG=loaders/config.js \
  ALLOWED_ORIGINS=$ALLOWED_ORIGINS \
  MONGO_HOST=$MONGO_HOST \
  MONGO_DB=$MONGO_DB \
  MONGO_USERNAME=$MONGO_USERNAME \
  MONGO_PASSWORD=$MONGO_PASSWORD \
  node \
    --loader @node-loader/core \
    server