# Unprivileged NGINX image: runs as uid 101 and listens on 8080
FROM nginxinc/nginx-unprivileged:1.30-alpine
COPY public/ /usr/share/nginx/html/
USER 101
EXPOSE 8080
