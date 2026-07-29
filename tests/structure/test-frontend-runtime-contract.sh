#!/usr/bin/env bash
# Vérifie le contrat propre à l'audit runtime /ecocode frontend.
# Note : pas de set -e — ce script comptabilise ses propres erreurs.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILL="$ROOT/skills/audits/frontend/SKILL.md"
AGENT="$ROOT/agents/ecocode-frontend-analyzer.md"
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

echo
echo "Résultat : $PASS passés, $FAIL échoués"
[ "$FAIL" -eq 0 ]
