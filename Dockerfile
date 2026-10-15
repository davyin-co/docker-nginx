FROM nginx:alpine

## 常用调试工具（alpine 默认无 bash，telnet 在 busybox-extras 里）
RUN apk add --no-cache bash vim curl busybox-extras

## 主配置：官方 nginx.conf 基础上同时兼容两种配置挂载方式：
##   - /etc/nginx/conf.d         （官方默认布局，nginx-k8s 场景挂载）
##   - /etc/nginx/sites.enabled  （站点配置挂载）
ADD nginx.conf /etc/nginx/nginx.conf
RUN mkdir -p /etc/nginx/sites.enabled

## subpath 支持：设置 SUBDIR 环境变量后，entrypoint 会把 default.conf
## 中的 fake-subdir-placeholder 替换为实际子路径；不设置则为 no-op。
ADD subpath.sh /docker-entrypoint.d/subpath.sh
RUN chmod +x /docker-entrypoint.d/subpath.sh

## 反向代理支持：NGINX_MODE=proxy 或 NGINX_ENABLE_REVERSE_PROXY=TRUE 时，
## entrypoint 按 NGINX_PROXY_URL / NGINX_SERVER_NAME 生成 proxy vhost；
## 不设置则为 no-op。
ADD reverse-proxy.sh /docker-entrypoint.d/reverse-proxy.sh
RUN chmod +x /docker-entrypoint.d/reverse-proxy.sh

## 默认站点（subpath 场景）+ 默认安全/上传限制
ADD default.conf /etc/nginx/conf.d/default.conf
RUN { \
      echo 'server_tokens off;'; \
      echo 'client_max_body_size 100m;'; \
    } > /etc/nginx/conf.d/server-token-off.conf

## 自定义维护页面：业务 vhost 中通过
##   location @maintenance { root /usr/share/nginx/maintenance; rewrite .* /index.html break; }
## 或 error_page 502 = @maintenance; 等方式引用
ADD install/assets/nginx/maintenance/index.html /usr/share/nginx/maintenance/index.html
