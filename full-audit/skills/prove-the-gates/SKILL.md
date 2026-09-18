---
name: prove-the-gates
description: Audit the repository's own checks — for each test, gate and CI script, establish what it guards, whether anything still runs it, and whether it actually fails when you break what it protects. Use when the user says "prove the gates", "are our tests real", "audit the test suite", "which checks are fake", "תוכיח את השערים", "הבדיקות שלנו אמיתיות?", "תבדוק את הבדיקות", "איזו בדיקה מזויפת", or as a lane of a full audit. Also invocable as /prove-the-gates.
---

# Prove the Gates

Purpose: every other review verifies claims about the code. None verifies the thing doing the verifying. A check that guards a place that no longer exists is noise; a check whose rule moved without it is a hole; a check that passes because it never reaches its own assertion is worse than no check, because it is trusted. **An unproven check is a promise, not a gate.**

## Procedure

1. **Inventory every check.** Test files, gate scripts, lint configs, CI steps, pre-commit hooks. For each, write down in one line: what it guards. **Fix your unit first and say what it is** — a file, a named check id, or an assertion give wildly different fractions, and a fraction whose unit is unstated says nothing.

2. **Does that place still exist?** Match each check against the current tree. A check demanding a file that moved, a selector that was renamed, a build step that went to CI — that is noise to report, not a gate.

3. **Does anything actually run it?** Trace every check to the command that invokes it: the test script, the push command, the CI config, the hook. **A check nobody runs is not a gate, however good it is** — and this is the cheapest hole to find and the easiest to miss, because the file exists and reads well. Documentation claiming a check is enforced is a claim; the invocation is the fact.

4. **Prove it reddens.** For each check: **copy the repo to a scratch directory** — include `.git`, and whatever the build genuinely needs (`node_modules`, env files) or the run is not the real one — break exactly what that check protects there, and run the original unedited script against the copy. Mark each one **proven** / **not proven** / **cannot be proven, because —**. Never break anything in the working tree; confirm `git status` is unchanged when you finish, and report that.

5. **Break it the way the application builds it.** This is where a proof goes wrong while looking right. Injecting an artificial element, a hand-written fixture or a synthetic record can satisfy a check that every *real* one bypasses — the check then proves itself on a case that never occurs in production. Measured: a gate filtered out every button carrying a framework-internal property, which the framework attaches to everything it renders; a hand-injected button had none, was caught, and the gate was recorded as proven while it had not caught a real one in weeks. **If your broken sample took a different path into existence than the real thing, you proved nothing.**

6. **Hunt the six ways a check goes green for the wrong reason:**
   - It returns before its assertion (an early exit, a guard that skips, a selector that finds nothing and is read as "no violations").
   - A `try`/`catch` swallows the failure.
   - It greps a config file **without stripping comments** — the comment explaining that a thing was removed contains the exact words the check searches for.
   - A conditional branch upstream turned false, so a whole arm of the check silently stopped running.
   - **An exclusion filter that now matches everything.** A filter written to skip a narrow case grows to cover the whole population when the stack changes under it — a framework migration, a new build step, a library that starts tagging every node. The check still runs, still passes, and can no longer fire.
   - **It crashes before it prints.** A check that dies partway exits with an error and discards the findings it had already collected. The run looks like infrastructure trouble, not like a defect, and real findings vanish with it.

7. **Waiting checks:** does it have a short timeout, and does its failure message name *what* was not found? "Timeout" alone is a check that cannot be debugged.

8. **Deferred checks that are now holes.** If the project keeps a list of checks postponed until a feature is built, verify each against the code. **A feature that shipped while its check is still listed as deferred is a hole** — report it as one.

9. **Files invisible to review.** A single NUL byte makes git classify a source file as binary; every diff and every review then skips it silently, forever.
   ```
   git ls-files | while read f; do git diff --numstat 4b825dc642cb6eb9a060e54bf8d69288fbee4904 -- "$f"; done | grep '^-'
   ```
   (that SHA is git's empty tree, in every repo). **Do not substitute `grep -rlIP '\x00'`** — it misses these files; measured.

10. **Name what the suite structurally cannot catch.** Tests and a build do not see: a page that renders blank, a number that is wrong but well-formed, anything that only happens on hover, a public URL nobody declared. List the blind spots.

## Output

A table — check · `file:line` · what it guards · does that place exist · **who runs it** · **proven to redden** — then the findings by severity, then the gates worth writing. Report the proven-to-reddens as a fraction **with its unit** ("31 of 46 check ids"): it is the single number that says how much the suite is worth, and it means nothing without the unit.

## Calibration

- Proving dozens of checks takes a while. Sampling is legitimate when you say what you sampled and why; a fraction that hides an unexamined remainder is not.
- **Separate "expensive to prove" from "unsafe to prove."** A check that would take an hour is a budget decision. A check that can only be proven against production, real customer data, or a third party is a different answer and must be labelled as one — never quietly folded into the same bucket.
- **A check that writes to a real database is not covered by "don't touch the working tree."** Decide before you run it: is there a scratch dataset, does it restore what it changed, and did you verify the restore. Say which of those you relied on.
- A green suite is the normal starting state. Finding nothing here is a real outcome; say the fraction and stop.

## Anti-patterns

- Reading a check and reasoning that it would fail. Reasoning is what lets fake checks survive; break it in a copy and watch.
- Proving a check with a sample you built by hand when the real ones are built by the framework. That is the failure this skill exists to catch, and it is the one that feels most like success.
- Reporting a check as broken because it is ugly. The question is only whether it catches what it claims.
- Touching the working tree to prove anything.
