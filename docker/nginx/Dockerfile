FROM nginx:alpine

ARG NGINX_CONFIG

COPY ${NGINX_CONFIG}/nginx.conf /etc/nginx/nginx.conf
COPY ${NGINX_CONFIG}/conf.d /etc/nginx/conf.d