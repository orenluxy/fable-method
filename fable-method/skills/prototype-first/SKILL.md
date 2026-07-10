---
name: prototype-first
description: For visual, design, or "I'll know it when I see it" tasks, generate cheap throwaway prototypes BEFORE touching real code. Use whenever the user asks for UI, dashboards, design directions, video/visual output, landing pages, or any task where their taste cannot be specified in words. Also invocable as /prototype-first <task description>.
---

# Prototype First

Purpose: the user's aesthetic and product taste is an unknown known — they have it, but cannot write it down. Words are a lossy channel for taste. Prototypes are a high-bandwidth channel. Spend cheap tokens on throwaway artifacts to extract taste before spending expensive tokens on real implementation.

## Procedure

1. **Confirm this is a taste-driven task.** Signals: the request contains words like "nice", "clean", "modern", "premium", or the deliverable is something the user will judge by looking at it. If the task has an objective spec (an API contract, a data transform), this skill does not apply — skip it.

2. **Generate divergent variations, not increments.** Produce ONE self-contained HTML file containing 3–4 genuinely different directions side by side (or navigable via tabs). "Different" means different layout philosophy, density, typography, and mood — not the same design with four accent colors. Each variation gets a short label and one sentence on what it optimizes for.

3. **Use realistic data.** Prototypes with lorem ipsum and fake numbers hide layout problems. Pull real or plausible data shapes from the actual project when available.

4. **Ask for a reaction, not a selection.** Prompt the user: "Which parts of which variation feel right? You can mix." The goal is extracting taste vectors, not picking a winner.

5. **Converge once, then implement.** After feedback, produce ONE refined prototype. When approved, implement it in the real codebase — and only then. Keep the prototype file around as the visual spec; reference it in IMPLEMENTATION_NOTES.md.

## For non-UI visual work (video, images, documents)

Same principle, adapted medium: for video, render a short low-quality proof-of-concept segment before the full pipeline; for documents/reports, produce a one-page structural mock before the full document.

## Anti-patterns

- Building variation 1 inside the real codebase "to save time" — it contaminates the code with an unvalidated direction and makes the other variations feel expensive.
- Four near-identical variations. If the user can't tell them apart at a glance, the pass was wasted.
