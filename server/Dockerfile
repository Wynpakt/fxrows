FROM node:22-alpine

WORKDIR /app

ENV NODE_ENV=production \
  PORT=8787

COPY package.json ./
COPY src ./src

RUN mkdir -p data && chown -R node:node /app

USER node

EXPOSE 8787

CMD ["node", "src/index.js"]
