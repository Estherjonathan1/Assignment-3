#!/usr/bin/env bash
# app.sh - system info and network check CLI
# Usage: app.sh <system-info|check-host|check-port|help> [args]

set -u

usage() {
  cat <<'USAGE'
Usage: app.sh <command> [args]

Commands:
  system-info               Display system information
  check-host <host>         Resolve and check a host
  check-port <host> <port>  Validate the port and check TCP connectivity
  help                      Show this help message
USAGE
}

cmd_system_info() {
  echo "===== System Information ====="
  echo "Hostname:          $(hostname)"
  echo "Current user:      $(whoami)"
  echo "Date/time:         $(date)"
  echo "Operating system:  $(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || uname -s)"
  echo "Kernel version:    $(uname -r)"
  echo "Uptime:            $(uptime -p 2>/dev/null || uptime)"
  return 0
}

cmd_check_host() {
  local HOST="${1:-}"
  if [[ -z "$HOST" ]]; then
    echo "Error: check-host requires a host argument" >&2
    return 2
  fi
  if ! [[ "$HOST" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]]; then
    echo "Error: invalid host: $HOST" >&2
    return 2
  fi
  local RESOLVED
  RESOLVED=$(getent ahosts "$HOST" 2>/dev/null | awk 'NR==1 {print $1}')
  if [[ -z "$RESOLVED" ]]; then
    echo "Resolution: FAILED - could not resolve $HOST"
    return 1
  fi
  echo "Resolved address: $RESOLVED"
  if command -v ping >/dev/null 2>&1 && ping -c 1 -W 2 "$HOST" >/dev/null 2>&1; then
    echo "Ping: OK"
    return 0
  else
    echo "Ping: FAILED"
    return 1
  fi
}

cmd_check_port() {
  local HOST="${1:-}"
  local PORT="${2:-}"
  if [[ -z "$HOST" || -z "$PORT" ]]; then
    echo "Error: check-port requires a host and a port" >&2
    return 2
  fi
  if ! [[ "$PORT" =~ ^[0-9]{1,5}$ ]] || (( 10#$PORT < 1 || 10#$PORT > 65535 )); then
    echo "Error: port must be an integer from 1 to 65535" >&2
    return 2
  fi
  if timeout 3 bash -c 'exec 3<>/dev/tcp/"$1"/"$2"' _ "$HOST" "$PORT" 2>/dev/null; then
    echo "TCP port $PORT on $HOST: OPEN"
    return 0
  else
    echo "TCP port $PORT on $HOST: CLOSED or unreachable"
    return 1
  fi
}

if [[ $# -lt 1 ]]; then
  echo "Error: missing command" >&2
  usage >&2
  exit 2
fi

COMMAND="$1"
shift

case "$COMMAND" in
  system-info)
    cmd_system_info
    exit $?
    ;;
  check-host)
    cmd_check_host "$@"
    exit $?
    ;;
  check-port)
    cmd_check_port "$@"
    exit $?
    ;;
  help)
    usage
    exit 0
    ;;
  *)
    echo "Error: unknown command: $COMMAND" >&2
    usage >&2
    exit 2
    ;;
esac
