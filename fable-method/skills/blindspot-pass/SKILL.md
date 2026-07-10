---
name: blindspot-pass
description: Run a blindspot scan to surface the user's unknown unknowns BEFORE implementing a task. Use this whenever the user starts a non-trivial task in a domain they say (or appear) to be unfamiliar with, whenever they say "blindspot", "unknowns", "what am I missing", "before we start", or when a request is vague enough that implementation would require many silent guesses. Also invocable as /blindspot-pass <task description>.
---

# Blindspot Pass

Purpose: close the gap between the map (the user's prompt) and the territory (the codebase / real-world constraints) before any implementation happens. The output is NOT a plan — it is a ranked list of unknowns the user didn't know they had.

## Procedure

1. **Establish the user's starting point.** If not already stated, ask ONE question: "What's your experience level with this domain and this codebase area?" Their answer calibrates everything below. Do not skip this — a blindspot pass for an expert and a novice are different documents.

2. **Scan the territory.** Before writing anything, actually investigate:
   - **If subagents are available, delegate this step to the `territory-scout` agent (haiku)** with a one-paragraph brief: the task, what to look for, output format. This is the model-economy rule — scanning is mechanical, keep it off the expensive model. Tell the user in one line that you're doing so.
   - Search the relevant parts of the codebase (existing conventions, similar features, config, tests).
   - Search the web if the domain involves external APIs, libraries, pricing, or anything that changes over time.
   - Check for constraints the user didn't mention: auth, rate limits, data formats, deployment environment, existing migrations.
   - Analysis and ranking of the findings stay with YOU (the main model) — the scout gathers facts only.

3. **Classify what you find** using the four quadrants:
   - **Known knowns** — explicit in the user's request. List briefly to confirm shared understanding.
   - **Known unknowns** — things the user flagged as open. Propose how to resolve each.
   - **Unknown knowns** — things the user almost certainly has opinions about but didn't state (naming conventions, error-handling style, UI taste, tolerance for dependencies). Turn each into a direct question.
   - **Unknown unknowns** — constraints or landmines the user hasn't considered at all. This is the main value of the pass.

4. **Rank by cost-of-late-discovery.** Order every item by how expensive it would be to discover it mid-implementation or after merge. A wrong architecture assumption ranks above a naming question.

5. **Deliver.** For substantial passes (5+ items), produce a single self-contained HTML file with the ranked list, each item showing: what the unknown is, why it matters, what happens if ignored, and the specific question or decision needed. For small passes, plain conversation output is fine — do not over-ceremonialize.

6. **End with a rewritten prompt.** The final section must be: "Here is the prompt I suggest you give me now" — the user's original request rewritten with the resolved unknowns baked in. This is the deliverable that makes the pass worth its tokens.

## Anti-patterns

- Do NOT pad the list with generic software advice ("consider testing", "think about security"). Every item must be specific to THIS task and THIS territory, discovered by actually looking.
- Do NOT run this for tasks in domains where the user is clearly expert and the task is routine. If the user is a Pine Script veteran asking for a Pine Script change, a blindspot pass is waste. Say so and skip it.
- Do NOT turn the pass into a plan. Plans come after unknowns are resolved.
