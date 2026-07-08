FROM oven/bun:latest AS base
WORKDIR /app

# Install dependencies first (cache layer)
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile --production

# Copy source + web assets
COPY src/ src/
COPY web/ web/

# serviceAccountKey.json is mounted via volume at runtime, NOT copied into image

RUN bun run build

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["bun", "run", "start"]
