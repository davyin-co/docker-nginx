#!/bin/sh
# 反向代理模式：通过环境变量生成 proxy vhost 到 /etc/nginx/sites.enabled/
# 生效条件（满足其一）：
#   NGINX_MODE=proxy
#   NGINX_ENABLE_REVERSE_PROXY=TRUE   （也接受 1/yes/on，大小写不敏感）
# 必需变量：NGINX_PROXY_URL，如 http://192.168.168.100:8080
# 可选变量：NGINX_SERVER_NAME，默认 _（捕获全部 Host）
set -e

is_true() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" in
    1|true|yes|on) return 0 ;;
    *) return 1 ;;
  esac
}

enabled=""
[ "$NGINX_MODE" = "proxy" ] && enabled=1
is_true "$NGINX_ENABLE_REVERSE_PROXY" && enabled=1

[ -z "$enabled" ] && exit 0

if [ -z "$NGINX_PROXY_URL" ]; then
  echo "reverse-proxy: NGINX_PROXY_URL is required but not set" >&2
  exit 1
fi

SERVER_NAME=${NGINX_SERVER_NAME:-_}

cat > /etc/nginx/sites.enabled/reverse-proxy.conf <<EOF
# 由 reverse-proxy.sh 根据环境变量生成，请勿手工编辑
server {
    listen       80;
    listen  [::]:80;
    server_name  $SERVER_NAME;

    location / {
        proxy_pass $NGINX_PROXY_URL;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

echo "reverse-proxy: generated /etc/nginx/sites.enabled/reverse-proxy.conf (server_name=$SERVER_NAME proxy_pass=$NGINX_PROXY_URL)"
