FROM node:22-bookworm-slim

WORKDIR /app
ENV NODE_ENV=production \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

ENV http_proxy=http://192.168.34.215:909
ENV https_proxy=http://192.168.34.215:909

COPY package.json package-lock.json ./
RUN npm ci --omit=dev \
    && node node_modules/playwright/cli.js install-deps chromium \
    && node node_modules/playwright/cli.js install --no-shell chromium \
    && npm cache clean --force

ENV http_proxy=
ENV https_proxy=

COPY cli.js ./

RUN mkdir -p /home/node/playwright-output \
    && chown -R node:node /app /home/node/playwright-output /ms-playwright

USER node
WORKDIR /home/node

EXPOSE 8931

ENTRYPOINT ["node", "/app/cli.js"]
CMD ["--headless", "--browser", "chromium", "--no-sandbox", "--port", "8931", "--host", "0.0.0.0"]
