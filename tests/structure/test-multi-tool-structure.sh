#!/usr/bin/env bash
# Vérifie que la structure multi-outils est en place
# Note: pas de set -e — ce script gère ses propres erreurs
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASS=0; FAIL=0

check() {
  local desc="$1"; local path="$2"
  if [ -e "$ROOT/$path" ]; then
    echo "✓ $desc"; PASS=$(( PASS + 1 ))
  else
    echo "✗ $desc — manquant : $path"; FAIL=$(( FAIL + 1 ))
  fi
}

absent() {
  local desc="$1"; local path="$2"
  if [ ! -e "$ROOT/$path" ]; then
    echo "✓ $desc (supprimé)"; PASS=$(( PASS + 1 ))
  else
    echo "✗ $desc — doit être supprimé : $path"; FAIL=$(( FAIL + 1 ))
  fi
}

json_check() {
  local desc="$1"; local path="$2"; local jq_expr="$3"; local expected="$4"
  local actual
  actual=$(jq -r "$jq_expr" "$ROOT/$path" 2>/dev/null || echo "ERROR")
  if [ "$actual" = "$expected" ]; then
    echo "✓ $desc"; PASS=$(( PASS + 1 ))
  else
    echo "✗ $desc — attendu '$expected', obtenu '$actual'"; FAIL=$(( FAIL + 1 ))
  fi
}

echo "=== Test structure multi-outils ==="

# plugin.json ecocode dans sous-dossiers
check "Claude Code ecocode plugin.json"  ".claude-plugin/plugins/ecocode/plugin.json"
check "Codex ecocode plugin.json"        ".codex-plugin/plugins/ecocode/plugin.json"
check "Cursor ecocode plugin.json"       ".cursor-plugin/plugins/ecocode/plugin.json"

# plugin.json rgaa stubs
check "Claude Code rgaa plugin.json"    ".claude-plugin/plugins/rgaa/plugin.json"
check "Codex rgaa plugin.json"          ".codex-plugin/plugins/rgaa/plugin.json"
check "Cursor rgaa plugin.json"         ".cursor-plugin/plugins/rgaa/plugin.json"

# anciens plugin.json supprimés
absent "Ancien .claude-plugin/plugin.json supprimé"  ".claude-plugin/plugin.json"
absent "Ancien .codex-plugin/plugin.json supprimé"   ".codex-plugin/plugin.json"
absent "Ancien .cursor-plugin/plugin.json supprimé"  ".cursor-plugin/plugin.json"

# marketplace.json contient 2 plugins
json_check "Claude Code marketplace: 2 plugins" \
  ".claude-plugin/marketplace.json" ".plugins | length" "2"
json_check "Codex marketplace existe et contient 2 plugins" \
  ".codex-plugin/marketplace.json" ".plugins | length" "2"

# skills
check "skills/ecocode/SKILL.md"  "skills/ecocode/SKILL.md"
check "skills/rgaa/SKILL.md"     "skills/rgaa/SKILL.md"

# agents rgaa
check "agents/rgaa-page-analyzer.md" "agents/rgaa-page-analyzer.md"
check "agents/rgaa-reporter.md"  "agents/rgaa-reporter.md"

# commands rgaa
check "commands/rgaa.md"         "commands/rgaa.md"

# opencode rgaa
check ".opencode/plugins/rgaa.js" ".opencode/plugins/rgaa.js"

# chemins relatifs Codex corrigés
json_check "Codex ecocode skills path corrigé" \
  ".codex-plugin/plugins/ecocode/plugin.json" ".skills" "../../../skills/"
json_check "Cursor ecocode skills path corrigé" \
  ".cursor-plugin/plugins/ecocode/plugin.json" ".skills" "../../../skills/"

if grep -qi "explicit web eco-design audits" "$ROOT/skills/ecocode/SKILL.md" \
  && grep -qi "proactive design and coding guidance" "$ROOT/skills/ecocode/SKILL.md" \
  && grep -qi "## Conception" "$ROOT/skills/ecocode/dev-guide/SKILL.md"; then
  echo "✓ Description ecocode : audit explicite et guide conception/code proactif"; PASS=$((PASS + 1))
else
  echo "✗ Description ecocode : contrat audit/guide conception-code incomplet"; FAIL=$((FAIL + 1))
fi

echo ""
echo "Résultat : $PASS passés, $FAIL échoués"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
