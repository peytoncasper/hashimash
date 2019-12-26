FROM nginx:1.17.4-alpine
COPY build/nginx.conf /etc/nginx/nginx.conf

COPY public/ /usr/share/nginx/html
COPY build/entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

CMD ["/bin/sh", "-c", "/entrypoint.sh"]