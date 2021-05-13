FROM nginx
RUN { \
      echo 'server_tokens off;'; \
    } > /etc/nginx/conf.d/server-token-off.conf
