# Playwright MCP

Playwright 浏览器自动化 MCP Server。默认按服务器 Docker 长驻服务使用，启用无头 Chromium，并通过 MCP HTTP 端点提供服务。

## 服务器部署

在服务器上进入项目目录，一条命令即可启动：

```bash
docker compose up -d --build
```

查看状态和日志：

```bash
docker compose ps
docker compose logs -f playwright-mcp
```

默认配置：

- 镜像：`sundonglai/playwright-mcp:latest`
- 容器：`playwright-mcp`
- 地址：`http://<服务器IP>:8931/mcp`
- 浏览器：Chromium headless
- 输出目录：Docker volume `playwright-output`
- 健康检查：容器内 TCP 8931
- 网络：监听所有网卡，不校验 Host

Agent 只需配置 URL，不需要自定义 `Host` 或其他 Headers：

```json
{
  "mcpServers": {
    "playwright": {
      "url": "http://<服务器IP>:8931/mcp"
    }
  }
}
```

如服务器开启了防火墙或云安全组，放行 TCP `8931` 即可。当前配置优先快速接入，
未增加认证和 HTTPS，不要直接暴露到不可信公网。

## 代理配置

### 浏览器访问代理

在项目目录创建 `.env`：

```dotenv
PLAYWRIGHT_MCP_PROXY_SERVER=http://127.0.0.1:7890
PLAYWRIGHT_MCP_PROXY_BYPASS=localhost,127.0.0.1,.internal.example.com
```

然后重启：

```bash
docker compose up -d
docker compose logs -f playwright-mcp
```

支持 `http://host:port` 和 `socks5://host:port`。这是浏览器代理，不是 Docker 镜像下载代理。

## 常用维护命令

```bash
docker compose build --no-cache
docker compose restart
docker compose logs --tail=200 playwright-mcp
docker exec -it playwright-mcp node --version
docker image ls sundonglai/playwright-mcp
docker ps --filter name=playwright-mcp
```

## 本地运行

```bash
npm ci
npx playwright install chromium
node cli.js --headless --browser chromium --port 8931 --host 127.0.0.1
```

本地地址：`http://127.0.0.1:8931/mcp`。代码实现和 MCP 工具保持原有逻辑，Docker 只负责运行环境、浏览器依赖和长驻进程。

## 常用参数

```text
--headless                  无头模式
--browser chromium          使用 Chromium
--host 0.0.0.0              监听所有网卡
--port 8931                 HTTP 端口
--allowed-hosts '*'         允许任意 Host 访问
--proxy-server <地址>       浏览器代理
--proxy-bypass <列表>       不走代理的域名
--isolated                  不持久化浏览器 profile
--ignore-https-errors       忽略证书错误（内网自签证书站点必带，已写进 Dockerfile CMD）
```

完整参数：`node cli.js --help`

## 注意事项

- Playwright MCP 具有浏览器操作能力，不是安全沙箱。
- 不要把账号密码、Cookie 或 storage state 提交到 Git。
- 更新依赖后执行 `docker compose up -d --build`。
