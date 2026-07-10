---
name: implementation-notes
description: Maintain an IMPLEMENTATION_NOTES.md decision log during any multi-step implementation session. Use this in EVERY session that involves writing or modifying code across more than one file, or any session expected to run longer than a few tool calls. Records decisions, deviations from plan, and open questions so nothing is silently guessed.
---

# Implementation Notes

Purpose: during long implementation runs, unknowns are discovered continuously. Without a log, they get resolved by silent guesses that the user never sees. This skill makes every guess visible and auditable.

## Setup

At the start of implementation, create (or append to) `IMPLEMENTATION_NOTES.md` in the project root or the current working directory:

```markdown
# Implementation Notes — <task name>
Session started: <date>

## Plan summary
<2–5 lines: what we agreed to build>

## Decisions
<!-- Choices made where alternatives existed. Format: what / why / alternative rejected -->

## Deviations
<!-- Any point where reality forced a departure from the plan. Format: what the plan said / what was found / conservative option taken -->

## Open questions
<!-- Unknowns deferred to the user. Must be empty or acknowledged before merge. -->
```

## Rules during implementation

1. **Every non-obvious choice gets a Decisions entry.** One line each. If you chose a library, a data structure, an error-handling strategy — log it.

2. **Deviation protocol.** When an edge case or discovered constraint forces departure from the plan:
   - Take the most **conservative** option (least code changed, most reversible).
   - Log it under Deviations with: plan said → territory showed → what I did.
   - Continue. Do NOT stop the run for deviations resolvable conservatively.
   - Exception: if the deviation invalidates the plan's architecture, STOP and ask the user. Logging is not a license to rebuild the design silently.

3. **Deviations are a convergence signal.** If the Deviations section is growing while tests are not converging, the plan is wrong — stop, summarize the deviations, and propose replanning instead of continuing to patch. Three or more deviations touching the same subsystem = automatic stop-and-replan.

4. **End of session.** Read back the file. Anything under Open questions must be either answered by the user or explicitly accepted. Summarize the log in your final message — do not assume the user will open the file.

## Anti-patterns

- Logging trivia ("used a for loop"). Log only choices where a reasonable alternative existed.
- Using the log as a diary. It is a contract-tracking device, not narration.
