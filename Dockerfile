FROM node:22-bookworm-slim

WORKDIR /app
ENV NODE_ENV=production \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

COPY package.json package-lock.json ./
RUN npm ci --omit=dev \
    && node node_modules/playwright/cli.js install-deps chromium \
    && node node_modules/playwright/cli.js install --no-shell chromium \
    && npm cache clean --force

COPY cli.js ./

RUN mkdir -p /home/node/playwright-output \
    && chown -R node:node /app /home/node/playwright-output /ms-playwright

USER node
WORKDIR /home/node

EXPOSE 8931

ENTRYPOINT ["node", "/app/cli.js"]
# --ignore-https-errors：内网被测站点普遍是自签证书，不带这个开关时 chromium
# 会直接以 ERR_CERT_AUTHORITY_INVALID 失败，页面根本打不开（连"继续前往"都点不动，
# 因为证书拦截页 chrome-error:// 不受页面级定位器控制）。
CMD ["--headless", "--browser", "chromium", "--no-sandbox", "--ignore-https-errors", "--port", "8931", "--host", "0.0.0.0", "--allowed-hosts", "*"]
