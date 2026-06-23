# ── Stage 1: build the React frontend ──────────────────────────────────────
FROM node:20-alpine AS frontend-builder
WORKDIR /build
COPY client/package*.json ./client/
RUN cd client && npm ci
COPY client/ ./client/
RUN cd client && npm run build
# vite.config outDir is '../public', so output lands at /build/public

# ── Stage 2: production server ──────────────────────────────────────────────
FROM node:20-alpine
WORKDIR /app

COPY server/package*.json ./server/
RUN cd server && npm ci --omit=dev

COPY server/ ./server/
COPY --from=frontend-builder /build/public ./public/

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000
CMD ["node", "server/index.js"]
