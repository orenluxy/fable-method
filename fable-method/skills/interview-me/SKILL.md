---
name: interview-me
description: Interview the user one question at a time to resolve ambiguities before or during implementation. Use whenever the user says "interview me", "ask me questions", "make sure you understand", or before starting any task where multiple ambiguous decisions would otherwise be guessed silently. Also invocable as /interview-me <task description>.
---

# Interview Me

Purpose: convert the user's unknown knowns (implicit preferences and constraints they have but didn't state) into known knowns — cheaply, before implementation makes them expensive.

## Rules

1. **One question per message.** Never batch. The user's answer to question N should be allowed to change question N+1.

2. **Prioritize by architectural impact.** Ask first the questions whose answers would change the structure of the solution. Cosmetic and naming questions come last or not at all. Before asking anything, internally rank your candidate questions by: "if the answer surprises me, how much of the design changes?"

3. **Every question must be paired with your current best guess.** Format: state the question, then "My default if you don't care: X, because Y." This lets the user answer with one word ("default") and keeps the interview fast.

4. **Hard cap: 7 questions.** If you have more than 7, your top 7 by architectural impact. If you genuinely can't get below 7, that's a signal the task should be split — say so.

5. **Stop early.** The moment remaining questions are all low-impact, say "Remaining questions are cosmetic — I'll use sensible defaults and log them in IMPLEMENTATION_NOTES.md" and end the interview.

6. **Close with a contract.** After the last answer, output a short summary: decisions made, defaults assumed, and the rewritten task statement. Ask for a single confirmation before implementing.

## Mid-implementation use

This skill also applies DURING implementation: when you hit an unknown whose resolution would change already-written code by more than ~20 lines, pause and ask rather than guess. For smaller unknowns, take the conservative option and log it under Deviations in IMPLEMENTATION_NOTES.md (see the implementation-notes skill).

## Anti-patterns

- Twenty trivia questions is failure. Fewer, sharper questions win.
- Asking questions whose answers are discoverable in the codebase or via search is failure. Look first, ask only what only the user knows.
