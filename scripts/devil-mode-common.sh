#!/bin/sh
# Shared state definitions for the devil mode scripts. Both entry points must
# resolve the same state file for the same project; keep all key logic here.

STATE_DIR="${HOME}/.claude/devil-plugin/state"
LOG_FILE="$STATE_DIR/devil-mode.log"
LOG_MAX_BYTES=65536

# Single-generation rotation: when the log passes LOG_MAX_BYTES it becomes
# .old (replacing the previous .old), so disk usage is bounded at ~2x the cap.
rotate_log() {
  [ -f "$LOG_FILE" ] || return 0
  _size=$(wc -c < "$LOG_FILE" 2>/dev/null) || return 0
  [ "$_size" -gt "$LOG_MAX_BYTES" ] 2>/dev/null || return 0
  mv -f "$LOG_FILE" "$LOG_FILE.old" 2>/dev/null
}

log() {
  rotate_log
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE" 2>/dev/null
}

# 'tr / -' alone is not injective (/a/b-c and /a/b/c collide), so the state
# file name is the sanitized project basename plus a hash of the full path.
hash_path() {
  if command -v md5 >/dev/null 2>&1; then printf '%s' "$1" | md5
  elif command -v md5sum >/dev/null 2>&1; then printf '%s' "$1" | md5sum
  else printf '%s' "$1" | cksum
  fi | awk '{print $1}'
}

state_file_for() {
  _base=$(basename "$1" | tr -c 'A-Za-z0-9._' '-' | tr -s '-')
  printf '%s/%s-%s' "$STATE_DIR" "${_base%-}" "$(hash_path "$1")"
}
