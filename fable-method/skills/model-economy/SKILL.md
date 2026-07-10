---
name: model-economy
description: Route each step of a workflow to the cheapest model that can do it well, using subagents with explicit model assignments. Consult whenever planning multi-step work, whenever the user mentions saving tokens/cost, choosing models, or "model economy", and whenever a fable-method skill involves scanning, drafting, or bulk mechanical work.
---

# Model Economy

Principle: a standing instruction like "use the cheapest model" does nothing by itself — the main session model cannot swap itself. The ONLY mechanism for per-step model choice is **delegation to subagents with an explicit `model:` field**. Cost savings happen when mechanical work is pushed down and judgment work stays up.

## Delegation table

| Step type | Route to | Why |
|---|---|---|
| Territory scanning: codebase exploration, convention extraction, web fact-finding | `territory-scout` (haiku) | Wide, read-only, mechanical. Findings > prose. |
| Change inventory, diff summarization, test-run reporting | `report-builder` (sonnet) | Mechanical but needs accurate code reading. |
| Bulk transformations with a clear spec (renames, format conversions, boilerplate) | subagent on haiku/sonnet, spec written by main model | Spec quality is the judgment; execution is mechanical. |
| Architecture decisions, interviews, quiz design, deviation calls, anything user-facing | main model, no delegation | Judgment and full context required. Delegating this is false economy. |
| Prototype variations (prototype-first) | main model | Taste extraction IS the point; cheap models produce generic variations that waste the pass. |

## Rules

1. **Never delegate judgment to save tokens.** A wrong architectural call costs more than every scan in the project combined. Cheap models get facts-gathering, not decisions.
2. **Write the brief before delegating.** A subagent with a vague brief returns noise you'll re-do on the expensive model — negative savings. One paragraph: what to look for, where, output format.
3. **One round-trip.** If a subagent's output needs a second clarification round, absorb the task into the main model instead — the coordination overhead has eaten the savings.
4. **Report the routing.** When you delegate, tell the user in one line: "scanning via territory-scout (haiku) to keep main context lean." This keeps the economy auditable.
5. **If the environment has no subagent support** (e.g., claude.ai), state that model routing is unavailable and proceed on the current model — do not pretend to route.
