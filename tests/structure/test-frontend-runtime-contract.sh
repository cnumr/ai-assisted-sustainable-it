#!/usr/bin/env bash
# Vérifie le contrat propre à l'audit runtime /ecocode frontend.
# Note : pas de set -e — ce script comptabilise ses propres erreurs.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILL="$ROOT/skills/audits/frontend/SKILL.md"
AGENT="$ROOT/agents/ecocode-frontend-analyzer.md"
REPORT_SKILL="$ROOT/skills/audits/report-writer/SKILL.md"
REPORT_AGENT="$ROOT/agents/ecocode-report-writer.md"
OPENCODE_REPORT_AGENT="$ROOT/.opencode/agents/ecocode-report-writer.md"
COMMAND="$ROOT/commands/ecocode.md"
OPENCODE_COMMAND="$ROOT/.opencode/commands/ecocode.md"
README="$ROOT/README.md"
CODEX_INSTALL="$ROOT/.codex/INSTALL.md"
OPENCODE_INSTALL="$ROOT/.opencode/INSTALL.md"
OPENCODE_README="$ROOT/docs/README.opencode.md"
CHANGELOG="$ROOT/CHANGELOG.md"
PASS=0
FAIL=0

contains() {
  local description="$1"
  local path="$2"
  local pattern="$3"

  if grep -Fq "$pattern" "$path"; then
    echo "✓ $description"
    PASS=$((PASS + 1))
  else
    echo "✗ $description — motif manquant : $pattern"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Test contrat audit frontend runtime ==="

contains "skill réservé au runtime" "$SKILL" 'jamais `audits/front`'
contains "JSON strict" "$SKILL" 'JSON strict'
contains "actions fermées" "$SKILL" '`goto`, `click`, `fill`, `select`, `check`, `press`, `waitFor`, `audit`'
contains "métrique DOM" "$SKILL" '`dom_nodes`'
contains "métrique requêtes" "$SKILL" '`requests`'
contains "métrique transfert" "$SKILL" '`size_kb`'
contains "calcul EcoIndex MCP" "$SKILL" '`greenit_calculer_ecoindex`'
contains "compteur Shadow DOM" "$SKILL" 'Shadow DOM ouverts'
contains "descendants SVG exclus" "$SKILL" 'descendants de `<svg>`'
contains "session gérée par l'utilisateur" "$SKILL" 'L’utilisateur se connecte lui-même'
contains "storageState interdit" "$SKILL" '`storageState`'
contains "origines HTTPS" "$SKILL" 'origines HTTPS'
contains "en-têtes sensibles refusés" "$SKILL" '`Authorization`, `Cookie`, `Proxy-Authorization`, `Set-Cookie`'
contains "erreur limitée au parcours" "$SKILL" 'arrête seulement le parcours concerné'
contains "aucune mesure inventée" "$SKILL" 'Aucune mesure n’est inventée'
contains "déduplication globale" "$SKILL" 'Dédupliquer globalement'
contains "métriques conservées par page" "$SKILL" 'métriques de chaque page'
contains "section GreenIT" "$SKILL" '### Écarts GreenIT'
contains "section Performance séparée" "$SKILL" '### Performance'
contains "section développement séparée" "$SKILL" '### Développement web'
contains "rapport dédié" "$SKILL" 'docs/ecocode/audits/{timestamp}-audit-frontend.md'

contains "agent exclusivement frontend" "$AGENT" 'exclusivement `/ecocode frontend`'
contains "agent en lecture seule" "$AGENT" 'Tu ne modifies aucun fichier'
contains "retour JSON strict" "$AGENT" 'Retourne un unique objet JSON strict'
contains "agent utilise le skill runtime" "$AGENT" '`audits/frontend`'
contains "agent transmet les sections séparées" "$AGENT" '"performance"'
contains "agent transmet le développement web" "$AGENT" '"developpement_web"'
contains "agent transmet les erreurs" "$AGENT" '"erreurs_execution"'
contains "agent transmet la déduplication" "$AGENT" '"deduplication"'
contains "agent désigne le rapport" "$AGENT" '"rapport": "audit-frontend"'

contains "rédacteur décrit le rapport runtime" "$REPORT_SKILL" 'Audit runtime front-end'
contains "rédacteur nomme le rapport runtime" "$REPORT_SKILL" 'YYYY-MM-DDTHH-MM-audit-frontend.md'
contains "rédacteur sépare les parcours" "$REPORT_SKILL" '## Parcours exécutés'
contains "rédacteur conserve les erreurs runtime" "$REPORT_SKILL" '## Erreurs d’exécution et limites'
contains "agent rédacteur écrit le rapport runtime" "$REPORT_AGENT" '{timestamp}-audit-frontend.md'
contains "agent OpenCode rédacteur écrit le rapport runtime" "$OPENCODE_REPORT_AGENT" '{timestamp}-audit-frontend.md'
contains "commande exige Playwright" "$COMMAND" '`frontend` — audit runtime des parcours front-end uniquement (requiert le MCP `playwright`)'
contains "commande OpenCode exige Playwright" "$OPENCODE_COMMAND" '`frontend` — audit runtime des parcours front-end uniquement (requiert le MCP `playwright`)'
contains "README documente le runtime frontend" "$README" '/ecocode frontend             # Audit runtime des parcours front-end (requiert playwright)'
contains "Codex documente Playwright requis" "$CODEX_INSTALL" '`playwright` MCP server configured for `/ecocode frontend` runtime audits (required)'
contains "Codex documente la commande frontend" "$CODEX_INSTALL" '/ecocode frontend     # Runtime front-end journey audit (requires playwright)'
contains "OpenCode documente la commande frontend" "$OPENCODE_INSTALL" '/ecocode frontend     # Runtime front-end journey audit (requires playwright)'
contains "guide OpenCode documente le runtime frontend" "$OPENCODE_README" 'Analyse les parcours front-end runtime avec `/ecocode frontend` (MCP `playwright` requis).'
contains "changelog annonce le rapport runtime" "$CHANGELOG" '{timestamp}-audit-frontend.md'

echo
echo "Résultat : $PASS passés, $FAIL échoués"
[ "$FAIL" -eq 0 ]
