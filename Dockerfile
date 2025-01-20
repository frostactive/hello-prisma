FROM node:22.13-alpine as builder

ENV NODE_ENV production

USER node
WORKDIR /home/node
RUN apk add --no-cache openssl

COPY package*.json ./
RUN npm ci

COPY --chown=node:node . .
RUN npx prisma generate \
    && npm run build \
    && npm prune --omit=dev

# ---

FROM node:22.13-alpine

ENV NODE_ENV production

USER node
WORKDIR /home/node
RUN apk add --no-cache openssl

COPY --from=builder --chown=node:node /home/node/package*.json ./
COPY --from=builder --chown=node:node /home/node/node_modules/ ./node_modules/
COPY --from=builder --chown=node:node /home/node/dist/ ./dist/

EXPOSE 8080

CMD ["node", "dist/main.js"]
