---
name: merge-quiz
description: Before merging or deploying the output of a long session, generate a change report with a comprehension quiz the user must pass. Use whenever the user says "merge", "deploy", "we're done", "wrap up", or at the end of any session that modified more than ~150 lines or touched production-relevant code. Also invocable as /merge-quiz.
---

# Merge Quiz

Purpose: after a long session, the user's mental model of the changes is a map that has drifted from the territory. Merging on a drifted map is how production incidents happen. The quiz forces the map to be re-synced before the merge button exists.

## Procedure

1. **Generate the change report** as a single self-contained HTML file. **If subagents are available, delegate the mechanical inventory (diff stats, file list, test run, notes import) to the `report-builder` agent (sonnet)** and build the report from its skeleton — the risk register and the quiz remain yours. If an external `stoploss` tool is on PATH, run its report and include the numbers. Report sections:
   - **Summary**: what was built, in 5 lines max.
   - **Change inventory**: every file touched, grouped by subsystem, with one line per file on what changed and why.
   - **Behavior changes**: what a user/consumer of this system will experience differently. This section matters more than the file list.
   - **Risk register**: the 3 changes most likely to break something, and how to verify each.
   - **Decisions & Deviations**: imported from IMPLEMENTATION_NOTES.md if it exists.

2. **Append the quiz** at the bottom of the report: 5–8 questions testing whether the user actually understands the changes. Mix of:
   - "What happens now when X?" (behavior)
   - "Why was Y chosen over Z?" (decisions)
   - "Which file would you edit to change W?" (territory knowledge)
   - At least one question about a deviation, if any exist.
   Questions must be answerable only by someone who understands the changes — not by pattern-matching the report's summary.

3. **Grade strictly.** The user answers in chat. A wrong or fuzzy answer means: explain the correct answer with a pointer to the relevant code, then re-ask a variant. Do not proceed to merge steps until all answers are solid.

4. **Only after a clean pass**: provide the merge/deploy commands or perform them if asked.

## Calibration

- Session touched < ~50 lines in familiar territory: skip the quiz, offer a 3-line summary instead. The gate exists for long sessions, not for typo fixes. Say explicitly that you're skipping it and why.
- Production systems (databases, payment, live servers): the quiz is mandatory regardless of size, and the risk register must include a rollback plan.

## Anti-patterns

- Softball questions the user can answer from the summary alone. The quiz must probe the territory, not the map.
- Treating a failed quiz as a formality. A failed quiz is the system working.
