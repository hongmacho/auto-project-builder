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

A Claude Code skill that runs a fully autonomous pipeline: interactive setup → trend research → idea scoring → competitive analysis → GitHub dedup → build → auto QA loop → README generation → GitHub push → report.

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
│  Phase -1  Checkpoint check + Interactive setup (×4)    │
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
        ┌──────────────────────────────┐
        │  Phase 1  Idea Generation    │
        │  + Competitive Analysis      │
        │  (Exa search per idea)       │
        └──────────────┬───────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 1.3  Idea Scoring     │
        │  Market · Originality ·      │
        │  Feasibility  /9 pts         │
        │  → auto-reroll if below 5    │
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
        └──────────────┬───────────────────────────────────┘
                       ▼
        ┌──────────────────────────────┐
        │  Phase 3  Reports            │
        │  YYYYMMDD_report.html        │
        │  overview.html  (cumulative) │
        └──────────────────────────────┘
```

---

## Installation

```bash
mkdir -p ~/.claude/skills/auto-project-builder
curl -o ~/.claude/skills/auto-project-builder/SKILL.md \
  https://raw.githubusercontent.com/hongmacho/auto-project-builder/main/skills/auto-project-builder/SKILL.md
```

Restart Claude Code — the skill will appear in `/skills`.

---

## Usage

```
/auto-project-builder
```

The skill asks 4 questions at startup, then runs fully autonomously.

| # | Question | Options |
|---|----------|---------|
| 1 | Platform | Web / Mobile App / CLI / **Auto** / Custom |
| 2 | Tech Stack | Auto-generated per platform + **Auto** (Claude picks per idea) / Custom |
| 3 | Service Type | Productivity / Content / Commerce / Education / … (multi-select) + **Auto** |
| 4 | Count | 1–10 / **Auto** (= `floor(categories × 2–3)`, max 10) |

Selecting **Auto** on any question lets Claude choose autonomously based on trend data and service categories. The chosen value and the reasoning behind it are always announced before proceeding.

---

## Features

### Checkpoint Resume
Progress is saved to `.auto-project-builder-checkpoint.json` after each completed project. If the run is interrupted, the next invocation offers to resume from where it left off — completed projects are skipped automatically.

### Trend-Based Idea Generation
In parallel with Context7 stack research, the skill searches Product Hunt and GitHub Trending to find categories gaining traction and unsolved market gaps. These feed directly into idea generation.

### Idea Scoring
Every idea is scored before building begins.

| Criterion | 1 pt | 2 pts | 3 pts |
|-----------|------|-------|-------|
| Market fit | Saturated niche | Some differentiation | Clear gap |
| Originality | Obvious clone | Improved clone | Novel approach |
| Feasibility | Wrong stack | Possible but complex | Perfect stack fit |

Ideas scoring below 5/9 are automatically replaced with a new idea.

### Competitive Analysis
For each idea, the skill runs an Exa search for similar services. If competitors are found, the differentiation section is populated concretely. If no competitors exist, it is flagged as a market gap — a scoring bonus.

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

---

## OMC Integration (oh-my-claudecode)

When running inside [oh-my-claudecode](https://github.com/oh-my-claudecode), the skill automatically detects the environment at startup (Phase -0.5) and upgrades each phase with specialized agent orchestration.

### Auto-Detection

| Detected | `OMC_MODE` | Agent Strategy |
|----------|-----------|----------------|
| `oh-my-claudecode:*` skills | `"omc"` | Full OMC orchestration |
| `everything-claude-code:*` skills | `"ecc"` | ECC agent suite |
| Neither | `"none"` | Built-in agents |

### Phase 1: Parallel Planning with `team`

When `OMC_MODE = "omc"`, idea generation runs three roles simultaneously via the `team` skill — cutting planning time and diversifying perspectives:

| Role | Responsibility |
|------|----------------|
| `planner` | Generate ideas with target users, core features, differentiators |
| `architect` | Evaluate tech feasibility and implementation risks per idea |
| `autoresearch` | Research 3 competing services per category; surface market gaps |

### Phase 2: Full Autonomous Orchestration with `ultrawork`

Optionally hand off all of Phase 2 (PRD → ROADMAP → implement → QA → README → push) to `ultrawork` for zero-touch execution:

```
Skill("oh-my-claudecode:ultrawork",
  prompt="Complete {N} projects end-to-end.
  PLATFORM / TECH_STACK / PRD path: projects/{slug}/docs/PRD.md
  Done when: zero build errors + 80%+ coverage + README + GitHub push")
```

### Post-Build Quality Loop with `ralph`

After implementation, `ralph` applies a PRD-driven acceptance-criteria loop until quality is guaranteed.

**Auto-triggered when:**
- QA failed 2+ times
- Idea scored ≤ 6/9
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
│       └── ... (source code)
├── report_data/
│   └── {slug}_log.json
├── .auto-project-builder-checkpoint.json  ← exists during run, deleted on completion
├── YYYYMMDD_report.html           ← per-run report (in Korean)
└── overview.html                  ← cumulative catalog, updated every run
```

### `YYYYMMDD_report.html`
A new dated report is created for every run. Includes:
- Run summary dashboard (trend research results, QA stats)
- Idea scoring distribution + rejection reasons
- Per-project cards (competitive analysis, QA attempts, errors fixed)
- Full retrospective

### `overview.html`
Updated cumulatively across all runs. Includes:
- Run history timeline (links to each report)
- Full project catalog with platform / type / score filters
- Statistics dashboard (total projects, stack distribution, average QA attempts, average idea score)

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
