#!/usr/bin/env bash
set -e

REPO="https://raw.githubusercontent.com/hongmacho/auto-project-builder/main"

echo "Installing auto-project-builder + idea-generator skills..."

mkdir -p ~/.claude/skills/auto-project-builder
curl -fsSL "$REPO/skills/auto-project-builder/SKILL.md" \
  -o ~/.claude/skills/auto-project-builder/SKILL.md

mkdir -p ~/.claude/skills/idea-generator
curl -fsSL "$REPO/skills/idea-generator/SKILL.md" \
  -o ~/.claude/skills/idea-generator/SKILL.md

echo ""
echo "✓ auto-project-builder installed → ~/.claude/skills/auto-project-builder/SKILL.md"
echo "✓ idea-generator installed        → ~/.claude/skills/idea-generator/SKILL.md"
echo ""
echo "Restart Claude Code — skills will appear in /skills."
