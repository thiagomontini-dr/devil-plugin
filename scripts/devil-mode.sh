#!/bin/sh
# Devil mode state manager. State lives outside the plugin dir because the
# plugin dir is read-only when installed from a marketplace.
#
# usage: devil-mode.sh on [light|medium|brutal] [project-dir]
#        devil-mode.sh off [project-dir]
#        devil-mode.sh status [project-dir]
#        devil-mode.sh cleanup
#
# project-dir falls back to CLAUDE_PROJECT_DIR, then to pwd. Slash commands
# must pass it explicitly: the Bash tool does not export CLAUDE_PROJECT_DIR
# and its working directory can drift away from the project root.
#
# State file format: line 1 is the intensity (the only line hooks read),
# line 2 is the project path, used by cleanup to detect orphaned state.

COMMON="$(dirname "$0")/devil-mode-common.sh"
[ -f "$COMMON" ] || { echo "devil mode: missing $COMMON"; exit 0; }
. "$COMMON"

case "$1" in
  on) PROJECT="${3:-${CLAUDE_PROJECT_DIR:-$(pwd)}}" ;;
  *)  PROJECT="${2:-${CLAUDE_PROJECT_DIR:-$(pwd)}}" ;;
esac
STATE_FILE=$(state_file_for "$PROJECT")

mkdir -p "$STATE_DIR" 2>/dev/null

validate_intensity() {
  case "$1" in
    light|medium|brutal) printf '%s' "$1" ;;
    *) printf 'medium' ;;
  esac
}

case "$1" in
  on)
    [ -d "$STATE_DIR" ] || { echo "devil mode: cannot create state dir $STATE_DIR"; exit 0; }
    INTENSITY=$(validate_intensity "${2:-medium}")
    printf '%s\n%s\n' "$INTENSITY" "$PROJECT" > "$STATE_FILE"
    echo "devil mode ON ($INTENSITY) for $PROJECT"
    log "on ($INTENSITY) for $PROJECT"
    ;;
  off)
    if [ -f "$STATE_FILE" ]; then
      rm -f "$STATE_FILE"
      echo "devil mode OFF for $PROJECT"
      log "off for $PROJECT"
    else
      echo "devil mode was not on for $PROJECT"
      log "off no-op for $PROJECT"
    fi
    ;;
  status)
    if [ -f "$STATE_FILE" ]; then
      INTENSITY=$(validate_intensity "$(head -n 1 "$STATE_FILE" 2>/dev/null | tr -d '[:space:]')")
      echo "devil mode is ON ($INTENSITY) for $PROJECT. Disable with /devil:off"
    fi
    ;;
  cleanup)
    REMOVED=0
    for f in "$STATE_DIR"/*; do
      [ -f "$f" ] || continue
      case "$f" in *.log|*.log.old) continue ;; esac
      DIR=$(sed -n '2p' "$f" 2>/dev/null)
      if [ -n "$DIR" ] && [ ! -d "$DIR" ]; then
        rm -f "$f"
        echo "removed orphan state for $DIR"
        log "cleanup removed orphan for $DIR"
        REMOVED=$((REMOVED + 1))
      fi
    done
    echo "cleanup done: $REMOVED orphan state file(s) removed"
    ;;
  *)
    echo "usage: devil-mode.sh {on [light|medium|brutal]|off|status|cleanup} [project-dir]"
    log "invalid usage: $*"
    ;;
esac

exit 0
