---
name: full-audit
description: Audit a whole repository in one pass — dispatch every applicable audit lane in parallel, prove the repo's own gates fail when they should, and return one evidence-backed report ranked by severity. Use when the user says "full audit", "audit this repo", "check the whole codebase", "תעשה אודיט מלא", or asks for a periodic proactive code review. Reports only; never fixes. Also invocable as /full-audit.
---

# Full Audit

Purpose: green tests and a green build are not evidence. A repository accumulates defects that every existing check is structurally blind to — and the checks themselves rot. This runs every applicable lane at once, re-verifies what they claim, and hands back one report the owner decides from.

**Reports only.** No edit, no commit, no push, no state-changing command. The single exception is starting a local server and running read-only checks. The one file written is the report.

## Procedure

1. **Baseline, before anything.** `git status --porcelain > baseline`, record HEAD. Run `ListAgents` (or check for other running sessions): if another session is working this repo, say so up front — its edits will land mid-audit and you must not attribute them to yourself. Give the user a wall-clock estimate as a range, and re-state it if reality moves.

2. **Detect lanes. Never assume a repo has what yours had.** Inspect the tree and pick only what applies:

   | Lane | Runs when | How |
   |---|---|---|
   | Security | always | **Invoke `claude-security` if installed** — do not hand-roll a security pass beside it. It computes its own rigor record and verifies findings adversarially. Absent it, run a security lane like the others. |
   | Over-engineering | always | **Invoke `ponytail-audit` if installed.** Otherwise skip and say so. |
   | Gates | any test/lint/CI/check script exists | `prove-the-gates` (this plugin) |
   | Architecture | always | duplicated business rules, layering shortcuts, dead code, framework-specific traps (e.g. conditional hooks), cross-directory imports that packaging misses |
   | Calculations | a data source exists | run the product's own query against the source and compare to what the app returns, metric by metric |
   | Content | user-facing text exists | against the project's own glossary/style rules if it has them; grammar of interpolated numbers; empty and zero states |
   | Display | a UI and a browser tool exist | real browser, real screenshots, two viewports, console must be silent, **and hover/click — layered checks never touch the mouse** |

   State which lanes you picked and which you skipped, with the reason, before dispatching.

3. **Give every lane agent the iron rules verbatim:**
   - Read-only. No edit, no commit, no push. Breaking something to prove a check works happens **in a copy**, never the tree.
   - **A finding without evidence is not a finding.** Each carries `file:line`, what actually happens, the command output or measurement, and what it costs the user or the system.
   - Three severities only: **blocker** (wrong value shown, security hole, crash) · **worth fixing** · **note**. Nothing else is a blocker.
   - **Doubt is not a finding.** Undecided → write "undecided" and what is missing to decide.
   - **No performance finding without two numbers**: cold vs warm, and single vs concurrent. Without both you cannot tell an expensive query from a cold cache from pool exhaustion, and each has a different fix.
   - Write the full report to a scratch file; return only a summary.

4. **Tier the fleet** (see `model-economy`): mechanical inventory cheap, lanes mid, synthesis top. One agent per lane. Tell them explicitly that commit and push are forbidden — a single agent that commits sweeps every other agent's work into it.

5. **Re-verify every blocker yourself, from source, before it enters the report.** This is not optional and it is not delegated. Lanes inflate severity and inherit wrong premises. Demote what does not meet the blocker test, and say you demoted it.

6. **Account for coverage.** Every top-level directory is either covered by a lane or set aside with a stated reason. "I checked the code" without the list is not a report.

7. **Write the report**, and close by diffing `git status` against the baseline. If the tree changed, say what changed and whether the audit caused it.

## The report

One self-contained HTML file (RTL and both themes if the project's conventions ask for it), in the user's language:

1. **One line**: how many blockers, worth-fixing, notes.
2. **The blockers**, each with: what is broken · `file:line` · the evidence · what it costs · the proposed fix · a time estimate.
3. The rest, by lane.
4. **What was checked and came out clean** — without it nobody can tell what was covered.
5. **What was not checked, and why** — honestly.
6. **New gates worth writing** — one per finding that could have been caught automatically.
7. Every file you touched.

Findings the owner will act on belong in a surface whose state gets back to you — not a checkbox that only writes to the viewer's browser.

## Calibration

- A repo with no tests, no UI and no data source is three lanes, not seven. Sizing the audit to the repo is the skill; running seven lanes on a library is theatre.
- Ten real findings beat sixty with noise. Padding the count is how a report gets ignored.
- Numbers in the project's own documentation are claims, not facts. Measure them. Where a doc and the running product disagree, the product is right.
- Connection strings, project ids and ports: say where to find them, never hardcode them. A wrong one in the prompt propagates into every lane at once.

## Anti-patterns

- Duplicating a lane a dedicated tool already owns better.
- Accepting a lane agent's blocker without reading the source yourself.
- Fixing anything. The owner decides what closes; an audit that fixes has no baseline left to prove it was honest.
- Scoping a fix to the directory where a defect was found instead of sweeping the pattern across the repo — that is how the same bug gets reported twice in two months.
