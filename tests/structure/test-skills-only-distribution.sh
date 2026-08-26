#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for path in \
  skills/design/SKILL.md \
  skills/development/SKILL.md \
  skills/ecocode/SKILL.md \
  skills/ecocode/references/static-analysis.md \
  skills/ecocode/references/runtime-analysis.md \
  skills/ecocode/references/findings-contract.md \
  skills/ecocode/references/restitution.md; do
  test -f "$root/$path"
done

for path in \
  agents \
  commands \
  hooks \
  .claude-plugin \
  .codex-plugin \
  .cursor-plugin \
  .codex \
  .opencode \
  gemini-extension.json; do
  ! test -e "$root/$path"
done

grep -Fq 'npx skills@latest add cnumr/ai-assisted-sustainable-it' "$root/README.md"
grep -Fq 'mcp-greenit' "$root/README.md"
grep -Fq 'playwright' "$root/README.md"
! grep -Fq '/plugin install' "$root/README.md"
