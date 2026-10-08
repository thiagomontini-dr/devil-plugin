#!/bin/sh
# UserPromptSubmit hook: injects the devil's advocate instruction on every
# prompt while devil mode is active (the effect decays when the instruction
# scrolls out of context, so it must be re-anchored each turn).
# Contract: stdout with exit 0 is appended to context; no output = no injection.
# Every failure path degrades to silent exit 0 so prompts are never blocked.

cat > /dev/null 2>&1

case "$0" in */*) SCRIPT_DIR=${0%/*} ;; *) SCRIPT_DIR=. ;; esac
COMMON="$SCRIPT_DIR/devil-mode-common.sh"
[ -f "$COMMON" ] || exit 0
# shellcheck source=devil-mode-common.sh
. "$COMMON"

PROJECT=$(canonical_path "${CLAUDE_PROJECT_DIR:-$PWD}")
STATE_FILE=$(state_file_for "$PROJECT")
[ -f "$STATE_FILE" ] || exit 0

# No log() here: this runs on every prompt, and the injection is fully
# determined by the state file that on/off already log.
read_intensity "$STATE_FILE"

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
