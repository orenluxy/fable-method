#!/usr/bin/env bash
# Fable Method — fallback uninstaller
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
SKILLS_DST="${CLAUDE_DIR}/skills"
AGENTS_DST="${CLAUDE_DIR}/agents"

for name in fable-method blindspot-pass interview-me prototype-first implementation-notes merge-quiz model-economy convergence-guard; do
  if [ -d "${SKILLS_DST}/${name}" ]; then
    rm -rf "${SKILLS_DST:?}/${name}"
    echo "removed skill: ${name}"
  fi
done

for agent in territory-scout.md report-builder.md; do
  if [ -f "${AGENTS_DST}/${agent}" ]; then
    rm -f "${AGENTS_DST}/${agent}"
    echo "removed agent: ${agent}"
  fi
done

CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
if [ -f "${CLAUDE_MD}" ]; then
  sed -i.bak '/^# === FABLE METHOD (managed block) ===$/,/^# === END FABLE METHOD ===$/d' "${CLAUDE_MD}"
  echo "CLAUDE.md: managed block removed (backup at CLAUDE.md.bak)"
fi

echo "Done."
