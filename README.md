# davyinsa/nginx

基于官方 `nginx:alpine`（mainline）的增强镜像，GitHub Action 每周重建跟随上游安全更新。

## 特性

1. 基于官方 nginx 镜像，无锁定启动的额外初始化（秒级启动）
2. 默认安全基线：`server_tokens off`、`client_max_body_size 100m`
3. 超大请求头支持：`client_header_buffer_size 64k`、`worker_connections 10240`
4. 内置调试工具：`bash`、`vim`、`curl`、`telnet`
5. 访问/错误日志输出到 stdout/stderr（用 `docker logs` 查看）
6. 自定义维护页面内置（见下文）
7. 同时兼容 `/etc/nginx/conf.d` 与 `/etc/nginx/sites.enabled` 两种配置挂载方式

## 镜像 tag

| tag | 说明 |
|---|---|
| `latest` | 主镜像 |
| `subpath` | 与 `latest` 为同一镜像（subpath 功能已合并，用 `SUBDIR` 环境变量控制） |

Docker Hub: `davyinsa/nginx`，阿里云: `registry.cn-hangzhou.aliyuncs.com/davyin/nginx`

## 使用方式

### 方式一：挂载 sites.enabled（推荐）

```yaml
services:
  nginx:
    image: davyinsa/nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./etc/nginx-to-k8s:/etc/nginx/sites.enabled:ro
      - ./html:/var/www/html:ro   # 按需在 server 配置里引用
    restart: unless-stopped
```

### 方式二：挂载 conf.d（官方默认布局）

```yaml
    volumes:
      - ./conf.d:/etc/nginx/conf.d:ro
```

两种方式可混用。注意 `sites.enabled` 先于 `conf.d` 加载：无 `server_name`
的 server 块会成为默认 server（生产 proxy-to-dsf 依赖此行为）。

### 方式三：subpath（子路径部署）

```yaml
services:
  nginx:
    image: davyinsa/nginx:latest
    environment:
      SUBDIR: myapp        # 访问 /myapp 自动 301 到 /myapp/
```

注意：subpath 模式不要挂载覆盖 `/etc/nginx/conf.d/default.conf`。

### 维护页面

镜像内置中文维护页 `/usr/share/nginx/maintenance/index.html`，在业务 server 中按需引用：

```nginx
location @maintenance {
    root /usr/share/nginx/maintenance;
    rewrite .* /index.html break;
}
error_page 502 503 = @maintenance;
```

## 注意事项

- 配置变更后 reload：`docker exec <容器> nginx -s reload`
- 默认站点（`server_name localhost`）提供官方欢迎页/50x 页面，未匹配 Host 的请求由它兜底
- 报错页面：业务 vhost 未自定义 `error_page` 时显示 nginx 内置默认页面
