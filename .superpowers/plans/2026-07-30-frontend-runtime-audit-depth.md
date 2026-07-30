# Frontend Runtime Audit Depth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `/ecocode frontend` deliver evidence-backed, complete ecodesign reports enriched with browser performance and web-development diagnostics.

**Architecture:** Keep the current Playwright and `mcp-greenit` stack. Extend the strict `frontendData` contract with probe coverage and verification leads, then make the runtime analyzer collect a fixed read-only diagnostic matrix and the report writer render the multipage, action-oriented report. Structural shell tests protect the contract across the canonical, OpenCode and report-writer instructions.

**Tech Stack:** Markdown skills and agents, Playwright MCP/Chrome DevTools data, `mcp-greenit`, Bash structure tests.

## Global Constraints

- Do not add Lighthouse, another browser, an external audit service or a package dependency.
- Keep EcoIndex inputs limited to the initial fresh-context navigation.
- Fixed Playwright probes may run; never execute JavaScript supplied by an audit input.
- Preserve HTTP(S), authentication, secret, header and mutation-confirmation safeguards.
- A GreenIT finding needs an exact MCP-returned fiche; unproven business necessity belongs only in `A verifier`.
- A C-to-G EcoIndex page must explain material contributors or explicitly state the uncovered scope.
- Create the plan only under `.superpowers/plans/`; do not create `docs/superpowers/`.

---

## File Structure

| File | Responsibility |
| --- | --- |
| `skills/audits/frontend/SKILL.md` | Canonical runtime workflow, fixed diagnostic matrix, EcoIndex coherence gate and strict enriched JSON contract. |
| `agents/ecocode-frontend-analyzer.md` | Canonical analyzer instructions, probe execution order and exact output example. |
| `.opencode/agents/ecocode-frontend-analyzer.md` | OpenCode analyzer parity with the canonical contract. |
| `skills/audits/report-writer/SKILL.md` | Detailed multipage template for `audit-frontend.md`. |
| `agents/ecocode-report-writer.md` | Canonical writer instructions for the enriched runtime data. |
| `.opencode/agents/ecocode-report-writer.md` | OpenCode writer parity and removal of its unavailable pinned model. |
| `tests/structure/test-frontend-runtime-contract.sh` | Contract assertions covering diagnostics, output additions, report sections and OpenCode writer configuration. |
| `.superpowers/specs/2026-07-30-frontend-runtime-audit-depth-design.md` | Approved design reference; do not change during implementation unless a requirement changes. |

## Task 1: Define The Enriched Runtime Contract

**Files:**
- Modify: `skills/audits/frontend/SKILL.md:141-282`
- Modify: `tests/structure/test-frontend-runtime-contract.sh:97-159`

**Interfaces:**
- Consumes: the existing page object with `metriques`, `ecoindex`, `ecarts_greenit`, `performance`, `developpement_web`, `deduplication`, `capture` and `limites`.
- Produces: a page object that additionally exposes `a_verifier` and `couverture`; every later task consumes these exact names.

- [ ] **Step 1: Add failing structural assertions for the contract additions**

Add these assertions after the existing `section développement séparée` assertion:

```bash
contains "skill définit la matrice de sondes" "$SKILL" '### Matrice de sondes fixe'
contains "skill impose la coherence EcoIndex" "$SKILL" '### Garde-fou de cohérence EcoIndex'
contains "skill sépare les pistes à vérifier" "$SKILL" '### À vérifier'
contains "skill définit la couverture" "$SKILL" '`couverture`'
contains "skill définit les pistes à vérifier" "$SKILL" '`a_verifier`'
contains "skill protège le calcul initial" "$SKILL" 'ne modifie jamais les entrées EcoIndex'
contains "skill refuse un audit vide pour grade bas" "$SKILL" 'grade C à G'
```

- [ ] **Step 2: Run the contract test to verify it fails**

Run: `bash tests/structure/test-frontend-runtime-contract.sh`

Expected: non-zero exit with the seven new missing-pattern messages.

- [ ] **Step 3: Add the diagnostic workflow to the canonical skill**

Insert this section immediately after the current runtime metrics section:

```markdown
### Matrice de sondes fixe

Après la mesure initiale et avant la qualification des constats, exécuter les
sondes internes et déterministes suivantes. Ne jamais exécuter de JavaScript
fourni par l'entrée ; les évaluations Playwright servent uniquement à lire l'état
de la page.

| Domaine | Preuves à collecter |
| --- | --- |
| Réseau | Type, domaine, statut, protocole, redirection, en-têtes de cache et compression, taille transférée, timings et erreurs. |
| Scripts et styles | URLs, doublons, tiers, modules CMS identifiables, erreurs console et ressources en échec. |
| Images et médias | Source servie, format, dimensions naturelles et affichées, `srcset`, `sizes`, `loading`, position dans le viewport, iframe, vidéo, audio et autoplay. |
| Composants | Carrousels Swiper/Slick/Splide/Owl ou équivalents ARIA, instances, diapositives, contrôles, animations actives et canvas. |
| Qualité web | Erreurs console, réponses 4xx/5xx, IDs dupliqués, médias cassés et dimensions intrinsèques manquantes. |

Une sonde peut déclencher un défilement progressif, sans clic ni saisie, pour
observer les médias situés sous la ligne de flottaison. Cette phase est séparée
de la fenêtre de collecte initiale et ne modifie jamais les entrées EcoIndex.
```

Insert this section after the matrix:

```markdown
### Garde-fou de cohérence EcoIndex

EcoIndex est un résultat, pas la preuve d'une fiche RWEB précise. Pour chaque
page de grade C à G, l'audit doit expliquer les contributeurs matériels aux
nœuds DOM, requêtes et octets transférés. Chacun doit produire un écart GreenIT
prouvé, une alerte Performance ou Développement web, une entrée `a_verifier`, ou
une limite de mesure explicite.

Si la première passe est insuffisante, exécuter toute la matrice puis le
défilement progressif autorisé. Si le score reste inexpliqué, retourner une
limite `analyse_inconcluante` décrivant le périmètre non mesuré. Ne jamais
inventer un écart GreenIT pour remplir le rapport.
```

- [ ] **Step 4: Extend the strict output schema and qualification rules**

Replace the page-row definition with this exact key set:

```markdown
| page | `nom`, `url`, `metriques`, `ecoindex`, `ecarts_greenit`, `performance`, `developpement_web`, `a_verifier`, `couverture`, `deduplication`, `capture`, `limites` | deux strings ; deux objects ; six arrays ; string ou null |
```

Add these exact object definitions under the existing web-development row:

```markdown
| à vérifier | `deduplication_key`, `severity`, `observation`, `preuve`, `impact`, `localisation`, `correction` | six strings, puis string ou null |
| couverture | `domaine`, `statut`, `message` | trois strings |
```

Add the following normative text:

```markdown
`a_verifier` contient les observations crédibles dont l'utilité métier, la cause
racine ou la nécessité légale ne peut pas être établie depuis le navigateur. Une
ressource nommée n'est jamais qualifiée d'inutilisée par sa seule présence.

`couverture` contient une ligne par domaine de la matrice. `statut` vaut
`mesure`, `non_applicable`, `non_mesurable` ou `erreur`. Une page de grade C à G
ne peut pas avoir toutes ses listes de constats vides sans une limite
`analyse_inconcluante`.
```

Add `### À vérifier` under `### Développement web` and define it as browser
evidence that requires business or source-code validation, not as a GreenIT
finding.

- [ ] **Step 5: Run the contract test to verify it passes**

Run: `bash tests/structure/test-frontend-runtime-contract.sh`

Expected: exit 0 and the new matrix, coherence, `a_verifier` and `couverture`
assertions marked passed.

- [ ] **Step 6: Commit the contract change**

```bash
git add skills/audits/frontend/SKILL.md tests/structure/test-frontend-runtime-contract.sh
git commit -m "feat(ecocode): deepen runtime audit contract"
```

## Task 2: Align Runtime Analyzer Instructions

**Files:**
- Modify: `agents/ecocode-frontend-analyzer.md:28-171`
- Modify: `.opencode/agents/ecocode-frontend-analyzer.md:8-26`
- Modify: `tests/structure/test-frontend-runtime-contract.sh:140-180`

**Interfaces:**
- Consumes: the new canonical contract from Task 1.
- Produces: `frontendData.pages[*].a_verifier` and `frontendData.pages[*].couverture` with the exact types from Task 1.

- [ ] **Step 1: Add failing assertions for analyzer parity**

Add these assertions after the current agent-output assertions:

```bash
contains "agent exécute la matrice de sondes" "$AGENT" 'Matrice de sondes fixe'
contains "agent explique les scores EcoIndex bas" "$AGENT" 'Garde-fou de cohérence EcoIndex'
contains "agent transmet les pistes à vérifier" "$AGENT" '"a_verifier"'
contains "agent transmet la couverture" "$AGENT" '"couverture"'
contains "analyseur OpenCode transmet les pistes à vérifier" "$OPENCODE_ANALYZER" '`a_verifier`'
contains "analyseur OpenCode transmet la couverture" "$OPENCODE_ANALYZER" '`couverture`'
```

- [ ] **Step 2: Run the contract test to verify it fails**

Run: `bash tests/structure/test-frontend-runtime-contract.sh`

Expected: non-zero exit with the six new missing-pattern messages.

- [ ] **Step 3: Add the canonical analyzer probe protocol and output example**

Add a `## Matrice de sondes fixe` section after `## Contraintes impératives`:

```markdown
Pour chaque point d'audit, après la mesure EcoIndex initiale, exécute les cinq
domaines définis par `audits/frontend` : réseau, scripts/styles, images/médias,
composants et qualité web. Utilise les requêtes, snapshots, console et
évaluations Playwright internes pour constituer les preuves. Une évaluation ne
lit que le DOM et les API navigateur ; elle n'exécute aucun code issu de
l'entrée utilisateur.

Retourne une entrée `couverture` pour chacun des cinq domaines. Pour une page
de grade C à G, explique chaque contributeur matériel dans une section de
constat, `a_verifier` ou limite `analyse_inconcluante`. Une bibliothèque ou un
outil de consentement observé sans preuve de son inutilité va uniquement dans
`a_verifier`.
```

In the JSON example, add this exact page data after `developpement_web`:

```json
"a_verifier": [
  {
    "deduplication_key": "script:https://example.com/search.js",
    "severity": "moyenne",
    "observation": "Un module de recherche est chargé au démarrage.",
    "preuve": "URL du script observée dans la fenêtre réseau.",
    "impact": "Le navigateur ne permet pas d'établir son utilité métier.",
    "localisation": "parcours/accueil",
    "correction": "Valider son besoin puis différer ou retirer le module si possible."
  }
],
"couverture": [
  {
    "domaine": "composants",
    "statut": "mesure",
    "message": "Carrousels et animations inspectés."
  }
],
```

- [ ] **Step 4: Align the OpenCode analyzer**

Replace its result-description paragraph with:

```markdown
Retourne le même objet JSON strict que l'agent canonique
`agents/ecocode-frontend-analyzer.md`, y compris `a_verifier` et `couverture`.
Exécute la matrice de sondes fixe après la mesure EcoIndex initiale : réseau,
scripts/styles, images/médias, composants et qualité web. Pour un grade C à G,
explique les contributeurs matériels ou retourne une limite
`analyse_inconcluante`; ne crée jamais un écart GreenIT sans fiche MCP et preuve
mesurée.
```

- [ ] **Step 5: Run the contract test to verify it passes**

Run: `bash tests/structure/test-frontend-runtime-contract.sh`

Expected: exit 0 and all canonical/OpenCode analyzer assertions pass.

- [ ] **Step 6: Commit the analyzer change**

```bash
git add agents/ecocode-frontend-analyzer.md .opencode/agents/ecocode-frontend-analyzer.md tests/structure/test-frontend-runtime-contract.sh
git commit -m "feat(ecocode): add runtime diagnostic probes"
```

## Task 3: Render The Actionable Multipage Runtime Report

**Files:**
- Modify: `skills/audits/report-writer/SKILL.md:115-182`
- Modify: `agents/ecocode-report-writer.md:15-34`
- Modify: `.opencode/agents/ecocode-report-writer.md:1-33`
- Modify: `tests/structure/test-frontend-runtime-contract.sh:186-193`

**Interfaces:**
- Consumes: enriched `frontendData` from Task 2, particularly per-page `a_verifier`, `couverture`, metrics and deduplicated findings.
- Produces: exactly one `docs/ecocode/audits/{timestamp}-audit-frontend.md` with the sections below; it never launches an audit or reads source code.

- [ ] **Step 1: Add failing report-format assertions**

Add these assertions after the existing report-skill assertions:

```bash
contains "rédacteur produit la synthèse executive" "$REPORT_SKILL" '## Synthèse exécutive'
contains "rédacteur décrit la couverture" "$REPORT_SKILL" '## Périmètre, méthode et couverture'
contains "rédacteur compare les pages" "$REPORT_SKILL" '## Comparatif des pages'
contains "rédacteur consolide les constats" "$REPORT_SKILL" '## Constats transverses'
contains "rédacteur produit les gains potentiels" "$REPORT_SKILL" '## Résumé des gains potentiels'
contains "rédacteur produit le plan intégré" "$REPORT_SKILL" '## Plan d’action priorisé'
contains "rédacteur produit la conclusion" "$REPORT_SKILL" '## Conclusion'
excludes "rédacteur OpenCode n'épingle pas un modèle indisponible" "$OPENCODE_REPORT_AGENT" 'anthropic/claude-3-5-sonnet-20241022'
```

- [ ] **Step 2: Run the contract test to verify it fails**

Run: `bash tests/structure/test-frontend-runtime-contract.sh`

Expected: non-zero exit with missing report-section assertions and the stale
OpenCode model assertion.

- [ ] **Step 3: Replace the runtime report template with the approved structure**

Replace the current runtime template section in `skills/audits/report-writer/SKILL.md`
with the following required headings and rules:

```markdown
## Synthèse exécutive
Afficher les pages, grades, principaux leviers et les actions P1/P2.

## Périmètre, méthode et couverture
Afficher la fenêtre de collecte initiale, le défilement éventuel, les limites et
la table des domaines `couverture` par page. Distinguer mesure initiale et
diagnostic complémentaire.

## Comparatif des pages
Afficher DOM, requêtes, transfert, EcoIndex, GES et eau pour chaque page.

## Résultats par page
Pour chaque page, écrire successivement : Écarts GreenIT, Performance,
Développement web, À vérifier, preuves, déduplications et limites.

## Constats transverses
Regrouper les composants, scripts, tiers, polices, médias, cache et redirections
partagés sans masquer les métriques de chaque page.

## Écarts GreenIT consolidés
Grouper les constats non dédupliqués par identifiant et intitulé RWEB exact.

## Performance
Récapituler les alertes mesurées sans fiche RWEB.

## Développement web
Récapituler les erreurs navigateur, DOM, API et ressources observées sans fiche
RWEB. Ne pas conclure à la conformité RGAA.

## Résumé des gains potentiels
Utiliser les colonnes `Levier`, `Situation actuelle`, `Objectif`, `Gain
potentiel` et `Confiance`. Chiffrer uniquement un gain déduit de données reçues;
sinon indiquer un gain qualitatif et la mesure avant/après requise.

## Plan d’action priorisé
Utiliser les colonnes `Priorité`, `Action`, `Périmètre`, `Justification` et
`Vérification après correction`. Prioriser P1 à P4 avec la grille effort/impact.

## Conclusion
Résumer les facteurs d’impact, les premières actions et la condition d'une
mesure comparative fiable.

## Erreurs d’exécution et limites
Conserver les erreurs et limites globales sans inventer de données.
```

- [ ] **Step 4: Update both writer agents**

Append this requirement to `agents/ecocode-report-writer.md` and
`.opencode/agents/ecocode-report-writer.md`:

```markdown
Pour `frontendData`, appliquer exactement la structure runtime détaillée du
skill `audits/report-writer` : synthèse, couverture, comparatif, résultats par
page, constats transverses, consolidation GreenIT, Performance, Développement
web, gains potentiels, plan d'action, conclusion et limites. N'invente jamais
un gain chiffré ou une preuve absente.
```

Remove this line from `.opencode/agents/ecocode-report-writer.md` so OpenCode
uses an available configured model:

```yaml
model: anthropic/claude-3-5-sonnet-20241022
```

- [ ] **Step 5: Run the contract test to verify it passes**

Run: `bash tests/structure/test-frontend-runtime-contract.sh`

Expected: exit 0, all detailed report assertions pass, and the stale model
assertion passes.

- [ ] **Step 6: Commit the report change**

```bash
git add skills/audits/report-writer/SKILL.md agents/ecocode-report-writer.md .opencode/agents/ecocode-report-writer.md tests/structure/test-frontend-runtime-contract.sh
git commit -m "feat(ecocode): enrich runtime audit reports"
```

## Task 4: Validate The Complete Plugin Contract

**Files:**
- Modify: `docs/testing.md:3-44` only if a new command is required; otherwise no documentation change.
- Test: `tests/structure/test-frontend-runtime-contract.sh`
- Test: `tests/structure/test-sustainable-it-structure.sh`
- Test: `tests/structure/test-yaml-frontmatter.sh`
- Test: `tests/claude-code/run-skill-tests.sh`

**Interfaces:**
- Consumes: all instructions and structural assertions delivered by Tasks 1-3.
- Produces: verified canonical/OpenCode runtime audit instructions and report writer configuration.

- [ ] **Step 1: Run the focused runtime contract test**

Run: `bash tests/structure/test-frontend-runtime-contract.sh`

Expected: `Résultat` reports zero failures.

- [ ] **Step 2: Run the repository structure checks**

Run: `bash tests/structure/test-sustainable-it-structure.sh`

Expected: exit 0.

Run: `bash tests/structure/test-yaml-frontmatter.sh`

Expected: exit 0.

- [ ] **Step 3: Run the Claude Code skill tests**

Run: `./tests/claude-code/run-skill-tests.sh`

Expected: exit 0 with no failed skill test.

- [ ] **Step 4: Manually inspect the final contract for safety invariants**

Confirm that the final text still contains all of the following:

```text
No user-supplied JavaScript execution
HTTP(S)-only navigation and no URL credentials
No secrets or storageState
No unconfirmed remote interaction
EcoIndex initial-load metrics unchanged by progressive scroll
No invented RWEB finding or numerical gain
```

- [ ] **Step 5: Commit verification-only documentation if changed**

If and only if `docs/testing.md` changed:

```bash
git add docs/testing.md
git commit -m "docs: document runtime audit verification"
```

## Plan Self-Review

- Spec coverage: Tasks 1-3 cover the fixed probe matrix, C-to-G coherence gate,
  strict contract additions, report structure, potential gains, prioritization,
  accessibility guardrail and no-Lighthouse constraint. Task 4 covers the
  required contract and regression checks.
- Completeness scan: no unfinished implementation marker or undefined interface
  remains.
- Type consistency: `a_verifier` and `couverture` are named consistently in the
  skill, canonical agent, OpenCode agent, writer instructions and tests.
