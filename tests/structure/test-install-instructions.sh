#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

grep -Fq '/plugin install ecocode@ai-assisted-sustainable-it' "$root/README.md"
grep -Fq '~/.codex/skills' "$root/README.md"
grep -Fq '~/.codex/skills' "$root/.codex/INSTALL.md"
! grep -Fq '~/.agents/' "$root/.codex/INSTALL.md"
