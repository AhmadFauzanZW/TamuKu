#!/bin/sh
# Write runtime config.js from container environment variables
# Runs at container startup via /docker-entrypoint.d/

set -e

api_base_url="${API_BASE_URL:-${VITE_BACKEND_URL:-http://localhost:3000}}"
api_key="${API_KEY:-${VITE_API_KEY:-}}"

cat <<EOF > /usr/share/nginx/html/config.js
window.__APP_CONFIG__ = {
  apiBaseUrl: "${api_base_url}",
  apiKey: "${api_key}",
};
EOF

echo "✅ Runtime config injected: API=${api_base_url}"
