# auto-project-builder

[![GitHub Stars](https://img.shields.io/github/stars/hongmacho/auto-project-builder?style=flat-square)](https://github.com/hongmacho/auto-project-builder/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/hongmacho/auto-project-builder?style=flat-square)](https://github.com/hongmacho/auto-project-builder/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet?style=flat-square)](https://claude.ai/claude-code)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black?style=flat-square&logo=next.js)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-blue?style=flat-square&logo=typescript)](https://www.typescriptlang.org)
[![SQLite](https://img.shields.io/badge/SQLite-Drizzle_ORM-003B57?style=flat-square&logo=sqlite)](https://orm.drizzle.team)

> **Finish working projects with zero human intervention.**
> A project with build errors, type errors, or lint errors is not "done."

A Claude Code skill that runs a fully autonomous pipeline: interactive setup → trend research → idea scoring → competitive analysis → GitHub dedup → build → auto QA loop → README generation → GitHub push → report → enhancement guide.

[한국어 문서 →](README_ko.md)

---

## How It Works

```
/auto-project-builder
        │
        ▼
┌─────────────────────────────────────────────────────────┐
│  Phase -0.5  OMC / ECC Environment Detection (silent)   │
│  → OMC_MODE = "omc" / "ecc" / "none"                    │
└──────────────────────────┬──────────────────────────────┘
                           │
        ▼
┌─────────────────────────────────────────────────────────┐
│  Phase -1  Checkpoint check + Interactive setup (up to 5)│
│  Q1 Platform → Q1.5 Have an idea? → Q2 Tech Stack       │
│  → Q3 Service Type* → Q4 Count*  (* skipped if Q1.5=yes)│
└──────────────────────────┬──────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                     ▼
┌───────────────┐                   ┌──────────────────┐
│ Phase 0-A     │                   │ Phase 0-B        │
│ Context7      │  (parallel)       │ Trend Research   │
│ Stack Docs    │                   │ Product Hunt /   │
│               │                   │ GitHub Trending  │
└───────┬───────┘                   └────────┬─────────┘
        └──────────────┬────────────────────┘
                       ▼
        ┌──────────────────────────────────────────────────┐
        │  Phase 1  Idea Generation (idea-generator skill) │
        │  · Pain mining: Reddit/HN/AppStore/GitHub Issues │
        │  · 3-role adversarial eval: planner+architect+   │
        │    critic (YC-style fatal-flaw-first)            │
        │  · User-idea path: use provided idea directly    │
        └──────────────┬───────────────────────────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 1.3  Score Review     │
        │  15-pt YC scorecard          │
        │  GO / CONDITIONAL / NO-GO    │
        │  → auto-replace NO-GO ideas  │
        │  (skipped for user's idea)   │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 1.5  GitHub Dedup     │
        │  Skip ideas already built    │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────────────────────────┐
        │  Phase 2  Build Loop  (repeated per project)     │
        │                                                  │
        │  2-1  Write PRD                                  │
        │  2-2  Write ROADMAP + Sprint plan                │
        │  2-3  Implement                                  │
        │  2-4  ★ Auto QA loop (tsc / lint / build)        │
        │       └─ on fail: build-error-resolver ×3        │
        │  2-5  Auto-generate README                       │
        │  2-6  GitHub push                                │
        │  2-7  macOS completion notification              │
        │  2-8  Save checkpoint                            │
        │  2-9  Generate enhancement guide (5 categories) │
        │  2-10 Update user-suggest.html                  │
        └──────────────┬───────────────────────────────────┘
                       ▼
        ┌──────────────────────────────────────┐
        │  Phase 3  Reports                    │
        │  {YYYYMMDDHHmm}_report.html          │
        │  overview.html  (append-only)        │
        └──────────────────────────────────────┘
```

---

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/hongmacho/auto-project-builder/main/install.sh | bash
```

This installs both required skills in one command:
- `~/.claude/skills/auto-project-builder/SKILL.md`
- `~/.claude/skills/idea-generator/SKILL.md`

Restart Claude Code — the skills will appear in `/skills`.

---

## Usage

```
/auto-project-builder
```

The skill asks up to 5 questions at startup, then runs fully autonomously.

| # | Question | Options |
|---|----------|---------|
| 1 | Platform | Web / Mobile App / CLI / **Auto** / Custom |
| 1.5 | Have an idea? | **Auto** (Claude generates from trends) / Direct input |
| 2 | Preferred Tech Stack | Platform-specific options + **None** (per-idea auto-pick) / Custom |
| 3 | Service Type _\*_ | Productivity / Content / Commerce / Education / … (multi-select) + **Auto** |
| 4 | Count _\*_ | 1–10 / **Auto** (= `floor(categories × 2–3)`, max 10) |

_\* Questions 3 and 4 are skipped automatically when you provide your own idea at Q1.5 — `PROJECT_COUNT` is set to 1._

Selecting **Auto** / **None** on any question lets Claude decide autonomously based on trend data. The chosen value and reasoning are always announced before proceeding.

---

## Features

### Checkpoint Resume
Progress is saved to `.auto-project-builder-checkpoint.json` after each completed project. If the run is interrupted, the next invocation offers to resume from where it left off — completed projects are skipped automatically.

### High-Quality Idea Generation (`idea-generator` skill)
Phase 1 delegates to a dedicated `idea-generator` skill that starts from **real user pain**, not trending technology. The process:

1. **Multi-source pain mining** (4 parallel lanes)
   - Reddit: "I wish there was" / "why is there no" complaints
   - Hacker News: "Ask HN: Is there a tool for..." threads
   - App Store 1-star reviews: repeated frustration patterns in competing apps
   - GitHub Issues: unresolved feature requests in popular repos

2. **Pain-to-idea transformation** — every idea is backed by real user quotes, not speculation

3. **3-role adversarial evaluation** (run in parallel)
   - Planner: value proposition, killer feature, target persona
   - Architect: technical feasibility, risks, MVP sprint estimate
   - Critic (YC-style): fatal flaws first, market size, defensibility, monetization

4. **15-point YC scorecard + go/no-go verdict**

| Criterion | 1 pt | 2 pts | 3 pts |
|-----------|------|-------|-------|
| Pain strength | Speculation only | Indirect evidence | 5+ direct user quotes |
| Market size | Niche few | Thousands | Hundreds of thousands+ |
| Originality | Obvious clone | Improved clone | Novel combination |
| Feasibility | Stack mismatch | Possible but risky | Perfect stack fit |
| Fatal flaw penalty | — | — | −1 to −3 pts |

**Verdicts**: GO (≥11 pts) · CONDITIONAL (8–10 pts) · NO-GO (≤7 pts, auto-replaced)

### GitHub Dedup
Runs `gh repo list` and filters out ideas that are too similar to existing repositories, then auto-generates replacements.

### Auto QA Loop (Core)
After implementation, stack-specific validation commands are executed.

| Stack | QA Commands |
|-------|-------------|
| TypeScript (Web / CLI) | `tsc --noEmit && lint && build` |
| Expo (App) | `expo-doctor && tsc --noEmit` |
| Python | `mypy && pytest` |
| Go | `vet && build && test` |
| Rust | `check && clippy && test` |

On failure, errors are handed to the `build-error-resolver` agent for automatic fixing. Up to 3 attempts. If all 3 fail, Nice-to-have features are stripped and only Must-have features are re-implemented. If that still fails, the project is marked SKIP and the next project begins.

### Auto README Generation
After each QA pass, a `README.md` is generated for the project containing: feature list, tech stack table, prerequisites, installation steps, and usage commands.

### Completion Notifications
A macOS notification is fired after each project completes so you can step away during long runs.

### Per-Idea Tech Stack
When **None** is selected for the tech stack question, no stack is locked at setup time. Instead, each idea receives its own optimal stack at Phase 1 planning time based on the idea's requirements and current trends. This allows a single run to produce projects in Next.js, SvelteKit, and Remix simultaneously without being constrained to one stack up front.

### Enhancement Guide (`user-suggest.html`)
After each project completes, the skill generates a five-category enhancement guide saved as `projects/{slug}/user-suggest.html` — one standalone file per project. Five projects → five independent files.

| Category | Contents |
|----------|----------|
| Quick Wins | Small improvements deployable within a day |
| Feature Enhancements | Mid-size features to add in the next sprint |
| Tech Improvements | Performance, security, and architecture upgrades |
| Growth Strategies | User acquisition, SEO, viral loops, partnerships |
| Monetization Ideas | Revenue models suited to the project type |

Raw suggestion data is also saved to `report_data/{slug}_suggestions.json` for programmatic use.

---

## OMC Integration (oh-my-claudecode)

When running inside [oh-my-claudecode](https://github.com/oh-my-claudecode), the skill automatically detects the environment at startup (Phase -0.5) and upgrades each phase with specialized agent orchestration.

### Auto-Detection

| Detected | `OMC_MODE` | Agent Strategy |
|----------|-----------|----------------|
| `oh-my-claudecode:*` skills | `"omc"` | Full OMC orchestration |
| `everything-claude-code:*` skills | `"ecc"` | ECC agent suite |
| Neither | `"none"` | Built-in agents |

### Phase 1: Pain-Driven Idea Generation with `idea-generator`

When `OMC_MODE = "omc"`, the `idea-generator` skill runs three agent roles in parallel for maximum idea quality:

| Role | Responsibility |
|------|----------------|
| `planner` | Value proposition, killer feature, target persona, 6-month survival scenario |
| `architect` | Technical feasibility score, implementation risks, MVP sprint count |
| `critic` | YC-style fatal-flaw hunting, competitor analysis, monetization path, go/no-go |

This replaces simple trend-based generation with evidence-backed, adversarially validated ideas.

### Phase 2: Full Autonomous Orchestration with `autopilot`

Optionally hand off all of Phase 2 (PRD → ROADMAP → implement → QA → README → push) to `autopilot` for zero-touch execution:

```
Skill("oh-my-claudecode:autopilot",
  prompt="Complete {N} projects end-to-end.
  PLATFORM / TECH_STACK / PRD path: projects/{slug}/docs/PRD.md
  Done when: zero build errors + 80%+ coverage + README + GitHub push")
```

### Post-Build Quality Loop with `ralph`

After implementation, `ralph` applies a PRD-driven acceptance-criteria loop until quality is guaranteed.

**Auto-triggered when:**
- QA failed 2+ times
- Idea scored ≤ 7/15 (CONDITIONAL verdict)
- Code review found 3+ HIGH issues

**Criteria ralph enforces:**
1. Test coverage ≥ 80%
2. Zero `tsc / lint / build` errors
3. Explicit error handling at every boundary
4. Functions / components ≤ 200 lines
5. All PRD Must-have features verified working

Can also be applied optionally to any completed project for uniform quality uplift.

---

## Supported Tech Stacks

### Web
| Option | Stack |
|--------|-------|
| ① Recommended | Next.js 14+ App Router · shadcn/ui · Drizzle ORM · SQLite |
| ② | Nuxt 3 · Tailwind CSS · PGlite |
| ③ | SvelteKit · shadcn-svelte · Drizzle ORM · SQLite |
| ④ | Remix · shadcn/ui · Drizzle ORM · SQLite |
| ⑤ | Custom input |

### Mobile App
| Option | Stack |
|--------|-------|
| ① Recommended | React Native + Expo · expo-sqlite |
| ② | Flutter 3 · Dart · sqflite |
| ③ | Auto (Claude picks per idea based on trend data) |
| ④ | Custom input |

### CLI
| Option | Stack |
|--------|-------|
| ① Recommended | Node.js · TypeScript · Commander.js · SQLite |
| ② | Python 3.12 · Typer / Click · SQLite |
| ③ | Go 1.22 · Cobra · SQLite |
| ④ | Rust · Clap · ratatui · SQLite |
| ⑤ | Custom input |

---

## Output

```
{working directory}/
├── projects/
│   └── {slug}/
│       ├── docs/
│       │   ├── PRD.md
│       │   └── ROADMAP.md
│       ├── README.md              ← auto-generated
│       ├── user-suggest.html      ← per-project enhancement guide (standalone)
│       └── ... (source code)
├── report_data/
│   ├── {slug}_log.json
│   └── {slug}_suggestions.json   ← enhancement guide data per project
├── .auto-project-builder-checkpoint.json  ← exists during run, deleted on completion
├── {YYYYMMDDHHmm}_report.html     ← per-run report, timestamped to minute (e.g. 202605242157_report.html)
└── overview.html                  ← cumulative catalog, append-only across all runs
```

### `{YYYYMMDDHHmm}_report.html`
A new timestamped report is created for every run (hour + minute included, e.g. `202605242157_report.html`). Multiple runs on the same day each get their own file — no overwriting. Includes:
- Run summary dashboard (trend research results, QA stats)
- Idea scoring distribution + rejection reasons
- Per-project cards (competitive analysis, QA attempts, errors fixed)
- Full retrospective

### `overview.html`
**Append-only** — existing content is never replaced. Each run injects new project cards and a history entry into well-known HTML markers (`<!-- PROJECT_CARDS_START/END -->`, `<!-- TIMELINE_START/END -->`, `<!-- STATS_TOTAL -->`, `<!-- STATS_AVG_SCORE -->`). Statistics are recalculated as a running total. Created fresh if it doesn't exist yet. Includes:
- Run history timeline (links to each report)
- Full project catalog with platform / type / score filters
- Statistics dashboard (total projects, stack distribution, average QA attempts, average idea score)

### `projects/{slug}/user-suggest.html`
Generated immediately after each project completes — one standalone file per project. Includes:
- Quick wins, feature enhancements, tech improvements, growth strategies, monetization ideas
- Priority and estimated effort labels per suggestion

---

## Prerequisites

- `gh` CLI authenticated (`gh auth login`)
- Node.js 18+ (for Web / CLI projects)
- Git configured
- Context7 MCP server enabled (for latest stack research)

---

## Fallback Strategy

Four-tier automatic fallback on errors:

```
1st  build-error-resolver agent (auto-fix)
2nd  build-error-resolver retry (with scope-reduction hint)
3rd  Strip Nice-to-have → re-implement Must-have only → 1 final QA
4th  Mark SKIP + log error details → proceed to next project
```

GitHub push failures are retried up to 3 times with exponential backoff (5s → 10s → 20s).

---

## License

MIT
