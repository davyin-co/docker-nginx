FROM nfrastack/nginx:alpine
ENV CONTAINER_NAME=nginx
ENV CONTAINER_LOG_LEVEL=DEBUG
ENV NGINX_ENABLE_BLOCK_BOTS=TRUE
ENV NGINX_ENABLE_OPEN_FILE_CACHE=FALSE
ENV CONTAINER_ENABLE_MONITORING=FALSE
ENV LOGROTATE_RETAIN_DAYS=60
ENV NGINX_SITE_ENABLED=null
## MQQBrowser是QQ浏览器，默认支持。因为微信中打开链接就是这个。
## nfrastack/nginx 自 8.x 起, blockbots 配置已从 /etc/nginx/snippets/blockbots/ 迁至 /container/data/nginx/blockbots/
RUN \
    sed -i '/MQQBrowser/d' /container/data/nginx/blockbots/globalblacklist.conf && \
    sed -i '/MicroMessenge/d' /container/data/nginx/blockbots/globalblacklist.conf && \
    sed -i '/Baidu/d' /container/data/nginx/blockbots/globalblacklist.conf 