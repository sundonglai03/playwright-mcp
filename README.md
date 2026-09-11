# Playwright MCP

Playwright 浏览器自动化 MCP Server。当前按 Docker 长驻服务使用，默认启用无头 Chromium，并通过 MCP HTTP 端点提供服务。

## Docker 启动

```bash
cd /path/to/playwright-mcp
docker compose up -d --build
docker compose logs -f playwright-mcp
docker compose ps
docker compose down
```

默认配置：

- 镜像：`sundonglai/playwright-mcp:latest`
- 容器：`playwright-mcp`
- 地址：`http://127.0.0.1:8931/mcp`
- 浏览器：Chromium headless
- 输出目录：Docker volume `playwright-output`

MCP 客户端配置：

```json
{
  "mcpServers": {
    "playwright": {
      "url": "http://127.0.0.1:8931/mcp"
    }
  }
}
```

默认只绑定宿主机回环地址。局域网部署时，将端口改为 `8931:8931`，并使用服务器实际地址；跨机器访问应放在认证和 HTTPS 反向代理后面。

## 代理配置

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
--proxy-server <地址>       浏览器代理
--proxy-bypass <列表>       不走代理的域名
--isolated                  不持久化浏览器 profile
```

完整参数：`node cli.js --help`

## 注意事项

- Playwright MCP 具有浏览器操作能力，不是安全沙箱。
- 不要把账号密码、Cookie 或 storage state 提交到 Git。
- 更新依赖后执行 `docker compose up -d --build`。
