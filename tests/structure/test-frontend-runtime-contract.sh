#!/usr/bin/env bash
# Vérifie le contrat propre à l'audit runtime /ecocode frontend.
# Note : pas de set -e — ce script comptabilise ses propres erreurs.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PARENT_SKILL="$ROOT/skills/audits/SKILL.md"
SKILL="$ROOT/skills/audits/frontend/SKILL.md"
AGENT="$ROOT/agents/ecocode-frontend-analyzer.md"
ORCHESTRATOR="$ROOT/agents/ecocode-orchestrator.md"
STATIC_SKILL="$ROOT/skills/audits/front/SKILL.md"
STATIC_AGENT="$ROOT/agents/ecocode-front-analyzer.md"
REPORT_SKILL="$ROOT/skills/audits/report-writer/SKILL.md"
REPORT_AGENT="$ROOT/agents/ecocode-report-writer.md"
OPENCODE_ANALYZER="$ROOT/.opencode/agents/ecocode-frontend-analyzer.md"
OPENCODE_ORCHESTRATOR="$ROOT/.opencode/agents/ecocode-orchestrator.md"
OPENCODE_REPORT_AGENT="$ROOT/.opencode/agents/ecocode-report-writer.md"
CODEX_ANALYZER="$ROOT/.codex/agents/ecocode-frontend-analyzer.toml"
CODEX_PLUGIN_MANIFEST="$ROOT/.codex-plugin/plugin.json"
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

excludes() {
  local description="$1"
  local path="$2"
  local pattern="$3"

  if grep -Fq "$pattern" "$path"; then
    echo "✗ $description — motif interdit : $pattern"
    FAIL=$((FAIL + 1))
  else
    echo "✓ $description"
    PASS=$((PASS + 1))
  fi
}

file_exists() {
  local description="$1"
  local path="$2"

  if [ -f "$path" ]; then
    echo "✓ $description"
    PASS=$((PASS + 1))
  else
    echo "✗ $description — fichier manquant : $path"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Test contrat audit frontend runtime ==="

file_exists "manifest plugin Codex découvrable" "$CODEX_PLUGIN_MANIFEST"
if [ -f "$CODEX_PLUGIN_MANIFEST" ]; then
  contains "manifest Codex référence les skills racine" "$CODEX_PLUGIN_MANIFEST" '"skills": "./skills/"'
fi
contains "installation Codex crée le dossier des agents" "$CODEX_INSTALL" 'mkdir -p ~/.codex/skills ~/.codex/agents'
contains "installation Codex expose les profils agents" "$CODEX_INSTALL" 'ln -s ~/.codex/plugins/ai-assisted-sustainable-it/.codex/agents/*.toml ~/.codex/agents/'
contains "profil Codex installé retrouve l'agent canonique" "$CODEX_ANALYZER" '~/.codex/plugins/ai-assisted-sustainable-it/agents/ecocode-frontend-analyzer.md'

contains "routage sur le premier token" "$PARENT_SKILL" 'premier token exact'
contains "skill parent reçoit frontendData" "$PARENT_SKILL" '`frontendData`'
contains "skill parent délègue au rédacteur" "$PARENT_SKILL" 'déléguer à `ecocode-report-writer`'
contains "skill parent transmet frontendData" "$PARENT_SKILL" 'transmettre `frontendData`'
contains "skill parent attend le rapport dédié" "$PARENT_SKILL" 'docs/ecocode/audits/{timestamp}-audit-frontend.md'
contains "skill parent relaie auth_required" "$PARENT_SKILL" '`auth_required`'
contains "skill parent reprend après authentification" "$PARENT_SKILL" 'reprendre le parcours à'
contains "reprise auth utilise un index base zéro" "$PARENT_SKILL" '`reprise_etape` est un index basé à zéro'
contains "reprise auth valide les bornes" "$PARENT_SKILL" '0 <= reprise_etape < nombre d’étapes'
contains "reprise auth fusionne par identité" "$PARENT_SKILL" 'fusionner par `parcours.nom`, puis par `pages.nom`'
contains "reprise auth préserve les mesures" "$PARENT_SKILL" 'supprimer une page déjà mesurée'
contains "reprise auth déduplique les erreurs" "$PARENT_SKILL" '`etape`/`action`/`message`'
contains "reprise auth interrompt une boucle sans progrès" "$PARENT_SKILL" 'triplet parcours/index/URL sans progression'
contains "reprise auth boucle jusqu'aux statuts terminaux" "$PARENT_SKILL" 'Répéter les étapes 3 et 4'
contains "reprise auth mémorise tous les états" "$PARENT_SKILL" 'ensemble des triplets déjà rencontrés'
contains "reprise auth plafonne les rappels" "$PARENT_SKILL" 'maximum de 5 rappels par parcours'
contains "reprise fusionne les limites globales" "$PARENT_SKILL" '`code`/`scope`/`message`'

contains "skill réservé au runtime" "$SKILL" 'jamais `audits/front`'
contains "JSON strict" "$SKILL" 'JSON strict'
contains "schéma d'entrée strict explicite" "$SKILL" '## Schéma d’entrée strict'
contains "schéma d'entrée ferme les clés" "$SKILL" 'Toute clé non listée'
contains "schéma d'entrée documente les types" "$SKILL" '| Objet | Clés autorisées | Clés requises | Types exacts |'
contains "nom de page goto déterministe" "$SKILL" '`etape-{index}`'
contains "parcours commence par goto" "$SKILL" 'première étape de chaque parcours est obligatoirement un `goto`'
contains "schéma de sortie strict explicite" "$SKILL" '## Schéma de sortie strict'
contains "sortie interdit les clés supplémentaires" "$SKILL" 'La sortie interdit toute clé'
contains "sortie définit capture non nulle" "$SKILL" '`capture` non nul est un string'
contains "sortie définit code observé non nul" "$SKILL" '`code_observe` non nul'
contains "sortie définit correction non nulle" "$SKILL" '`correction` non nulle est un string'
contains "actions fermées" "$SKILL" '`waitFor` et `audit`'
contains "navigation limitée à HTTP(S)" "$SKILL" '`http://` ou `https://`'
contains "protocoles actifs interdits" "$SKILL" '`file:`, `data:`, `javascript:` et `ftp:`'
contains "identifiants URL interdits" "$SKILL" '`username` ou `password` non vide'
contains "audit distant en lecture seule par défaut" "$SKILL" 'lecture seule par défaut'
contains "actions mutantes confirmées" "$SKILL" '`check` et `press`'
contains "confirmation explicite via le parent" "$SKILL" '`confirmation_required`'
contains "capture Playwright seule exception d'écriture" "$SKILL" 'seule exception d’écriture locale'
contains "fichier JSON ne s'auto-confirme pas" "$SKILL" 'Un fichier JSON ne peut jamais autoriser ses propres actions'
contains "URL directe limite son autorisation" "$SKILL" 'HTTP(S) exacte demandée'
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
contains "skill définit la matrice de sondes" "$SKILL" '### Matrice de sondes fixe'
contains "skill impose la coherence EcoIndex" "$SKILL" '### Garde-fou de cohérence EcoIndex'
contains "skill sépare les pistes à vérifier" "$SKILL" '### À vérifier'
contains "skill définit la couverture" "$SKILL" '`couverture`'
contains "skill définit les pistes à vérifier" "$SKILL" '`a_verifier`'
contains "skill protège le calcul initial" "$SKILL" 'ne modifie jamais les entrées EcoIndex'
contains "skill refuse un audit vide pour grade bas" "$SKILL" 'grade C à G'
contains "schéma page définit sept arrays" "$SKILL" '| page | `nom`, `url`, `metriques`, `ecoindex`, `ecarts_greenit`, `performance`, `developpement_web`, `a_verifier`, `couverture`, `deduplication`, `capture`, `limites` | deux strings ; deux objects ; sept arrays ; string ou null |'
contains "rapport dédié" "$SKILL" 'docs/ecocode/audits/{timestamp}-audit-frontend.md'
contains "skill retourne auth_required au parent" "$SKILL" '`auth_required`'
contains "skill confie la reprise au parent" "$SKILL" '`reprise_etape`'

contains "agent exclusivement frontend" "$AGENT" 'exclusivement `/ecocode frontend`'
contains "agent en lecture seule" "$AGENT" 'Tu ne modifies aucun fichier'
contains "retour JSON strict" "$AGENT" 'Retourne un unique objet JSON strict'
contains "agent utilise le skill runtime" "$AGENT" '`audits/frontend`'
contains "agent transmet les sections séparées" "$AGENT" '"performance"'
contains "agent transmet le développement web" "$AGENT" '"developpement_web"'
contains "agent exécute la matrice de sondes" "$AGENT" 'Matrice de sondes fixe'
contains "agent explique les scores EcoIndex bas" "$AGENT" 'Garde-fou de cohérence EcoIndex'
contains "analyseur OpenCode transmet les pistes à vérifier" "$OPENCODE_ANALYZER" '`a_verifier`'
contains "analyseur OpenCode transmet la couverture" "$OPENCODE_ANALYZER" '`couverture`'
contains "agent transmet les pistes à vérifier" "$AGENT" '"a_verifier"'
contains "agent transmet la couverture" "$AGENT" '"couverture"'
contains "agent couvre le réseau" "$AGENT" '"domaine": "reseau"'
contains "agent couvre les scripts et styles" "$AGENT" '"domaine": "scripts_styles"'
contains "agent couvre les images et médias" "$AGENT" '"domaine": "images_medias"'
contains "agent couvre les composants" "$AGENT" '"domaine": "composants"'
contains "agent couvre la qualité web" "$AGENT" '"domaine": "qualite_web"'
contains "agent transmet les erreurs" "$AGENT" '"erreurs_execution"'
contains "agent transmet la déduplication" "$AGENT" '"deduplication"'
contains "agent désigne le rapport" "$AGENT" '"rapport": "audit-frontend"'
contains "agent expose auth_required" "$AGENT" '`auth_required`'
contains "agent expose confirmation_required" "$AGENT" '`confirmation_required`'
contains "agent expose la reprise" "$AGENT" '"reprise_etape"'
contains "agent expose l'URL cible de reprise" "$AGENT" '"url_cible"'
contains "schéma écart GreenIT complet" "$AGENT" '"impact": "Impact mesuré ou observable"'
contains "schéma performance complet" "$AGENT" '"categorie": "performance"'
contains "performance dédupliquable" "$AGENT" '"deduplication_key": "performance:https://example.com/app.js"'
contains "schéma développement complet" "$AGENT" '"categorie": "developpement_web"'
contains "développement localisé" "$AGENT" '"localisation": "parcours/accueil#console"'
contains "schéma limite de page complet" "$AGENT" '"code": "shadow_dom_ferme"'
contains "schéma limite globale complet" "$AGENT" '"scope": "execution"'

contains "orchestrateur route sur le premier token" "$ORCHESTRATOR" 'premier token exact'
contains "orchestrateur reçoit frontendData" "$ORCHESTRATOR" '`frontendData`'
contains "orchestrateur appelle le rédacteur" "$ORCHESTRATOR" 'déléguer à `ecocode-report-writer`'
contains "orchestrateur transmet frontendData" "$ORCHESTRATOR" 'transmettre `frontendData`'
contains "orchestrateur reprend auth_required" "$ORCHESTRATOR" 'reprendre le parcours à'
contains "orchestrateur confirme les actions mutantes" "$ORCHESTRATOR" '`confirmation_required`'
contains "orchestrateur boucle jusqu'aux statuts terminaux" "$ORCHESTRATOR" 'Répéter ce protocole'

contains "analyseur OpenCode suit le contrat canonique" "$OPENCODE_ANALYZER" 'même objet JSON strict'
contains "analyseur OpenCode expose auth_required" "$OPENCODE_ANALYZER" '`auth_required`'
contains "orchestrateur OpenCode route sur le premier token" "$OPENCODE_ORCHESTRATOR" 'premier token exact'
contains "orchestrateur OpenCode reçoit frontendData" "$OPENCODE_ORCHESTRATOR" '`frontendData`'
contains "orchestrateur OpenCode appelle le rédacteur" "$OPENCODE_ORCHESTRATOR" 'déléguer à `ecocode-report-writer`'
contains "orchestrateur OpenCode transmet frontendData" "$OPENCODE_ORCHESTRATOR" 'transmettre `frontendData`'
contains "orchestrateur OpenCode reprend auth_required" "$OPENCODE_ORCHESTRATOR" 'reprendre le parcours à'
contains "orchestrateur OpenCode boucle jusqu'aux statuts terminaux" "$OPENCODE_ORCHESTRATOR" 'Répéter ce protocole'

contains "profil Codex frontend" "$CODEX_ANALYZER" 'name = "ecocode-frontend-analyzer"'
contains "profil Codex en lecture seule" "$CODEX_ANALYZER" 'sandbox_mode = "read-only"'
contains "profil Codex lit l'agent canonique" "$CODEX_ANALYZER" 'agents/ecocode-frontend-analyzer.md'
excludes "skill front statique sans rapport runtime" "$STATIC_SKILL" 'audit-frontend'
excludes "skill front statique sans données runtime" "$STATIC_SKILL" 'frontendData'
excludes "agent front statique sans rapport runtime" "$STATIC_AGENT" 'audit-frontend'
excludes "agent front statique sans données runtime" "$STATIC_AGENT" 'frontendData'

contains "rédacteur décrit le rapport runtime" "$REPORT_SKILL" 'Audit runtime front-end'
contains "rédacteur nomme le rapport runtime" "$REPORT_SKILL" 'YYYY-MM-DDTHH-MM-audit-frontend.md'
contains "rédacteur sépare les parcours" "$REPORT_SKILL" '## Parcours exécutés'
contains "rédacteur conserve les erreurs runtime" "$REPORT_SKILL" '## Erreurs d’exécution et limites'
contains "rédacteur interprète les captures strictes" "$REPORT_SKILL" '`capture` est `null` ou un chemin relatif PNG'
contains "rédacteur interprète code et correction stricts" "$REPORT_SKILL" '`code_observe` et `correction` sont `null` ou des strings'
contains "rédacteur produit la synthèse executive" "$REPORT_SKILL" '## Synthèse exécutive'
contains "rédacteur décrit la couverture" "$REPORT_SKILL" '## Périmètre, méthode et couverture'
contains "rédacteur compare les pages" "$REPORT_SKILL" '## Comparatif des pages'
contains "rédacteur consolide les constats" "$REPORT_SKILL" '## Constats transverses'
contains "rédacteur produit les gains potentiels" "$REPORT_SKILL" '## Résumé des gains potentiels'
contains "rédacteur produit le plan intégré" "$REPORT_SKILL" '## Plan d’action priorisé'
contains "rédacteur produit la conclusion" "$REPORT_SKILL" '## Conclusion'
excludes "rédacteur OpenCode n'épingle pas un modèle indisponible" "$OPENCODE_REPORT_AGENT" 'anthropic/claude-3-5-sonnet-20241022'
contains "agent rédacteur écrit le rapport runtime" "$REPORT_AGENT" '{timestamp}-audit-frontend.md'
contains "agent OpenCode rédacteur écrit le rapport runtime" "$OPENCODE_REPORT_AGENT" '{timestamp}-audit-frontend.md'
contains "commande exige Playwright" "$COMMAND" '`frontend` — audit runtime des parcours front-end uniquement (requiert le MCP `playwright`)'
contains "commande route frontend par premier token" "$COMMAND" 'premier token exact'
contains "commande OpenCode exige Playwright" "$OPENCODE_COMMAND" '`frontend` — audit runtime des parcours front-end uniquement (requiert le MCP `playwright`)'
contains "commande OpenCode route frontend par premier token" "$OPENCODE_COMMAND" 'premier token exact'
contains "README documente le runtime frontend" "$README" '/ecocode frontend             # Audit runtime des parcours front-end (requiert playwright)'
contains "README donne un exemple URL frontend" "$README" '/ecocode frontend https://example.com'
contains "README donne un exemple fichier JSON frontend" "$README" '/ecocode frontend parcours.json'
contains "README donne un exemple JSON de parcours" "$README" '"parcours": ['
contains "README documente init frontend" "$README" '/ecocode frontend init'
contains "Codex documente Playwright requis" "$CODEX_INSTALL" '`playwright` MCP server configured for `/ecocode frontend` runtime audits (required)'
contains "Codex documente la commande frontend" "$CODEX_INSTALL" '/ecocode frontend     # Runtime front-end journey audit (requires playwright)'
contains "Codex documente une URL frontend" "$CODEX_INSTALL" '/ecocode frontend https://example.com'
contains "Codex documente un fichier JSON frontend" "$CODEX_INSTALL" '/ecocode frontend parcours.json'
contains "Codex documente init frontend" "$CODEX_INSTALL" '/ecocode frontend init'
contains "commande documente la syntaxe URL" "$COMMAND" '/ecocode frontend <url> [url...]'
contains "commande documente la syntaxe fichier JSON" "$COMMAND" '/ecocode frontend <fichier.json>'
contains "OpenCode documente la commande frontend" "$OPENCODE_INSTALL" '/ecocode frontend     # Runtime front-end journey audit (requires playwright)'
contains "OpenCode documente le skill frontend" "$OPENCODE_INSTALL" 'use skill tool to load audits/frontend'
contains "guide OpenCode documente le runtime frontend" "$OPENCODE_README" 'Analyse les parcours front-end runtime avec `/ecocode frontend` (MCP `playwright` requis).'
contains "changelog annonce le rapport runtime" "$CHANGELOG" '{timestamp}-audit-frontend.md'
contains "documentation teste le contrat frontend" "$ROOT/docs/testing.md" 'bash tests/structure/test-frontend-runtime-contract.sh'
contains "documentation teste le bootstrap OpenCode" "$ROOT/docs/testing.md" 'node --input-type=module'

echo
echo "Résultat : $PASS passés, $FAIL échoués"
[ "$FAIL" -eq 0 ]
