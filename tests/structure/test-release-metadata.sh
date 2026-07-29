#!/usr/bin/env bash
# Vérifie les métadonnées de la release courante.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASS=0
FAIL=0
EXPECTED_VERSION=$(jq -r '.version' "$ROOT/package.json")

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

check_tag_bump() {
  local fixture_dir status
  fixture_dir=$(mktemp -d)

  mkdir -p "$fixture_dir/scripts" "$fixture_dir/docs" \
    "$fixture_dir/.claude-plugin/plugins/ecocode" \
    "$fixture_dir/.codex-plugin/plugins/ecocode" \
    "$fixture_dir/.cursor-plugin/plugins/ecocode"
  cp "$ROOT/scripts/bump-version.sh" "$fixture_dir/scripts/"
  cp "$ROOT/.version-bump.json" "$ROOT/package.json" \
    "$ROOT/gemini-extension.json" "$fixture_dir/"
  cp "$ROOT/docs/README.opencode.md" "$fixture_dir/docs/"
  cp "$ROOT/.claude-plugin/plugins/ecocode/plugin.json" \
    "$fixture_dir/.claude-plugin/plugins/ecocode/"
  cp "$ROOT/.codex-plugin/plugin.json" "$fixture_dir/.codex-plugin/"
  cp "$ROOT/.codex-plugin/plugins/ecocode/plugin.json" \
    "$fixture_dir/.codex-plugin/plugins/ecocode/"
  cp "$ROOT/.cursor-plugin/plugins/ecocode/plugin.json" \
    "$fixture_dir/.cursor-plugin/plugins/ecocode/"
  cp "$ROOT/.claude-plugin/marketplace.json" \
    "$fixture_dir/.claude-plugin/"
  cp "$ROOT/.codex-plugin/marketplace.json" "$fixture_dir/.codex-plugin/"

  "$fixture_dir/scripts/bump-version.sh" 9.9.9 >/dev/null 2>&1
  status=$?
  if [ "$status" -eq 0 ] && grep -q '#v9.9.9' "$fixture_dir/docs/README.opencode.md"; then
    status=0
  else
    status=1
  fi
  trash "$fixture_dir"
  return "$status"
}

check "Les manifests sont synchronisés en $EXPECTED_VERSION" \
  bash -c "'$ROOT/scripts/bump-version.sh' --check | grep -Fq 'Tous les fichiers sont synchronisés à $EXPECTED_VERSION'"
check "Le changelog contient la release $EXPECTED_VERSION" \
  grep -Fq "## $EXPECTED_VERSION —" "$ROOT/CHANGELOG.md"
check "Le guide OpenCode référence v$EXPECTED_VERSION" \
  grep -Fq "#v$EXPECTED_VERSION" "$ROOT/docs/README.opencode.md"
check "Le bump synchronise le tag OpenCode" check_tag_bump
check "L'audit de version ne remonte aucun fichier non déclaré" \
  bash -c "! '$ROOT/scripts/bump-version.sh' --audit | grep -q 'Fichiers NON DÉCLARÉS'"

echo
echo "Résultat : $PASS passés, $FAIL échoués"
test "$FAIL" -eq 0
