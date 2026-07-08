FROM oven/bun:1.1-alpine
WORKDIR /app

# Install dependencies
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile --production

# Copy source + web assets
COPY src/ src/
COPY web/ web/

EXPOSE 3000

# Bun runs TypeScript natively — no build step needed
# serviceAccountKey.json is mounted as volume at runtime
CMD ["bun", "src/index.ts"]
