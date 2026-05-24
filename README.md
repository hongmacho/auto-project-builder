# auto-project-builder

[![GitHub Stars](https://img.shields.io/github/stars/hongmacho/auto-project-builder?style=flat-square)](https://github.com/hongmacho/auto-project-builder/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/hongmacho/auto-project-builder?style=flat-square)](https://github.com/hongmacho/auto-project-builder/network/members)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet?style=flat-square)](https://claude.ai/claude-code)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black?style=flat-square&logo=next.js)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-blue?style=flat-square&logo=typescript)](https://www.typescriptlang.org)
[![SQLite](https://img.shields.io/badge/SQLite-Drizzle_ORM-003B57?style=flat-square&logo=sqlite)](https://orm.drizzle.team)

A Claude Code skill that autonomously plans service ideas and builds complete Next.js + shadcn/ui + SQLite web projects — no human intervention required.

## Features

- Generates N service ideas (default: 5) autonomously
- Checks GitHub for duplicate projects before building
- Builds each project with Next.js 14+ App Router + shadcn/ui + Drizzle ORM + SQLite
- Pushes each project to GitHub automatically
- Produces a final HTML report in Korean

## Installation

```bash
mkdir -p ~/.claude/skills/auto-project-builder
curl -o ~/.claude/skills/auto-project-builder/SKILL.md \
  https://raw.githubusercontent.com/hongmacho/auto-project-builder/main/skills/auto-project-builder/SKILL.md
```

Then restart Claude Code — the skill will appear in `/skills`.

## Usage

```
# Default (5 projects, autonomous domain selection)
/auto-project-builder

# Specify count
/auto-project-builder --count 3

# Specify domain keywords
/auto-project-builder --keywords "healthcare,education"

# Count + keywords
/auto-project-builder --count 3 --keywords "saas,productivity"

# Natural language also works
"자율 프로젝트 3개 커머스 관련으로 만들어봐"
"autonomous build 2 projects about productivity"
```

## Prerequisites

- `gh` CLI authenticated (`gh auth login`)
- Node.js 18+
- Git configured
- Context7 MCP server enabled (for latest stack research)

## Tech Stack

Each generated project uses:

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 14+ App Router |
| UI | shadcn/ui |
| Database | SQLite via Drizzle ORM |
| Auth | NextAuth.js v5 (optional) |
| Language | TypeScript (strict mode) |

## Output

- `projects/{slug}/` — each generated project
- `project_report.html` — final summary report in Korean

## License

MIT
