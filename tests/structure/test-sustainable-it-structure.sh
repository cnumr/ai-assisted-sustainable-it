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

toml_check() {
  local desc="$1" path="$2" key="$3" expected="$4"
  local actual
  actual=$(python3.11 - "$ROOT/$path" "$key" <<'PY' 2>/dev/null || echo "ERROR"
import sys
import tomllib

with open(sys.argv[1], "rb") as file:
    config = tomllib.load(file)

value = config
for part in sys.argv[2].split("."):
    value = value[part]

if not isinstance(value, str):
    raise TypeError(f"{sys.argv[2]} must be a string")

print(value)
PY
)
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
check "skill audit frontend" "skills/audits/frontend/SKILL.md"
check "skill audit back" "skills/audits/back/SKILL.md"
check "plans Superpowers" ".superpowers/plans"
check "spécifications Superpowers" ".superpowers/specs"
check "commande ecocode" "commands/ecocode.md"
check "agent ecocode" "agents/ecocode-orchestrator.md"
check "agent audit frontend" "agents/ecocode-frontend-analyzer.md"
check "agent OpenCode audit frontend" ".opencode/agents/ecocode-frontend-analyzer.md"
check "plugin Claude ecocode" ".claude-plugin/plugins/ecocode/plugin.json"
check "plugin Codex ecocode" ".codex-plugin/plugins/ecocode/plugin.json"
check "plugin Cursor ecocode" ".cursor-plugin/plugins/ecocode/plugin.json"
check "plugin OpenCode ecocode" ".opencode/plugins/ecocode.js"

for agent in \
  "ecocode-orchestrator" \
  "ecocode-front-analyzer" \
  "ecocode-frontend-analyzer" \
  "ecocode-back-analyzer" \
  "ecocode-report-writer" \
  "ecocode-planner" \
  "ecocode-fix-suggester"; do
  check "adaptateur Codex $agent" ".codex/agents/$agent.toml"
done

for analyzer in "ecocode-front-analyzer" "ecocode-frontend-analyzer" "ecocode-back-analyzer"; do
  toml_check "analyseur Codex $analyzer en lecture seule" ".codex/agents/$analyzer.toml" "sandbox_mode" "read-only"
done

for agent in \
  "ecocode-orchestrator" \
  "ecocode-front-analyzer" \
  "ecocode-frontend-analyzer" \
  "ecocode-back-analyzer" \
  "ecocode-report-writer" \
  "ecocode-planner" \
  "ecocode-fix-suggester"; do
  if python3.11 - "$ROOT/.codex/agents/$agent.toml" <<'PY' 2>/dev/null
import sys
import tomllib

with open(sys.argv[1], "rb") as stream:
    assert "model" not in tomllib.load(stream)
PY
  then
    echo "✓ adaptateur Codex $agent sans modèle figé"; PASS=$((PASS + 1))
  else
    echo "✗ adaptateur Codex $agent contient un modèle figé"; FAIL=$((FAIL + 1))
  fi
done

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

EXPECTED_VERSION=$(jq -r '.version' "$ROOT/package.json")

for spec in \
  "commands/ecocode.md:Use the \`audits\` skill" \
  "commands/ecocode.md:/ecocode délègue à \`ecocode-orchestrator\`" \
  "commands/ecocode.md:\`frontend\` — audit runtime des parcours front-end uniquement" \
  "skills/audits/SKILL.md:premier token exact" \
  "skills/audits/SKILL.md:docs/ecocode/audits/{timestamp}-audit-frontend.md" \
  "agents/ecocode-orchestrator.md:skill \`audits\`" \
  "agents/ecocode-orchestrator.md:premier token exact" \
  "agents/ecocode-orchestrator.md:docs/ecocode/audits/{timestamp}-audit-frontend.md" \
  ".opencode/agents/ecocode-orchestrator.md:skill \`audits\`" \
  ".opencode/commands/ecocode.md:\`frontend\` — audit runtime des parcours front-end uniquement" \
  ".opencode/agents/ecocode-orchestrator.md:premier token exact" \
  ".opencode/agents/ecocode-orchestrator.md:docs/ecocode/audits/{timestamp}-audit-frontend.md" \
  "README.md:skills/design ~/.codex/skills/design" \
  "README.md:skills/development ~/.codex/skills/development" \
  ".codex/INSTALL.md:skills/design ~/.codex/skills/design" \
  ".codex/INSTALL.md:skills/development ~/.codex/skills/development"; do
  path="${spec%%:*}"
  pattern="${spec#*:}"
  if grep -Fq "$pattern" "$ROOT/$path"; then
    echo "✓ référence $path"; PASS=$((PASS + 1))
  else
    echo "✗ référence $path — motif manquant : $pattern"; FAIL=$((FAIL + 1))
  fi
done

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
  json_check "version $EXPECTED_VERSION dans $path ($jq_expr)" "$path" "$jq_expr" "$EXPECTED_VERSION"
done

echo
echo "Résultat : $PASS passés, $FAIL échoués"
[ "$FAIL" -eq 0 ]
