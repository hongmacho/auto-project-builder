# auto-project-builder

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
