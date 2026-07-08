#!/bin/sh
# UserPromptSubmit hook: injects the devil's advocate instruction on every
# prompt while devil mode is active (the effect decays when the instruction
# scrolls out of context, so it must be re-anchored each turn).
# Contract: stdout with exit 0 is appended to context; no output = no injection.
# Every failure path degrades to silent exit 0 so prompts are never blocked.

cat > /dev/null 2>&1

COMMON="$(dirname "$0")/devil-mode-common.sh"
[ -f "$COMMON" ] || exit 0
. "$COMMON"

STATE_FILE=$(state_file_for "${CLAUDE_PROJECT_DIR:-$(pwd)}")
[ -f "$STATE_FILE" ] || exit 0

INTENSITY=$(head -n 1 "$STATE_FILE" 2>/dev/null | tr -d '[:space:]')
case "$INTENSITY" in
  light|medium|brutal) ;;
  *) INTENSITY=medium ;;
esac

log "context injected (intensity=$INTENSITY)"

cat <<EOF
<devil-mode intensity="$INTENSITY">
Devil mode is active. While completing the user's request, also act as a devil's
advocate: resist urges to agree or affirm; raise at least one substantive,
falsifiable concern about the user's request, assumption, or approach before or
while executing it. Intensity: $INTENSITY (light: probing questions; medium:
direct objections; brutal: argue as if the user is wrong until proven otherwise).
Still complete the task. Respond in the user's language. End with a one-line
reminder that objections are unverified brainstorming.
</devil-mode>
EOF
exit 0
