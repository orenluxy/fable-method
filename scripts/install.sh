#!/usr/bin/env bash
# Fable Method — fallback installer (when plugin installation isn't available)
# Copies skills + agents to ~/.claude/ and appends the method summary to ~/.claude/CLAUDE.md
# Detects superpowers / stoploss and reports coexistence status.
# Usage: bash scripts/install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="${HOME}/.claude"
SKILLS_DST="${CLAUDE_DIR}/skills"
AGENTS_DST="${CLAUDE_DIR}/agents"
MARKER="# === FABLE METHOD (managed block) ==="

echo "Installing Fable Method into ${CLAUDE_DIR}"
mkdir -p "${SKILLS_DST}" "${AGENTS_DST}"

# 1. Copy skills
for skill in "${REPO_DIR}/skills/"*/; do
  name="$(basename "${skill}")"
  rm -rf "${SKILLS_DST:?}/${name}"
  cp -r "${skill}" "${SKILLS_DST}/${name}"
  echo "  skill installed: ${name}"
done

# 2. Copy agents (model-routed subagents: territory-scout=haiku, report-builder=sonnet)
for agent in "${REPO_DIR}/agents/"*.md; do
  cp "${agent}" "${AGENTS_DST}/"
  echo "  agent installed: $(basename "${agent}")"
done

# 3. Append routing summary to global CLAUDE.md (idempotent via marker)
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
touch "${CLAUDE_MD}"
if ! grep -qF "${MARKER}" "${CLAUDE_MD}"; then
  cat >> "${CLAUDE_MD}" <<'BLOCK'

# === FABLE METHOD (managed block) ===
Route every non-trivial task before starting:
1. Trivial task -> just do it, no ceremony.
2. Familiar domain -> use implementation-notes skill during work; merge-quiz skill if >150 lines or production.
3. New domain -> blindspot-pass skill first, then interview-me skill, then implement with notes; merge-quiz mandatory.
4. Visual/taste task -> prototype-first skill with divergent variations before real code.
5. Vague request -> interview-me skill, one question at a time, architecture-impact first.
MODEL ECONOMY: per-step model choice happens ONLY via subagents. Delegate territory scanning to the
territory-scout agent (haiku) and change inventories to the report-builder agent (sonnet). Judgment,
interviews, quiz design and taste work stay on the main model.
CONVERGENCE GUARD: 3 failed fix attempts on the same behavior, 5+ edits to the same file, or 3+
deviations in one subsystem = STOP and replan (see convergence-guard skill). If a `stoploss` tool
is on PATH, it is authoritative — run `stoploss report` at checkpoints and before merges.
SUPERPOWERS COEXISTENCE: if the superpowers plugin is installed, it owns HOW (brainstorm/plan/execute);
fable-method owns UNKNOWNS (blindspot-pass/interview-me/prototype-first run BEFORE its planning flow,
merge-quiz gates AFTER). Never run brainstorming and blindspot-pass on the same task.
# === END FABLE METHOD ===
BLOCK
  echo "  CLAUDE.md: routing block appended"
else
  echo "  CLAUDE.md: routing block already present, skipped"
fi

# 4. Environment detection report
echo ""
echo "--- Environment detection ---"
if ls "${CLAUDE_DIR}/plugins" 2>/dev/null | grep -qi "superpowers"; then
  echo "  superpowers: DETECTED — coexistence rules active (fable-method owns unknowns, superpowers owns plan/execute)."
else
  echo "  superpowers: not found — fable-method covers the full flow natively. Nothing to install; it is NOT a dependency."
  echo "               (optional install: /plugin marketplace add obra/superpowers-marketplace, then /plugin install superpowers)"
fi
if command -v stoploss >/dev/null 2>&1; then
  echo "  stoploss:    DETECTED on PATH — it is authoritative; built-in convergence-guard defers to it."
else
  echo "  stoploss:    not found — built-in convergence-guard skill covers fix-loop/budget discipline natively."
fi

echo ""
echo "Done. Skills: fable-method, blindspot-pass, interview-me, prototype-first, implementation-notes, merge-quiz, model-economy, convergence-guard"
echo "Agents: territory-scout (haiku), report-builder (sonnet)"
echo "Note: fallback install does NOT wire the hooks (SessionStart/PostToolUse/Stop)."
echo "For hooks, install as a plugin (see README) or merge hooks/hooks.json into ~/.claude/settings.json manually."
