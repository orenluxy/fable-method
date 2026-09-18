---
name: prove-the-gates
description: Audit the repository's own checks — for each test, gate and CI script, establish what it guards, whether that place still exists, and whether it actually fails when you break what it protects. Use when the user says "prove the gates", "are our tests real", "audit the test suite", "which checks are fake", or as a lane of a full audit. Also invocable as /prove-the-gates.
---

# Prove the Gates

Purpose: every other review verifies claims about the code. None verifies the thing doing the verifying. A check that guards a place that no longer exists is noise; a check whose rule moved without it is a hole; a check that passes because it never reaches its own assertion is worse than no check, because it is trusted. **An unproven check is a promise, not a gate.**

## Procedure

1. **Inventory every check.** Test files, gate scripts, lint configs, CI steps, pre-commit hooks. For each, write down in one line: what it guards.

2. **Does that place still exist?** Match each check against the current tree. A check demanding a file that moved, a selector that was renamed, a build step that went to CI — that is noise to report, not a gate.

3. **Prove it reddens.** For each check: **copy the repo to a scratch directory**, break exactly what that check protects there, and run the original unedited script against the copy. Mark each one **proven** / **not proven** / **cannot be proven, because —**. Never break anything in the working tree; confirm `git status` is unchanged when you finish, and report that.

4. **Hunt the four ways a check goes green for the wrong reason:**
   - It returns before its assertion (an early exit, a guard that skips, a selector that finds nothing and is read as "no violations").
   - A `try`/`catch` swallows the failure.
   - It greps a config file **without stripping comments** — the comment explaining that a thing was removed contains the exact words the check searches for.
   - A conditional branch upstream turned false, so a whole arm of the check silently stopped running.

5. **Waiting checks:** does it have a short timeout, and does its failure message name *what* was not found? "Timeout" alone is a check that cannot be debugged.

6. **Deferred checks that are now holes.** If the project keeps a list of checks postponed until a feature is built, verify each against the code. **A feature that shipped while its check is still listed as deferred is a hole** — report it as one.

7. **Files invisible to review.** A single NUL byte makes git classify a source file as binary; every diff and every review then skips it silently, forever.
   ```
   git ls-files | while read f; do git diff --numstat 4b825dc642cb6eb9a060e54bf8d69288fbee4904 -- "$f"; done | grep '^-'
   ```
   (that SHA is git's empty tree, in every repo). **Do not substitute `grep -rlIP '\x00'`** — it misses these files; measured.

8. **Name what the suite structurally cannot catch.** Tests and a build do not see: a page that renders blank, a number that is wrong but well-formed, anything that only happens on hover, a public URL nobody declared. List the blind spots.

## Output

A table — check · `file:line` · what it guards · does that place exist · **proven to redden** — then the findings by severity, then the gates worth writing. Report the proven-to-reddens as a fraction ("20 of 24"): it is the single number that says how much the suite is worth.

## Calibration

- Proving 24 checks takes a while. A check that cannot be proven without touching the tree gets "cannot be proven, because —" — that is an honest result, not a failure.
- A green suite is the normal starting state. Finding nothing here is a real outcome; say the fraction and stop.

## Anti-patterns

- Reading a check and reasoning that it would fail. Reasoning is what lets fake checks survive; break it in a copy and watch.
- Reporting a check as broken because it is ugly. The question is only whether it catches what it claims.
- Touching the working tree to prove anything.
