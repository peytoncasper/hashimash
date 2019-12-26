FROM nginx:1.17.4-alpine
COPY web/build/nginx.conf /etc/nginx/nginx.conf

COPY web/public/ /usr/share/nginx/html
COPY web/build/entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh

CMD ["/bin/sh", "-c", "/entrypoint.sh"]