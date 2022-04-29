FROM ubuntu:20.04

##############
# USER CONFIG
##############

ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV

ARG TZ
ENV TZ=$TZ

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

# Expose the Noode.js HTTP port
EXPOSE 3000

# Start command
CMD \
  NODE_ENV=$NODE_ENV \
  TZ=$TZ \
  NODE_LOADER_CONFIG=loaders/config.js \
  node \
    --experimental-loader @node-loader/core \
    server