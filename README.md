# auto-project-builder

[![GitHub Stars](https://img.shields.io/github/stars/hongmacho/auto-project-builder?style=flat-square)](https://github.com/hongmacho/auto-project-builder/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/hongmacho/auto-project-builder?style=flat-square)](https://github.com/hongmacho/auto-project-builder/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet?style=flat-square)](https://claude.ai/claude-code)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black?style=flat-square&logo=next.js)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-blue?style=flat-square&logo=typescript)](https://www.typescriptlang.org)
[![SQLite](https://img.shields.io/badge/SQLite-Drizzle_ORM-003B57?style=flat-square&logo=sqlite)](https://orm.drizzle.team)

A Claude Code skill that interactively configures platform & tech stack, then autonomously plans service ideas and builds complete projects — no human intervention required after setup.

## Features

- **Interactive setup** — choose platform (Web / Mobile App / CLI / Custom), tech stack, service type, and count
- Generates N service ideas (default: 5) tailored to your selections
- Checks GitHub for duplicate projects before building
- Builds each project with your chosen stack (Next.js, Nuxt, SvelteKit, React Native, Flutter, and more)
- Pushes each project to GitHub automatically
- Produces a **date-stamped report** (`YYYYMMDD_report.html`) per run
- Maintains a **cumulative `overview.html`** — a living catalog of all generated projects

## Installation

```bash
mkdir -p ~/.claude/skills/auto-project-builder
curl -o ~/.claude/skills/auto-project-builder/SKILL.md \
  https://raw.githubusercontent.com/hongmacho/auto-project-builder/main/skills/auto-project-builder/SKILL.md
```

Then restart Claude Code — the skill will appear in `/skills`.

## Usage

```
/auto-project-builder
```

On start, the skill asks 4 questions:

| # | Question | Options |
|---|----------|---------|
| 1 | Platform | Web / Mobile App / CLI / Custom |
| 2 | Tech Stack | Dynamic options based on platform choice |
| 3 | Service Type | SaaS / E-commerce / Social / Productivity / etc. |
| 4 | Count | How many projects to build (default: 5) |

Then it runs fully autonomously.

## Supported Tech Stacks

### Web
| Stack | Details |
|-------|---------|
| Next.js (recommended) | Next.js 14+ App Router · shadcn/ui · Drizzle + SQLite |
| Nuxt 3 | Nuxt 3 · Tailwind CSS · PGlite |
| SvelteKit | SvelteKit · shadcn-svelte · Drizzle + SQLite |
| Remix | Remix · shadcn/ui · Drizzle + SQLite |

### Mobile App
| Stack | Details |
|-------|---------|
| React Native + Expo (recommended) | Expo SDK · NativeWind · SQLite |
| Flutter | Flutter 3 · Material 3 · sqflite |
| Swift (iOS) | SwiftUI · CoreData |
| Kotlin (Android) | Jetpack Compose · Room |

### CLI
| Stack | Details |
|-------|---------|
| Node.js (recommended) | Node.js · Commander · chalk |
| Python | Python 3.12 · Click · Rich |
| Go | Go 1.22 · Cobra · Bubble Tea |
| Rust | Rust · clap · ratatui |

## Output

- `projects/{slug}/` — each generated project
- `YYYYMMDD_report.html` — per-run summary report in Korean
- `overview.html` — cumulative catalog updated after every run

## Prerequisites

- `gh` CLI authenticated (`gh auth login`)
- Node.js 18+ (for web/CLI projects)
- Git configured
- Context7 MCP server enabled (for latest stack research)

## License

MIT
