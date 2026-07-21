#!/usr/bin/env bash
# Vérifie les métadonnées propres à la release 2.0.0.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASS=0
FAIL=0

check() {
  local description="$1"
  shift
  if "$@"; then
    echo "✓ $description"
    PASS=$((PASS + 1))
  else
    echo "✗ $description"
    FAIL=$((FAIL + 1))
  fi
}

check "Les manifests sont synchronisés en 2.0.0" \
  bash -c "'$ROOT/scripts/bump-version.sh' --check | grep -q 'Tous les fichiers sont synchronisés à 2.0.0'"
check "Le changelog contient la release 2.0.0" \
  grep -q '^## 2.0.0 — 2026-07-21$' "$ROOT/CHANGELOG.md"
check "Le guide OpenCode référence v2.0.0" \
  grep -q '#v2.0.0' "$ROOT/docs/README.opencode.md"
check "L'audit de version ne remonte aucun fichier non déclaré" \
  bash -c "! '$ROOT/scripts/bump-version.sh' --audit | grep -q 'Fichiers NON DÉCLARÉS'"

echo
echo "Résultat : $PASS passés, $FAIL échoués"
test "$FAIL" -eq 0
