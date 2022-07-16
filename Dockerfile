FROM nginx
RUN { \
      echo 'server_tokens off;'; \
      echo 'client_max_body_size 100m;'; \
    } > /etc/nginx/conf.d/server-token-off.conf
ADD nginx.conf /etc/nginx/
ADD subpath.sh /docker-entrypoint.d/
ADD default.conf /etc/nginx/conf.d/
