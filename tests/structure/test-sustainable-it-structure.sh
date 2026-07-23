#!/usr/bin/env bash
# Vérifie que le dépôt ne distribue plus que l'outil d'éco-conception.
# Note : pas de set -e — ce script comptabilise ses propres erreurs.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PASS=0; FAIL=0

check() {
  local desc="$1" path="$2"
  if [ -e "$ROOT/$path" ]; then
    echo "✓ $desc"; PASS=$((PASS + 1))
  else
    echo "✗ $desc — manquant : $path"; FAIL=$((FAIL + 1))
  fi
}

absent() {
  local desc="$1" path="$2"
  if [ ! -e "$ROOT/$path" ]; then
    echo "✓ $desc (absent)"; PASS=$((PASS + 1))
  else
    echo "✗ $desc — doit être absent : $path"; FAIL=$((FAIL + 1))
  fi
}

json_check() {
  local desc="$1" path="$2" jq_expr="$3" expected="$4"
  local actual
  actual=$(jq -r "$jq_expr" "$ROOT/$path" 2>/dev/null || echo "ERROR")
  if [ "$actual" = "$expected" ]; then
    echo "✓ $desc"; PASS=$((PASS + 1))
  else
    echo "✗ $desc — attendu '$expected', obtenu '$actual'"; FAIL=$((FAIL + 1))
  fi
}

echo "=== Test structure Sustainable IT ==="

check "skill design" "skills/design/SKILL.md"
check "skill development" "skills/development/SKILL.md"
check "skill audits" "skills/audits/SKILL.md"
check "skill audit front" "skills/audits/front/SKILL.md"
check "skill audit back" "skills/audits/back/SKILL.md"
check "plans Superpowers" ".superpowers/plans"
check "spécifications Superpowers" ".superpowers/specs"
check "commande ecocode" "commands/ecocode.md"
check "agent ecocode" "agents/ecocode-orchestrator.md"
check "plugin Claude ecocode" ".claude-plugin/plugins/ecocode/plugin.json"
check "plugin Codex ecocode" ".codex-plugin/plugins/ecocode/plugin.json"
check "plugin Cursor ecocode" ".cursor-plugin/plugins/ecocode/plugin.json"
check "plugin OpenCode ecocode" ".opencode/plugins/ecocode.js"

for path in \
  "skills/ecocode" \
  "docs/superpowers" \
  "skills/rgaa" \
  "commands/rgaa.md" \
  "agents/rgaa-orchestrator.md" \
  "agents/rgaa-page-analyzer.md" \
  "agents/rgaa-reporter.md" \
  "agents/rgaa-checklist.md" \
  ".opencode/agents/rgaa-orchestrator.md" \
  ".opencode/agents/rgaa-page-analyzer.md" \
  ".opencode/agents/rgaa-reporter.md" \
  ".opencode/agents/rgaa-checklist.md" \
  ".opencode/commands/rgaa.md" \
  ".opencode/plugins/rgaa.js" \
  ".claude-plugin/plugins/rgaa" \
  ".codex-plugin/plugins/rgaa" \
  ".cursor-plugin/plugins/rgaa"; do
  absent "surface RGAA $path" "$path"
done

if grep -Fq '`.superpowers/`' "$ROOT/AGENTS.md"; then
  echo "✓ règle locale pour les fichiers Superpowers"; PASS=$((PASS + 1))
else
  echo "✗ règle locale pour les fichiers Superpowers — manquante dans AGENTS.md"; FAIL=$((FAIL + 1))
fi

if grep -Fq 'path.join(ecocodeSkillsDir, "audits", "SKILL.md")' "$ROOT/.opencode/plugins/ecocode.js"; then
  echo "✓ bootstrap OpenCode charge le skill audits"; PASS=$((PASS + 1))
else
  echo "✗ bootstrap OpenCode charge le skill audits — chemin manquant"; FAIL=$((FAIL + 1))
fi

json_check "package renommé" "package.json" ".name" "ai-assisted-sustainable-it"
json_check "extension Gemini renommée" "gemini-extension.json" ".name" "ai-assisted-sustainable-it"
json_check "marketplace Claude : un plugin" ".claude-plugin/marketplace.json" ".plugins | length" "1"
json_check "marketplace Codex : un plugin" ".codex-plugin/marketplace.json" ".plugins | length" "1"
json_check "marketplace Claude : ecocode" ".claude-plugin/marketplace.json" ".plugins[0].name" "ecocode"
json_check "marketplace Codex : ecocode" ".codex-plugin/marketplace.json" ".plugins[0].name" "ecocode"

for spec in \
  "package.json:.version" \
  "gemini-extension.json:.version" \
  ".claude-plugin/plugins/ecocode/plugin.json:.version" \
  ".codex-plugin/plugins/ecocode/plugin.json:.version" \
  ".cursor-plugin/plugins/ecocode/plugin.json:.version" \
  ".claude-plugin/marketplace.json:.plugins[0].version" \
  ".codex-plugin/marketplace.json:.plugins[0].version"; do
  path="${spec%%:*}"
  jq_expr="${spec#*:}"
  json_check "version 2.0.0 dans $path ($jq_expr)" "$path" "$jq_expr" "2.0.0"
done

echo
echo "Résultat : $PASS passés, $FAIL échoués"
[ "$FAIL" -eq 0 ]
