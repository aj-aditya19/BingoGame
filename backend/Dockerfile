FROM node:20-alpine

ENV NODE_ENV=production
WORKDIR /app

# Dependencies pehle copy karte hain taaki Docker cache use ho sake
COPY package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi

# Baaki poora backend code (src/ folder etc.)
COPY --chown=node:node . .

# Root ki jagah normal user se chalao (safe)
USER node

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${PORT:-5000}/health || exit 1

CMD ["node", "src/server.js"]
