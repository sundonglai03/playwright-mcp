FROM node:22-bookworm-slim

WORKDIR /app
ENV NODE_ENV=production \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

COPY package.json package-lock.json ./
RUN npm ci --omit=dev
RUN ./node_modules/.bin/playwright install-deps chromium
RUN ./node_modules/.bin/playwright install --no-shell chromium
RUN npm cache clean --force

COPY cli.js ./

RUN mkdir -p /home/node/playwright-output \
    && chown -R node:node /app /home/node/playwright-output /ms-playwright

USER node
WORKDIR /home/node

EXPOSE 8931

ENTRYPOINT ["node", "/app/cli.js"]
CMD ["--headless", "--browser", "chromium", "--no-sandbox", "--port", "8931", "--host", "0.0.0.0"]
