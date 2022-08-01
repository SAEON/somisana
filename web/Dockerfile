FROM node:16.14.2

##############
# BUILD CONFIG
##############

ARG ALLOWED_ORIGINS
ARG API
ARG DEPLOYMENT_ENV
ARG MONGO_DB
ARG MONGO_HOST
ARG MONGO_PASSWORD
ARG MONGO_USERNAME
ARG NODE_ENV
ARG NODE_LOADER_CONFIG=loaders/config.js
ARG TECHNICAL_CONTACT
ARG TILESERV_BASE_URL
ARG TZ

##############
# RUNTIME
##############

ENV ALLOWED_ORIGINS=$ALLOWED_ORIGINS
ENV DEPLOYMENT_ENV=$DEPLOYMENT_ENV
ENV MONGO_DB=$MONGO_DB
ENV MONGO_HOST=$MONGO_HOST
ENV MONGO_PASSWORD=$MONGO_PASSWORD
ENV MONGO_USERNAME=$MONGO_USERNAME
ENV NODE_ENV=$NODE_ENV
ENV NODE_LOADER_CONFIG=$NODE_LOADER_CONFIG
ENV TZ=$TZ

##############
# SOMISANA WEB
##############

WORKDIR /somisana

COPY . .

# Configure client (build time only)
RUN echo "API=${API}" > .env
RUN echo "NODE_ENV=${NODE_ENV}" >> .env
RUN echo "TECHNICAL_CONTACT=${TECHNICAL_CONTACT}" >> .env
RUN echo "DEPLOYMENT_ENV=${DEPLOYMENT_ENV}" >> .env
RUN echo "TILESERV_BASE_URL=${TILESERV_BASE_URL}" >> .env

# Install deps
RUN npm install -g chomp \
  & npm ci --only=production

# Build app using chomp
RUN chomp build:deployment

# Expose the Noode.js HTTP port
EXPOSE 3000

# Start command
ENTRYPOINT [ "node" ]
CMD ["--no-warnings", "--loader", "@node-loader/core", "server"]