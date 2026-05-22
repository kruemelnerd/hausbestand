#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"

BACKEND_PID=""
FRONTEND_PID=""
STOP_POSTGRES=0
STOP_MAILPIT=0
SHUTTING_DOWN=0

wait_for_http() {
  local url="$1"
  local name="$2"
  local timeout_seconds="${3:-120}"
  local started_at

  started_at="$(date +%s)"

  while true; do
    if curl --silent --fail "$url" >/dev/null; then
      return 0
    fi

    if (( $(date +%s) - started_at >= timeout_seconds )); then
      printf 'Timeout while waiting for %s at %s\n' "$name" "$url" >&2
      return 1
    fi

    sleep 1
  done
}

is_compose_service_running() {
  local service="$1"
  docker compose ps --status running --services 2>/dev/null | grep -Fxq "$service"
}

stop_process() {
  local pid="$1"
  local name="$2"

  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    printf 'Stopping %s...\n' "$name"
    kill -TERM "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  fi
}

cleanup() {
  local exit_code="$1"

  if (( SHUTTING_DOWN )); then
    return
  fi
  SHUTTING_DOWN=1

  stop_process "$FRONTEND_PID" "frontend"
  stop_process "$BACKEND_PID" "backend"

  if (( STOP_MAILPIT || STOP_POSTGRES )); then
    printf 'Stopping docker services...\n'
    docker compose stop mailpit postgres >/dev/null || true
  fi

  exit "$exit_code"
}

trap 'cleanup 0' INT TERM
trap 'cleanup $?' EXIT

printf 'Starting local infrastructure...\n'

if ! is_compose_service_running postgres; then
  STOP_POSTGRES=1
fi

if ! is_compose_service_running mailpit; then
  STOP_MAILPIT=1
fi

docker compose up -d --wait postgres mailpit

printf 'Starting backend on http://127.0.0.1:8080 ...\n'
(
  cd "$BACKEND_DIR"
  exec ./mvnw spring-boot:run
) &
BACKEND_PID="$!"

wait_for_http 'http://127.0.0.1:8080/actuator/health' 'backend'

printf 'Starting frontend on http://127.0.0.1:4173 ...\n'
(
  cd "$FRONTEND_DIR"
  exec npm run dev -- --host 127.0.0.1 --port 4173
) &
FRONTEND_PID="$!"

wait_for_http 'http://127.0.0.1:4173' 'frontend'

printf '\nLocal stack is ready:\n'
printf '  Frontend: http://127.0.0.1:4173\n'
printf '  Backend:  http://127.0.0.1:8080\n'
printf '  Mailpit:  http://127.0.0.1:8025\n'
printf '\nPress Ctrl+C to stop frontend and backend cleanly.\n\n'

set +e
wait -n "$BACKEND_PID" "$FRONTEND_PID"
exit_code="$?"
set -e

cleanup "$exit_code"
