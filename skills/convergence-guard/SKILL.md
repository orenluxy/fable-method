---
name: convergence-guard
description: Stop-loss discipline for implementation sessions - detect fix-loops and runaway token burn, and stop to replan instead of patching. Consult during any debugging or implementation session, especially when tests keep failing, the same file keeps being edited, or the user mentions stoploss, token budget, fix loops, or "why is this taking so long".
---

# Convergence Guard (stoploss)

Principle: the most expensive failure mode in agentic work is the **fix-loop** — repeatedly patching symptoms of a wrong plan. Tokens spent in a fix-loop are worse than wasted: they deepen commitment to a broken approach. This skill defines when to STOP.

## External tool detection — check first

At session start (the PostToolUse hook does this automatically too): if a `stoploss` command exists on PATH or a `stoploss.config.*` file exists in the project, the user has a dedicated stoploss tool. **Defer to it**: run `stoploss report` (or its documented equivalent) when checking convergence, and treat its thresholds as authoritative over the defaults below.

## Native thresholds (when no external tool is present)

Track mentally and via IMPLEMENTATION_NOTES.md:

1. **Same-file churn**: the same file edited 5+ times in one session without its tests turning green → WARNING: state it explicitly and re-examine the approach before the next edit. 8+ edits → STOP.
2. **Three-strike rule**: 3 consecutive fix attempts for the same failing test/behavior, each failing → STOP. Attempt #4 with the same strategy is forbidden.
3. **Deviation pressure**: 3+ entries under Deviations in IMPLEMENTATION_NOTES.md touching the same subsystem → STOP.
4. **Scope creep**: the session has touched 2x more files than the plan anticipated → pause and re-confirm scope with the user.

## What STOP means

STOP is not "give up." It is a mandatory replan checkpoint:

1. Freeze edits. No more code changes.
2. Summarize for the user: what was attempted, what failed each time, what the failures have in common.
3. State the hypothesis the fix-loop was implicitly betting on, and why the evidence now contradicts it.
4. Propose 2 alternative approaches (different strategy, not different patch), with cost estimates.
5. Wait for the user's call. Resuming the old strategy requires their explicit approval.

## Anti-patterns

- "One more try" past a threshold. Thresholds exist precisely because in-the-loop judgment is compromised in a loop.
- Silently resetting the counter after a partial success. A test flipping green then red again counts as a strike, not a reset.
- Treating STOP as failure. Detecting a wrong plan after 3 attempts instead of 15 is the system succeeding.
