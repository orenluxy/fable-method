#!/usr/bin/env bash
# Fable Method — SessionStart hook
# Injects routing reminder + adaptive detection of superpowers and stoploss.

# --- Detect external tools ---
SP_NOTE="Superpowers plugin NOT detected: fable-method skills own the full workflow (blindspot-pass replaces brainstorm/research, interview-me replaces requirements gathering)."
if ls "${HOME}/.claude/plugins" 2>/dev/null | grep -qi "superpowers"; then
  SP_NOTE="Superpowers plugin DETECTED. Precedence rules: superpowers owns HOW to plan and execute (brainstorming, writing-plans, executing-plans, TDD); fable-method owns UNKNOWNS DISCOVERY. Never run both brainstorming and blindspot-pass on the same task - run blindspot-pass first and feed its rewritten prompt into the superpowers planning flow. merge-quiz still gates the merge."
fi

SL_NOTE="No external stoploss tool detected: the built-in convergence-guard skill and PostToolUse hook enforce fix-loop thresholds (5-edit warning, 8-edit stop, three-strike rule)."
if command -v stoploss >/dev/null 2>&1; then
  SL_NOTE="External stoploss tool DETECTED on PATH. It is authoritative for convergence/budget thresholds - run 'stoploss report' at checkpoints and before merge-quiz. The built-in guard defers to it automatically."
fi

python3 - "$SP_NOTE" "$SL_NOTE" <<'PYEOF'
import json, sys
sp, sl = sys.argv[1], sys.argv[2]
ctx = (
  "FABLE METHOD ACTIVE. Route every non-trivial task before starting: "
  "(1) trivial -> just do it; "
  "(2) familiar domain -> implementation-notes during, merge-quiz if >150 lines/production; "
  "(3) new domain -> blindspot-pass first, then interview-me, then implement with notes, merge-quiz mandatory; "
  "(4) visual/taste task -> prototype-first with divergent variations; "
  "(5) vague request -> interview-me, one question at a time, architecture-impact first. "
  "MODEL ECONOMY: per-step model choice happens ONLY via subagents - delegate territory scanning to territory-scout (haiku) and change inventories to report-builder (sonnet); judgment, interviews and quiz design stay on the main model. "
  "CONVERGENCE: maintain IMPLEMENTATION_NOTES.md (Decisions/Deviations/Open questions); 3 failed fix attempts on the same behavior or 3+ deviations in one subsystem = stop and replan. "
  "Do NOT apply ceremony to trivial tasks. | " + sp + " | " + sl
)
print(json.dumps({
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": ctx
  }
}))
PYEOF
exit 0
