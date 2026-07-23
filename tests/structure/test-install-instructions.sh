#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

grep -Fq '/plugin install ecocode@ai-assisted-sustainable-it' "$root/README.md"
grep -Fq '~/.codex/skills' "$root/README.md"
grep -Fq '~/.codex/skills' "$root/.codex/INSTALL.md"
! grep -Fq '~/.agents/' "$root/.codex/INSTALL.md"

for path in \
  README.md \
  CLAUDE.md \
  .codex/INSTALL.md \
  .codex-plugin/INSTALL.md \
  .opencode/INSTALL.md \
  docs/README.opencode.md \
  .claude-plugin/plugins/ecocode/plugin.json \
  .codex-plugin/plugins/ecocode/plugin.json; do
  grep -Fq 'github.com/cnumr/ai-assisted-sustainable-it' "$root/$path"
  ! grep -Fq 'github.com/hrenaud/ai-assisted-sustainable-it' "$root/$path"
done

for path in README.md CLAUDE.md .codex/INSTALL.md; do
  grep -Fq 'skills/audits' "$root/$path"
  grep -Fq 'skills/design' "$root/$path"
  grep -Fq 'skills/development' "$root/$path"
done
