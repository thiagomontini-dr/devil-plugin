#!/bin/sh
# Shared state definitions for the devil mode scripts. Both entry points must
# resolve the same state file for the same project; keep all key logic here.
#
# The UserPromptSubmit hook sources this file on every prompt, so the code it
# reaches (canonical_path, state_file_for, read_intensity) avoids external
# commands wherever a shell builtin can do the job.

# State and log record project paths; keep them private to the user.
umask 077

STATE_DIR="${HOME}/.claude/devil-plugin/state"
LOG_FILE="$STATE_DIR/devil-mode.log"
LOG_MAX_BYTES=65536
DEFAULT_INTENSITY=medium

# Single-generation rotation: when the log passes LOG_MAX_BYTES it becomes
# .old (replacing the previous .old), so disk usage is bounded at ~2x the cap.
rotate_log() {
  [ -f "$LOG_FILE" ] || return 0
  _size=$(wc -c < "$LOG_FILE" 2>/dev/null) || return 0
  [ "$_size" -gt "$LOG_MAX_BYTES" ] 2>/dev/null || return 0
  mv -f "$LOG_FILE" "$LOG_FILE.old" 2>/dev/null
}

# A symlinked log would redirect appends to an arbitrary file; refuse it.
log() {
  [ -L "$LOG_FILE" ] && return 0
  rotate_log
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE" 2>/dev/null
}

# The hook gets CLAUDE_PROJECT_DIR while the slash commands get a path typed
# by the model, so every spelling of the same directory (trailing slash,
# symlink, '..') must map to one state file. A directory that cannot be
# entered falls back to the given path without trailing slashes.
canonical_path() {
  (CDPATH='' cd -P -- "$1" 2>/dev/null && pwd -P) && return 0
  _path=$1
  while [ "$_path" != / ] && [ "${_path%/}" != "$_path" ]; do
    _path=${_path%/}
  done
  printf '%s' "$_path"
}

# 'tr / -' alone is not injective (/a/b-c and /a/b/c collide), so the state
# file name is the sanitized project basename plus a hash of the full path.
hash_path() {
  if command -v md5 >/dev/null 2>&1; then _hash=$(printf '%s' "$1" | md5)
  elif command -v md5sum >/dev/null 2>&1; then _hash=$(printf '%s' "$1" | md5sum)
  else _hash=$(printf '%s' "$1" | cksum)
  fi
  printf '%s' "${_hash%% *}"
}

# Expects a path already passed through canonical_path.
state_file_for() {
  _base=$(printf '%s' "${1##*/}" | tr -cs 'A-Za-z0-9._' '-')
  printf '%s/%s-%s' "$STATE_DIR" "${_base%-}" "$(hash_path "$1")"
}

# Sets INTENSITY to $1 when it is a known level, else to DEFAULT_INTENSITY.
# INTENSITY is read by the sourcing scripts.
# shellcheck disable=SC2034
set_intensity() {
  case "$1" in
    light|medium|brutal) INTENSITY=$1 ;;
    *) INTENSITY=$DEFAULT_INTENSITY ;;
  esac
}

# Sets INTENSITY from line 1 of state file $1 (the only line hooks read).
read_intensity() {
  _line=
  { read -r _line; } 2>/dev/null < "$1"
  set_intensity "$_line"
}
