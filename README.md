# Fable Method — A Claude Code Plugin for Systematic Unknowns Discovery

> Stop guessing. Find your unknown unknowns before they cost you.

**Fable Method** is a [Claude Code](https://docs.claude.com/en/docs/claude-code) plugin that turns Thariq Shihipar's ["A Field Guide to Fable"](https://x.com/trq212/status/2073100352921215386) into an installable, enforced workflow: **8 agent skills, 2 model-routed subagents, and 3 lifecycle hooks** for blindspot scanning, structured requirement interviews, prototype-first design, decision logging, fix-loop detection, and pre-merge comprehension quizzes.

Works with **Claude Fable 5**, Opus, and Sonnet. Zero external dependencies. Compatible with the Superpowers plugin. Skills also installable on claude.ai.

[English](README.md) · [עברית](README.he.md)

---

## Table of Contents

- [Why This Exists](#why-this-exists)
- [What's Inside](#whats-inside)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [How It Works Day-to-Day](#how-it-works-day-to-day)
- [Model Economy: Cheaper Models per Step](#model-economy-cheaper-models-per-step)
- [Convergence Guard: Built-in Stop-Loss](#convergence-guard-built-in-stop-loss)
- [Coexistence with Superpowers](#coexistence-with-the-superpowers-plugin)
- [Architecture](#architecture)
- [FAQ](#faq)

---

## Why This Exists

The core idea, from Anthropic engineer Thariq's field guide: **the map is not the territory**. Your prompt is a map. The codebase, its conventions, and real-world constraints are the territory. The gap between them is made of **unknowns** — and with frontier models like Claude Fable 5, the quality of AI-assisted work is no longer bottlenecked by the model. It's bottlenecked by **how cheaply you discover your unknowns** before they become expensive.

Four kinds of unknowns, four failure modes:

| Quadrant | What it is | Typical failure |
|---|---|---|
| **Known knowns** | What's explicit in your prompt | None — this is the easy part |
| **Known unknowns** | Gaps you're aware of | Deferred instead of resolved |
| **Unknown knowns** | Your unstated conventions & taste | Claude guesses; you reject; loop |
| **Unknown unknowns** | Constraints you never considered | Discovered in production |

Fable Method attacks each quadrant with a specific, cheap technique — and **enforces** the discipline with hooks, so it doesn't depend on anyone remembering to follow it.

**This is a toolbox, not a pipeline.** The router skill decides which technique applies to which task — and its most important job is deciding when to apply *nothing*. Ceremony on trivial tasks is a bug.

## What's Inside

### Agent Skills (8)

| Skill | Purpose | Trigger |
|---|---|---|
| `fable-method` | The router — a decision tree matching task type to technique, including when to skip everything | Start of any non-trivial task |
| `blindspot-pass` | Scans the territory (codebase + web) and returns a ranked list of your unknown unknowns, ending with a rewritten prompt | New domains, vague tasks, `/blindspot-pass` |
| `interview-me` | One-question-at-a-time requirements interview, max 7 questions, sorted by architectural impact, each with a proposed default | Ambiguous requests, `/interview-me` |
| `prototype-first` | 3–4 genuinely divergent HTML prototypes before any real code — extracts taste you can't verbalize | UI/design/visual tasks, `/prototype-first` |
| `implementation-notes` | Maintains `IMPLEMENTATION_NOTES.md` with Decisions / Deviations / Open questions during every multi-file session | Automatic during implementation |
| `merge-quiz` | Change report + a comprehension quiz you must pass before merging — resyncs your mental model with the actual diff | End of long sessions, `/merge-quiz` |
| `model-economy` | Routes each workflow step to the cheapest suitable model via subagents | Multi-step planning |
| `convergence-guard` | Stop-loss discipline: three-strike rule, deviation pressure, scope-creep detection, mandatory replan protocol | Debugging, fix-loops |

### Subagents (2) — explicit model routing

| Agent | Model | Job |
|---|---|---|
| `territory-scout` | **haiku** | Cheap, wide, read-only codebase & web reconnaissance for blindspot passes |
| `report-builder` | **sonnet** | Mechanical change inventories, diff summaries, and test-run reports for merge quizzes |

### Hooks (1) — enforcement, not suggestions

| Hook | Event | What it does |
|---|---|---|
| `posttool-guard.sh` | PostToolUse | Counts edits per file: **warning at the 5th edit** of the same file, **hard stop at the 8th** — the classic fix-loop signal. Defers automatically to a real `stoploss` binary if found on PATH |

Since 1.0.2 the plugin injects no text: the `SessionStart` (`session-start.sh`) and `Stop` (`check-notes.sh`) hooks are no longer registered. Text injected into every session competed with other plugins' injected text and cost tokens in every session, including the ones that never used it. The skills still load by their descriptions. The two scripts stay in `hooks/` for anyone who wants to register them by hand.

## Installation

### Option A — Plugin via Git (recommended; includes hooks)

```
claude
> /plugin marketplace add orenluxy/fable-method
> /plugin install fable-method@fable-method-marketplace
```

Update everywhere later with one `git push` + `/plugin update fable-method` per machine.

### Option B — Fallback installer (no plugin support)

```bash
git clone https://github.com/orenluxy/fable-method.git
cd fable-method && bash scripts/install.sh
```

Copies skills to `~/.claude/skills/`, agents to `~/.claude/agents/`, and appends a managed routing block to `~/.claude/CLAUDE.md`. Idempotent; remove with `scripts/uninstall.sh`. **Does not wire the hooks** — merge `hooks/hooks.json` into `~/.claude/settings.json` manually if you want enforcement.

### Option C — claude.ai (no Claude Code)

Each folder under `skills/` can be uploaded individually as a skill in claude.ai (Settings → Capabilities → Skills). Hooks and subagents don't apply there.

## Quick Start

```
# New domain? Find what you don't know you don't know:
/blindspot-pass integrate Stripe webhooks into this app — zero experience with Stripe

# Vague idea? Get interviewed instead of guessing:
/interview-me I'm thinking about adding real-time notifications to the app

# Visual work? Extract your taste before writing real code:
/prototype-first admin dashboard for the analytics module — dark mode, mobile-first

# Long session done? Prove you understand the diff before merging:
/merge-quiz
```

## How It Works Day-to-Day

**Most of the time you do nothing.** The SessionStart hook injects the decision tree into every session and Claude routes on its own:

1. **Trivial task** → just done, no ceremony.
2. **Familiar domain** → `IMPLEMENTATION_NOTES.md` during, `merge-quiz` if >150 lines or production code.
3. **New domain** → `blindspot-pass` → `interview-me` → implement with notes → mandatory `merge-quiz`.
4. **Visual / taste-driven** → `prototype-first` with divergent variations.
5. **Vague request** → `interview-me`, one question at a time, architecture-impact first.

The one habit that pays for everything: **state your experience level with the domain at the start of the task**. Every branch calibrates on it.

### The IMPLEMENTATION_NOTES.md lifecycle

Created at implementation start; fills with Decisions / Deviations / Open questions; **3+ deviations in one subsystem = the plan is wrong, stop and replan**; the merge quiz imports it; the Stop hook refuses to end the session with open questions. Per-task, not a running journal — add it and `.fable-session/` to `.gitignore`.

## Model Economy: Cheaper Models per Step

A standing instruction like "use the cheapest model" does nothing — a session's main model cannot swap itself mid-run. The only real mechanism for per-step model selection in Claude Code is **subagents with an explicit `model:` field**, and this plugin codifies it:

- Territory scanning → `territory-scout` on **haiku**
- Change inventories, diff summaries, test reports → `report-builder` on **sonnet**
- Judgment, interviews, quiz design, taste work → **main model, never delegated** (delegating judgment to save tokens is false economy — one wrong architectural call costs more than every scan in the project)

Rules of thumb baked into the `model-economy` skill: write the brief before delegating, one round-trip maximum, and report the routing to the user in one line so the economy stays auditable.

## Convergence Guard: Built-in Stop-Loss

The most expensive failure mode in agentic coding is the **fix-loop** — repeatedly patching symptoms of a wrong plan. Tokens burned in a fix-loop are worse than wasted: they deepen commitment to a broken approach.

Enforced thresholds:

- **5 edits** to the same file without tests going green → injected warning
- **8 edits** → hard stop: Claude must freeze, summarize the failed attempts and their common cause, and propose **2 alternative strategies** (different strategy, not different patch)
- **3 consecutive failed fixes** of the same behavior → three-strike rule, attempt #4 with the same strategy is forbidden
- **3+ deviations** in one subsystem → the plan is wrong; replan

If you have your own stop-loss tooling, the guard **auto-detects a `stoploss` binary on PATH and defers to it entirely** — your thresholds become authoritative.

## Coexistence with the Superpowers Plugin

Fable Method has **zero dependencies** — Superpowers is not required. But if it's installed, the SessionStart hook detects it and activates precedence rules:

- **Superpowers owns HOW**: brainstorming, writing plans, executing plans, TDD mechanics.
- **Fable Method owns UNKNOWNS**: blindspot-pass / interview-me / prototype-first run *before* the planning flow and feed it a rewritten prompt; merge-quiz gates *after* execution.
- **Never both** brainstorming and blindspot-pass on the same task — that's doubled ceremony.

## Architecture

```
fable-method/
├── .claude-plugin/
│   ├── plugin.json              # plugin manifest
│   └── marketplace.json         # lets this repo act as its own marketplace
├── skills/                      # 8 agent skills (SKILL.md each)
│   ├── fable-method/            # router / decision tree
│   ├── blindspot-pass/
│   ├── interview-me/
│   ├── prototype-first/
│   ├── implementation-notes/
│   ├── merge-quiz/
│   ├── model-economy/
│   └── convergence-guard/
├── agents/
│   ├── territory-scout.md       # model: haiku
│   └── report-builder.md        # model: sonnet
├── hooks/
│   ├── hooks.json               # SessionStart / PostToolUse / Stop wiring
│   ├── session-start.sh
│   ├── posttool-guard.sh
│   └── check-notes.sh
└── scripts/
    ├── install.sh               # fallback installer (idempotent)
    └── uninstall.sh
```

## FAQ

**Does this work with models other than Claude Fable 5?**
Yes — the techniques are model-agnostic and the field guide's core claim is simply that the stronger the model, the more your unknowns become the bottleneck. Opus and Sonnet benefit the same way.

**Won't all this ceremony burn tokens?**
The router's first branch is "trivial → no ceremony," and every skill carries explicit anti-patterns against over-application. Measured correctly (tokens per *solved* task, not per session), unknowns discovered early are the cheapest tokens you'll spend. Track re-prompt rounds and deviation counts for two weeks; if a technique isn't paying, the router tells Claude to skip it for similar tasks.

**Why not auto-install Superpowers as a dependency?**
Auto-pulling third-party plugins from an installer is a supply-chain risk and creates version coupling. Native equivalents + runtime detection is more robust.

**How do I update across all my machines?**
`git push` once, then `/plugin update fable-method` on each machine. The repo is the single source of truth.

**Private repo?**
Works — each machine just needs git authentication (SSH key or `gh auth login`). Note that SEO/discoverability only applies to public repos.

---

## Keywords

Claude Code plugin · Claude Fable 5 · AI coding workflow · prompt engineering · agentic coding · unknown unknowns · blindspot scanning · AI pair programming · context engineering · Claude skills · Claude Code hooks · Claude Code subagents · model routing · token optimization · LLM cost optimization · fix-loop detection · AI code review · merge quiz · implementation notes · Anthropic · A Field Guide to Fable

## Credits & License

Methodology: [Thariq Shihipar's "A Field Guide to Fable"](https://x.com/trq212/status/2073100352921215386) (Anthropic, Claude Code team). Plugin implementation: independent, not affiliated with Anthropic. MIT License.
