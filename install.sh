#!/usr/bin/env bash
# docpilot installer for Linux/macOS
# Usage: curl -fsSL https://raw.githubusercontent.com/.../install.sh | bash
set -e

SKILL_DIR="${HOME}/.claude/skills"
SKILL_FILE="${SKILL_DIR}/docpilot.md"
REPO_URL="https://raw.githubusercontent.com/airwaves778899/docpilot/main/skill/SKILL.md"

echo "📚 Installing docpilot..."
mkdir -p "${SKILL_DIR}"
curl -fsSL "${REPO_URL}" -o "${SKILL_FILE}"
echo "✅ docpilot installed to ${SKILL_FILE}"
echo ""
echo "Restart Claude Code or Cowork, then say:"
echo '  "produce documentation for my project"'
