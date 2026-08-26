#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

for path in \
  skills/ecodesign/SKILL.md \
  skills/ecocode/SKILL.md \
  skills/audit-ecoconception/SKILL.md \
  skills/audit-ecoconception/references/static-analysis.md \
  skills/audit-ecoconception/references/runtime-analysis.md \
  skills/audit-ecoconception/references/findings-contract.md \
  skills/audit-ecoconception/references/restitution.md; do
  test -f "$root/$path"
done

for path in skills/design skills/development; do
  ! test -e "$root/$path"
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
grep -Fq 'skills/ecodesign' "$root/README.md"
grep -Fq 'skills/ecocode' "$root/README.md"
grep -Fq 'skills/audit-ecoconception' "$root/README.md"
grep -Fq 'audit-ecoconception code back' "$root/README.md"
grep -Fq 'audit-ecoconception navigateur' "$root/README.md"
grep -Fq 'mcp-greenit' "$root/README.md"
grep -Fq 'playwright' "$root/README.md"
! grep -Fq '/plugin install' "$root/README.md"

grep -Fq 'name: ecodesign' "$root/skills/ecodesign/SKILL.md"
grep -Fq 'name: ecocode' "$root/skills/ecocode/SKILL.md"
grep -Fq 'name: audit-ecoconception' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'code front' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'code back' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'navigateur' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'mcp-greenit' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'sous-agents' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq 'retourne exclusivement le contrat de constats' "$root/skills/audit-ecoconception/SKILL.md"
grep -Fq "brouillon d'issue" "$root/skills/audit-ecoconception/references/restitution.md"
grep -Fq 'demande explicite' "$root/skills/audit-ecoconception/references/restitution.md"
