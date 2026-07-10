#!/usr/bin/env bash
# Fable Method — Stop hook
# When Claude finishes responding, check IMPLEMENTATION_NOTES.md in the CWD.
# If there are unresolved Open Questions or a heavy Deviations section, block the stop
# once and ask Claude to surface them to the user.

NOTES="IMPLEMENTATION_NOTES.md"

# Read hook input to detect if we already blocked once (avoid infinite loop)
INPUT=$(cat)
ALREADY_ACTIVE=$(printf '%s' "$INPUT" | grep -o '"stop_hook_active":[ ]*true' | head -n1)

if [ -n "$ALREADY_ACTIVE" ]; then
  exit 0
fi

if [ ! -f "$NOTES" ]; then
  exit 0
fi

# Count non-empty, non-comment lines under "## Open questions"
OPEN_Q=$(awk '/^## Open questions/{flag=1; next} /^## /{flag=0} flag' "$NOTES" | grep -v '^\s*$' | grep -v '^<!--' | wc -l | tr -d ' ')

# Count deviation entries (lines starting with "-" under "## Deviations")
DEVIATIONS=$(awk '/^## Deviations/{flag=1; next} /^## /{flag=0} flag' "$NOTES" | grep -c '^-' || true)

if [ "${OPEN_Q:-0}" -gt 0 ]; then
  cat <<EOF
{
  "decision": "block",
  "reason": "IMPLEMENTATION_NOTES.md contains ${OPEN_Q} unresolved item(s) under 'Open questions'. Before ending, summarize them for the user and ask for resolution or explicit acknowledgment. Also mention there are ${DEVIATIONS:-0} logged deviation(s)."
}
EOF
  exit 0
fi

exit 0
