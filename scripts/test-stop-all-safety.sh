#!/usr/bin/env bash
# Regression test: stop-all must preserve Docker resources and unrelated port listeners.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
PID=""
trap 'if [ -n "$PID" ]; then kill "$PID" 2>/dev/null || true; fi; rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin" "$TMP/ai-ugc" "$TMP/workdir"
touch "$TMP/ai-ugc/docker-compose.yml"
cat > "$TMP/bin/docker" <<'DOCKER'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$DOCKER_LOG"
DOCKER
cat > "$TMP/bin/lsof" <<'LSOF'
#!/usr/bin/env bash
printf '%s\n' "$TEST_PID"
LSOF
chmod +x "$TMP/bin/docker" "$TMP/bin/lsof"

(
  cd "$TMP/workdir"
  sleep 60
) &
PID=$!

OUTPUT="$(
  PATH="$TMP/bin:/usr/bin:/bin" \
  AI_UGC_DIR="$TMP/ai-ugc" \
  DOCKER_LOG="$TMP/docker.log" \
  TEST_PID="$PID" \
  bash "$ROOT/scripts/stop-all.sh"
)"

kill -0 "$PID" 2>/dev/null
grep -Fq "Leaving PID $PID running" <<< "$OUTPUT"
grep -Fq "compose stop" "$TMP/docker.log"
if grep -Eq '(^| )down( |$)|--remove-orphans|kill -9' "$TMP/docker.log" "$ROOT/scripts/stop-all.sh"; then
  echo "FAIL: stop-all contains a destructive container or process-kill operation" >&2
  exit 1
fi

echo "PASS: Compose uses stop (not down), and an unrelated listener is left running"
