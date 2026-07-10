---
name: fable-method
description: The routing logic of the Fable Method - decides which unknowns-discovery technique (blindspot-pass, interview-me, prototype-first, implementation-notes, merge-quiz) applies to the current task, and which to skip. Consult this at the START of any non-trivial task, or when the user says "fable", "the method", "how should we approach this", or asks how to structure work on a task.
---

# The Fable Method — Router

Core idea (from Thariq's "A Field Guide to Fable"): the map is not the territory. The user's prompt is a map; the codebase and real constraints are the territory. The gap is made of unknowns, and work quality is bottlenecked by how cheaply those unknowns get discovered. Every technique below is a way to pay a little now instead of a lot later.

**This is a toolbox, not a pipeline.** Applying every technique to every task is itself a failure mode — it burns tokens and time on ceremony. Route by task type:

## Decision tree

**1. Trivial task** (typo, config tweak, one-file change in familiar territory):
→ Just do it. No method overhead. Skipping the method here IS the method.

**2. Task in a domain the user knows well** (their own conventions, their own codebase area):
→ Skip blindspot-pass and prototype-first.
→ Use **implementation-notes** during the work.
→ Use **merge-quiz** at the end if >150 lines changed or production is involved.
→ Dominant unknown type: unknown knowns (their unstated conventions). Resolve by referencing their existing code, not by asking.

**3. Task in a domain new to the user** (new API, new field, first time doing X):
→ Start with **blindspot-pass**. Offer to explain the domain ("teach me, don't build yet") before building.
→ Then **interview-me** on the architecture-changing questions the pass surfaced.
→ Then plan, then implement with **implementation-notes**.
→ **merge-quiz** at the end, mandatory.
→ Dominant unknown type: unknown unknowns.

**4. Visual / taste-driven task** (UI, design, video, "make it look good"):
→ **prototype-first** before real code. Divergent variations, react-and-mix.
→ Then route the implementation itself through branch 2 or 3.
→ Dominant unknown type: unknown knowns (taste that can't be verbalized).

**5. Vague or ambiguous request** (you'd have to guess 3+ significant things to start):
→ **interview-me**, one question at a time, architecture-impact first.
→ If your questions reveal the user doesn't know the domain either → escalate to branch 3.

## Cross-cutting rules

- **Always establish the user's starting point** before choosing a branch: their experience with the domain and this part of the codebase. One question, if not evident.
- **Discovered mid-task that the branch was wrong?** Say so and switch. A blindspot found during implementation is still cheaper than one found in production.
- **Token discipline**: each technique must earn its cost. If a technique produced nothing the user didn't already know, note that and skip it next time for similar tasks.
- **Model economy** (see model-economy skill): per-step model choice happens only via subagents. Delegate territory scanning to `territory-scout` (haiku) and change inventories to `report-builder` (sonnet). Judgment, interviews, quiz design and taste work stay on the main model — delegating those is false economy.
- **Convergence guard** (see convergence-guard skill): 3 failed fix attempts on the same behavior, 5+ edits to the same file, or 3+ deviations in one subsystem = stop and replan, not another patch. If an external `stoploss` tool is on PATH, it is authoritative.

## Coexistence with the Superpowers plugin

If the superpowers plugin is installed (the SessionStart hook detects and announces this):
- **Superpowers owns HOW**: brainstorming, writing-plans, executing-plans, TDD mechanics.
- **fable-method owns UNKNOWNS**: blindspot-pass, interview-me, prototype-first run BEFORE the superpowers planning flow; their output (the rewritten prompt / resolved decisions) is the input to it. merge-quiz still gates the merge AFTER execution.
- **Never run both brainstorming and blindspot-pass on the same task** — that is doubled ceremony. Blindspot-pass replaces the research half of brainstorming.
If superpowers is NOT installed, fable-method skills cover the full flow on their own. Nothing here depends on superpowers being present.
