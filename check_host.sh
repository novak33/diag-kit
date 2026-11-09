#!/usr/bin/env bash
#
# check_host.sh — быстрая диагностика доступности хоста.
# Проект: diag-kit
#
# Использование:
#   ./check_host.sh <host> [port]
#
# Примеры:
#   ./check_host.sh example.com
#   ./check_host.sh example.com 443
#
# Проверки:
#   1. DNS  — резолв имени (getent)
#   2. ICMP — доступность по ping (только warning: фаерволы часто режут ICMP)
#   3. TCP  — доступность порта (если порт передан вторым аргументом)
#
# Коды выхода:
#   0 — все критичные проверки прошли
#   1 — DNS не разрешился или TCP-порт закрыт

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[ OK ]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
info() { echo -e "${YELLOW}[INFO]${NC} $1"; }

usage() {
    echo "Usage: $0 <host> [port]"
    echo "Example: $0 example.com 443"
    exit 1
}

[[ $# -ge 1 ]] || usage

HOST="$1"
PORT="${2:-}"

# Защита от мусора в аргументе порта: только цифры
if [[ -n "$PORT" && ! "$PORT" =~ ^[0-9]+$ ]]; then
    fail "PORT: '$PORT' is not a number"
    exit 1
fi

echo "=== Diagnostics for host: $HOST ==="

# --- 1. DNS: резолв имени ---
IP="$(getent hosts "$HOST" 2>/dev/null | awk '{print $1; exit}')"
if [[ -z "$IP" ]]; then
    fail "DNS: could not resolve name '$HOST'"
    exit 1
fi
ok "DNS: $HOST -> $IP"

# --- 2. ICMP: ping (не критично: многие хосты блокируют ICMP) ---
if ping -c 2 -W 3 "$HOST" >/dev/null 2>&1; then
    ok "PING: host responds to ICMP"
else
    info "PING: no ICMP response (normal if firewall blocks ICMP)"
fi

# --- 3. TCP: проверка порта через /dev/tcp ---
if [[ -n "$PORT" ]]; then
    if timeout 5 bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
        ok "PORT: TCP $PORT is open"
    else
        fail "PORT: TCP $PORT is not available"
        exit 1
    fi
else
    info "PORT: port not specified, skipping TCP check"
fi

echo "=== Result: host $HOST is available ==="
