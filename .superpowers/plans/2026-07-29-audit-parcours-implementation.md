# Audit EcoCode de parcours Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Ajouter /ecocode parcours pour auditer des listes d'URL ou un parcours JSON Playwright, avec rapport EcoIndex par page.

**Architecture:** L'orchestrateur route le parcours vers le seul analyseur front. Celui-ci exécute les points d'audit et retourne des pages structurées. Le rédacteur produit un rapport de parcours sans relire les sources. Les copies OpenCode restent synchronisées.

**Tech Stack:** Skills Markdown, MCP Playwright, mcp-greenit et tests Bash.

## Global Constraints

- Les constats d'éco-conception et les résultats EcoIndex proviennent exclusivement de mcp-greenit.
- Le DOM parcourt les Shadow DOM ouverts, compte svg, mais exclut les descendants svg; les racines fermées sont une limite.
- L'utilisateur établit la session navigateur : aucun login, mot de passe, TOTP, jeton ou storageState n'est traité.
- Les en-têtes sont non sensibles, HTTPS, listés et cloisonnés par origine; refuser le parcours si le MCP ne sait pas le garantir.
- Dédupliquer globalement les éléments partagés, mais jamais les métriques par page.
- Ne pas modifier les profils .codex/agents.

---

### Task 1: Écrire les tests en échec

**Files:**
- Modify: tests/structure/test-sustainable-it-structure.sh
- Create: tests/claude-code/test-ecocode-journey.sh
- Modify: tests/claude-code/run-skill-tests.sh

**Interfaces:**
- Consumes: textes produits dans les tâches 2 et 3.
- Produces: assertions structurelles et test de routage.

- [ ] **Step 1: Ajouter les assertions structurelles**

Ajouter après les contrôles de références existants :

~~~bash
for spec in \
  "commands/ecocode.md:/ecocode parcours" \
  "skills/audits/SKILL.md:audit-parcours.md" \
  "skills/audits/front/SKILL.md:Shadow DOM ouverts" \
  "skills/audits/report-writer/SKILL.md:audit-parcours.md" \
  "agents/ecocode-front-analyzer.md:session utilisateur" \
  ".opencode/agents/ecocode-front-analyzer.md:session utilisateur" \
  "README.md:/ecocode parcours"; do
  path="${spec%%:*}"
  pattern="${spec#*:}"
  if grep -Fq "$pattern" "$ROOT/$path"; then
    echo "✓ parcours $path"; PASS=$((PASS + 1))
  else
    echo "✗ parcours $path — motif manquant"; FAIL=$((FAIL + 1))
  fi
done
~~~

- [ ] **Step 2: Vérifier le rouge**

Run: bash tests/structure/test-sustainable-it-structure.sh

Expected: exit code non nul et motif parcours manquant.

- [ ] **Step 3: Créer le test de routage**

Créer tests/claude-code/test-ecocode-journey.sh :

~~~bash
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"
output=$(run_claude "/ecocode parcours https://example.com : explique uniquement le routage." 60)
assert_contains "$output" -i "parcours|URL" "Reconnaît le parcours"
assert_contains "$output" "ecocode-front-analyzer" "Route vers le front"
assert_contains "$output" -i "playwright|EcoIndex" "Mentionne la mesure runtime"
~~~

Ajouter test-ecocode-journey.sh à la liste tests de run-skill-tests.sh.

- [ ] **Step 4: Vérifier le rouge du routage**

Run: bash tests/claude-code/run-skill-tests.sh --test test-ecocode-journey.sh --timeout 60

Expected: échec avant l'implémentation, ou blocage explicite si claude est absent.

- [ ] **Step 5: Commit**

~~~bash
git add tests/structure/test-sustainable-it-structure.sh tests/claude-code/test-ecocode-journey.sh tests/claude-code/run-skill-tests.sh
git commit -m "test(ecocode): cover journey audit routing"
~~~

### Task 2: Ajouter les skills et agents canoniques

**Files:**
- Modify: skills/audits/SKILL.md
- Modify: skills/audits/front/SKILL.md
- Modify: skills/audits/report-writer/SKILL.md
- Modify: agents/ecocode-orchestrator.md
- Modify: agents/ecocode-front-analyzer.md
- Modify: agents/ecocode-report-writer.md

**Interfaces:**
- Consumes: parcours avec URL ou fichier JSON.
- Produces: journeyData.pages et audit-parcours.md.

- [ ] **Step 1: Ajouter le routage parent**

Ajouter avant le traitement d'une URL isolée :

~~~markdown
Si l'argument commence par parcours, interpréter les URL restantes comme un
parcours implicite ou charger le fichier JSON. Déléguer uniquement à
ecocode-front-analyzer, sans analyseur back. Le rédacteur écrit
docs/ecocode/audits/<timestamp>-audit-parcours.md.
~~~

Documenter les actions goto, click, fill, select, check, press, waitFor et audit, ainsi que parcours init qui génère seulement un JSON après confirmation.

- [ ] **Step 2: Ajouter la mesure DOM runtime**

Ajouter au skill front :

~~~js
function countDomNodes(root, insideSvg = false) {
  let total = 0;
  for (const element of root.children) {
    const isSvg = insideSvg || element.namespaceURI === "http://www.w3.org/2000/svg";
    if (!insideSvg) total += 1;
    total += countDomNodes(element, isSvg);
    if (element.shadowRoot) total += countDomNodes(element.shadowRoot, isSvg);
  }
  return total;
}
return { dom_nodes: countDomNodes(document) };
~~~

Après chaque audit, recueillir requêtes et poids, appeler greenit_calculer_ecoindex, capturer seulement une preuve utile et conserver un registre de déduplication global.

- [ ] **Step 3: Ajouter le contrat de retour**

Ajouter à l'agent front :

~~~json
{
  "scope": "journey",
  "pages": [{
    "journey": "recherche-filtre",
    "checkpoint": "resultats-filtres",
    "url": "https://example.test/recherche",
    "ecoindex": { "score": 0, "grade": "A", "co2_grams": 0, "water_cl": 0, "dom_nodes": 0, "requests": 0, "size_kb": 0 },
    "greenit_issues": [],
    "performance_issues": [],
    "development_issues": [],
    "screenshots": [],
    "duplicate_references": [],
    "limitations": []
  }]
}
~~~

Imposer session utilisateur ouverte, suspension sur login, aucun secret et aucun storageState. Accepter contexte.headers comme liste nom/valeur avec originesHeaders; refuser Authorization, Cookie, Proxy-Authorization, Set-Cookie et tout jeton, mot de passe ou clé. Refuser si l'isolation des origines est impossible.

- [ ] **Step 4: Ajouter le rapport**

Ajouter au skill et à l'agent rédacteur le fichier audit-parcours.md :

~~~markdown
# Audit Éco-conception de parcours — [Nom du projet]

## [Nom du parcours]
### [Point d'audit]
**URL :** …
**EcoIndex :** … — Grade …
**GES :** …
**Eau :** …

## Écarts GreenIT
## Performance
## Développement web
## Limites et erreurs d'exécution
~~~

Les extraits avant/après ne sont inclus que si le code est accessible; un doublon est remplacé par une référence à la première occurrence.

- [ ] **Step 5: Vérifier et commit**

Run: bash tests/structure/test-sustainable-it-structure.sh

Expected: les assertions des skills et agents canoniques passent.

~~~bash
git add skills/audits/SKILL.md skills/audits/front/SKILL.md skills/audits/report-writer/SKILL.md agents/ecocode-orchestrator.md agents/ecocode-front-analyzer.md agents/ecocode-report-writer.md
git commit -m "feat(ecocode): add journey audit workflow"
~~~

### Task 3: Synchroniser OpenCode et documenter

**Files:**
- Modify: .opencode/agents/ecocode-orchestrator.md
- Modify: .opencode/agents/ecocode-front-analyzer.md
- Modify: .opencode/agents/ecocode-report-writer.md
- Modify: commands/ecocode.md
- Modify: .opencode/commands/ecocode.md
- Modify: README.md
- Modify: docs/README.opencode.md
- Modify: .codex/INSTALL.md

**Interfaces:**
- Consumes: contrats de la tâche 2.
- Produces: comportement et documentation identiques sur toutes les plateformes.

- [ ] **Step 1: Synchroniser OpenCode**

Reporter les instructions canoniques de parcours dans les trois agents .opencode. Ne pas modifier les TOML Codex.

- [ ] **Step 2: Documenter les entrées et exemples**

Documenter dans les commandes et guides :

~~~text
/ecocode parcours <url1> <url2> ...
/ecocode parcours chemin/vers/parcours.json
/ecocode parcours init
~~~

Inclure les trois exemples validés : URLs simples, interactions et mélange. Expliquer session utilisateur obligatoire, absence de secrets et storageState, et en-têtes non sensibles limités aux origines HTTPS.

- [ ] **Step 3: Vérifier et commit**

Run: bash tests/structure/test-sustainable-it-structure.sh && git diff --check

Expected: exit code 0.

~~~bash
git add .opencode/agents/ecocode-orchestrator.md .opencode/agents/ecocode-front-analyzer.md .opencode/agents/ecocode-report-writer.md commands/ecocode.md .opencode/commands/ecocode.md README.md docs/README.opencode.md .codex/INSTALL.md
git commit -m "docs(ecocode): document journey audits"
~~~

### Task 4: Vérification finale

**Files:**
- Verify: fichiers modifiés par les tâches 1 à 3

- [ ] **Step 1: Exécuter la structure complète**

Run: bash tests/structure/test-sustainable-it-structure.sh

Expected: 0 échec et exit code 0.

- [ ] **Step 2: Exécuter les tests Claude Code**

Run: bash tests/claude-code/run-skill-tests.sh --timeout 60

Expected: STATUT : OK; si claude est absent, signaler ce blocage externe sans déclarer la réussite.

- [ ] **Step 3: Vérifier les contraintes sensibles**

Run: rg -n 'otpauth://|secretEnv|authProfile|AUDIT_(PASSWORD|TOKEN|TOTP)' commands README.md docs skills agents .opencode .codex || true

Expected: aucune référence à une graine, un secret, une authentification automatique ou une variable d'environnement de secret. Les mentions documentaires de l'interdiction de storageState sont attendues.

- [ ] **Step 4: Relecture**

Comparer le diff aux contraintes globales : URL et JSON, étapes autorisées, session utilisateur, en-têtes cloisonnés, EcoIndex GreenIT, SVG/Shadow DOM, déduplication globale, sections séparées et copies OpenCode.
