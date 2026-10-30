#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/curl" <<'CURL'
#!/usr/bin/env sh
printf '000'
CURL
chmod +x "$TMP/curl"

OUTPUT="$(
  env -i \
    PATH="$TMP:/usr/bin:/bin" \
    HOME="${HOME:-/tmp}" \
    SHELL=/bin/bash \
    AI_UGC_DIR=/tmp/ai-ugc \
    N8N_HOST=localhost \
    N8N_PORT=5678 \
    N8N_PROTOCOL=http \
    N8N_ENCRYPTION_KEY=sentinel-secret \
    N8N_USER_MANAGEMENT_JWT_SECRET=sentinel-secret \
    ANTHROPIC_API_KEY=sentinel-secret \
    GITHUB_TOKEN=sentinel-secret \
    WEBHOOK_URL='https://example.test/webhook/secret?token=sentinel-secret' \
    CONTENT_URL='https://user:pass@example.test?token=sentinel-secret' \
    bash "$ROOT/scripts/debug-env.sh"
)"

if grep -q 'sentinel-secret\|user:pass\|webhook/secret' <<<"$OUTPUT"; then
  echo "FAIL: debug output exposed a secret-like value" >&2
  exit 1
fi

grep -q 'N8N_HOST=localhost' <<<"$OUTPUT"
grep -q 'N8N_PORT=5678' <<<"$OUTPUT"
grep -q 'N8N_ENCRYPTION_KEY=\[REDACTED\]' <<<"$OUTPUT"
grep -q 'N8N_USER_MANAGEMENT_JWT_SECRET=\[REDACTED\]' <<<"$OUTPUT"
grep -q 'ANTHROPIC_API_KEY=\[REDACTED\]' <<<"$OUTPUT"
grep -q 'GITHUB_TOKEN=\[REDACTED\]' <<<"$OUTPUT"
grep -q 'WEBHOOK_URL=\[REDACTED\]' <<<"$OUTPUT"
grep -q 'CONTENT_URL=\[REDACTED\]' <<<"$OUTPUT"

echo "PASS: debug environment output keeps safe settings and redacts secret-like values"
