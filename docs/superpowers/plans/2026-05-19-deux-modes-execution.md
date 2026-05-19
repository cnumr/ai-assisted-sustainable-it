# Deux modes d'exécution (auto / interactif) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ajouter une question de mode en début d'audit — "auto" enchaîne sans interruption jusqu'au plan d'action, "interactif" demande confirmation avant chaque étape d'écriture.

**Architecture:** La réponse au mode est capturée à l'Étape 0 du skill et mémorisée en contexte LLM. Les Étapes 4 et 5 branchent conditionnellement selon ce mode. Aucun état persistant, aucun fichier de config — tout se passe dans les instructions markdown des agents.

**Tech Stack:** Markdown skill files (instructions LLM), YAML frontmatter agent definitions (Claude Code + OpenCode)

---

### Task 1 : Modifier `skills/ecocode/SKILL.md` — Étape 0 + branches conditionnelles

**Files:**

- Modify: `skills/ecocode/SKILL.md`

Note : ces fichiers sont des instructions markdown pour LLM, pas du code. Il n'y a pas de tests unitaires. La vérification se fait par relecture logique du fichier modifié.

- [ ] **Step 1 : Ajouter Étape 0 avant Étape 1**

Insérer le bloc suivant entre la fin du diagramme de routing (ligne ~40, juste après la dernière ligne `}`) et le titre `## Étape 1 — Identifier le périmètre` :

```markdown
## Étape 0 — Choisir le mode d'exécution

Avant toute analyse, poser cette question :

> "Mode d'exécution pour cet audit :
>
> - **auto** — l'audit s'enchaîne sans interruption : analyse → fichiers d'audit → plan d'action. Tu reçois un résumé des fichiers créés à la fin.
> - **interactif** — tu confirmes avant l'écriture des fichiers et avant la génération du plan.
>
> (auto/interactif)"

Garder le mode choisi en contexte pour les Étapes 4 et 5.
```

- [ ] **Step 2 : Remplacer Étape 4 — Écrire les fichiers d'audit**

Remplacer le contenu de la section `## Étape 4 — Écrire les fichiers d'audit` (du titre jusqu'à la ligne vide avant `## Étape 5`) par :

```markdown
## Étape 4 — Écrire les fichiers d'audit

**Si mode `auto` :** déléguer immédiatement à `ecocode-report-writer` sans confirmation. Conserver les chemins retournés pour le résumé final de l'Étape 5.

**Si mode `interactif` :** poser d'abord la question :

> "L'analyse est terminée. Veux-tu que j'écrive les fichiers d'audit dans `docs/ecocode/audits/` ? (o/n)"

- Si **oui** : déléguer à `ecocode-report-writer` en lui transmettant les mêmes données (résultats front, résultats back, nom du projet, scores calculés). Afficher les chemins créés.
- Si **non** : terminer. Ne pas passer à l'Étape 5.

Dans les deux cas, transmettre à `ecocode-report-writer` :

- Les résultats complets de l'agent front (tableau de problèmes + bonnes pratiques respectées + métriques EcoIndex)
- Les résultats complets de l'agent back (tableau de problèmes + bonnes pratiques respectées)
- Le nom du projet (déduit du dossier courant ou demandé à l'utilisateur)
- Les scores calculés (EcoIndex officiel + score d'impact interne)

L'agent écrit les fichiers horodatés dans `docs/ecocode/audits/` et retourne leurs chemins.
```

- [ ] **Step 3 : Remplacer Étape 5 — Plan d'action**

Remplacer le contenu de la section `## Étape 5 — Plan d'action sur demande` (du titre jusqu'à la ligne `**Règle token :**...`) par :

```markdown
## Étape 5 — Plan d'action

**Si mode `auto` :** déléguer immédiatement à `ecocode-planner` en lui transmettant :

- L'ensemble des problèmes détectés (couche, localisation, code exact, sévérité, RWEB_XXXX)
- Les bonnes pratiques déjà respectées
- Le timestamp utilisé pour les fichiers d'audit (pour cohérence du nommage)
- Le framework/ORM détecté (pour adapter le code "Après")

Puis afficher le résumé final :

> "Audit terminé. Fichiers créés :
>
> - `docs/ecocode/audits/{timestamp}-audit-front.md`
> - `docs/ecocode/audits/{timestamp}-audit-back.md`
> - `docs/ecocode/plans/{timestamp}-plan.md`"
>
> _(N'afficher que les fichiers effectivement créés selon le périmètre analysé.)_

**Si mode `interactif` :** poser la question :

> "Veux-tu un plan d'action priorisé ? Il liste les corrections P1→P4 avec le code avant/après et les commandes exactes pour chaque problème. (o/n)"

- Si **oui** : déléguer à `ecocode-planner` avec les mêmes données listées ci-dessus. Afficher le chemin du fichier créé :

  > "Plan d'action écrit dans : `docs/ecocode/plans/{timestamp}-plan.md`"

- Si **non** : terminer. Ne pas générer de contenu supplémentaire.

**Règle token :** L'agent planificateur reçoit les données du contexte de la session. Ne pas relancer d'analyse, ne pas relire de fichiers source.
```

- [ ] **Step 4 : Vérifier la cohérence du fichier final**

Relire `skills/ecocode/SKILL.md` en entier et vérifier :

- Étape 0 est présente avant Étape 1
- Étape 4 contient deux branches claires (`auto` / `interactif`)
- Étape 5 contient deux branches claires (`auto` / `interactif`)
- Le mode `auto` de l'Étape 5 affiche un résumé consolidé de tous les fichiers créés
- Les sections "Calcul de l'EcoIndex officiel", "Calcul du score d'impact interne", "Priorisation effort/impact", "Erreurs fréquentes" sont intactes

- [ ] **Step 5 : Commit**

```bash
git add skills/ecocode/SKILL.md
git commit -m "feat(ecocode): ajouter modes auto/interactif dans le skill orchestrateur"
```

---

### Task 2 : Modifier `agents/ecocode-orchestrator.md` — étape mode + branches conditionnelles

**Files:**

- Modify: `agents/ecocode-orchestrator.md`

- [ ] **Step 1 : Ajouter l'étape de sélection du mode (step 1), renommer les steps existants**

Remplacer tout le corps du fichier (après le frontmatter YAML `---`) par :

```markdown
Tu es l'orchestrateur de l'audit éco-conception. Utilise le skill `ecocode` comme guide principal pour toute ta démarche.

Quand tu reçois une demande d'audit :

1. **Choisis le mode d'exécution** en posant la question :

   > "Mode d'exécution pour cet audit :
   >
   > - **auto** — l'audit s'enchaîne sans interruption : analyse → fichiers d'audit → plan d'action. Tu reçois un résumé des fichiers créés à la fin.
   > - **interactif** — tu confirmes avant l'écriture des fichiers et avant la génération du plan.
   >
   > (auto/interactif)"

   Garder le mode choisi en contexte pour les étapes 5 et 6.

2. **Identifie le périmètre** en lisant le projet (fichiers source, package.json, structure des dossiers, URLs fournies). Détermine si l'analyse concerne le front, le back, ou les deux.

3. **Charge le référentiel Green IT** via le MCP `mcp-greenit` :
   - Appelle `fiches_prioritaires` pour identifier les pratiques à fort impact à prioriser
   - Garde les IDs des pratiques pour les transmettre aux agents spécialisés

4. **Délègue l'analyse** aux agents spécialisés en leur transmettant :
   - Le périmètre exact à analyser (chemins de fichiers, URLs)
   - Les pratiques Green IT prioritaires à vérifier en premier
   - Les instructions pour retourner un rapport structuré JSON + markdown
   - **Agent front :** `ecocode-front-analyzer` (si front détecté)
   - **Agent back :** `ecocode-back-analyzer` (si back détecté)
   - Si full-stack : lancer les deux agents en parallèle

5. **Agrège les résultats** : calcule le score d'impact interne (base 5 + 0,5 par Haute + 0,2 par Moyenne − 0,1 par bonne pratique respectée, plafonné 1–10) sur toutes les couches.

6. **Écris les fichiers d'audit** :

   **Si mode `auto` :** déléguer immédiatement à `ecocode-report-writer` en transmettant les résultats complets des deux agents, le nom du projet, et les scores calculés. Conserver les chemins retournés pour le résumé final.

   **Si mode `interactif` :** demander d'abord :

   > "L'analyse est terminée. Veux-tu que j'écrive les fichiers d'audit dans `docs/ecocode/audits/` ? (o/n)"
   - Si **oui** : déléguer à `ecocode-report-writer` et afficher les chemins créés.
   - Si **non** : terminer ici.

7. **Génère le plan d'action** :

   **Si mode `auto` :** déléguer immédiatement à `ecocode-planner` avec l'ensemble des problèmes détectés (localisation exacte, code, sévérité, RWEB_XXXX, framework détecté) et le timestamp des fichiers d'audit. Puis afficher le résumé final :

   > "Audit terminé. Fichiers créés :
   >
   > - `docs/ecocode/audits/{timestamp}-audit-front.md`
   > - `docs/ecocode/audits/{timestamp}-audit-back.md`
   > - `docs/ecocode/plans/{timestamp}-plan.md`"
   >
   > _(N'afficher que les fichiers effectivement créés selon le périmètre analysé.)_

   **Si mode `interactif` :** demander à l'utilisateur s'il veut un plan d'action priorisé (o/n). Si oui, déléguer à `ecocode-planner` avec les mêmes données et afficher le chemin du fichier créé.

**Contraintes :**

- Ne modifie jamais les fichiers source du projet — tu es en lecture seule pour l'analyse
- Pour les corrections, délègue à `ecocode-fix-suggester`. Pour les rapports et plans, délègue aux agents spécialisés.
- Toujours baser le rapport sur les pratiques officielles de `mcp-greenit`, pas sur des suppositions
```

- [ ] **Step 2 : Vérifier le fichier**

Relire `agents/ecocode-orchestrator.md` et vérifier :

- Le frontmatter YAML est intact (`name`, `model`, `tools`)
- 7 étapes numérotées (1 = mode, 2 = périmètre, 3 = MCP, 4 = délégation analyse, 5 = agrégation, 6 = fichiers audit, 7 = plan)
- Étape 6 contient deux branches `auto` / `interactif`
- Étape 7 contient deux branches `auto` / `interactif`
- Le résumé final en mode `auto` liste tous les chemins

- [ ] **Step 3 : Commit**

```bash
git add agents/ecocode-orchestrator.md
git commit -m "feat(ecocode/back): ajouter modes auto/interactif dans l'orchestrateur Claude Code"
```

---

### Task 3 : Modifier `.opencode/agents/ecocode-orchestrator.md`

**Files:**

- Modify: `.opencode/agents/ecocode-orchestrator.md`

- [ ] **Step 1 : Mettre à jour le corps (même contenu que Task 2)**

Le frontmatter OpenCode est différent du frontmatter Claude Code, mais le corps (les instructions) est identique. Remplacer uniquement le corps (après le `---` de fermeture du frontmatter) par le même contenu que Task 2 Step 1 (de `Tu es l'orchestrateur...` jusqu'à `...pas sur des suppositions`).

Le frontmatter à conserver intact :

```yaml
---
description: >
  Orchestrateur principal pour les audits d'éco-conception. Déclenche-toi dès
  qu'on demande un audit ecocode, une analyse d'impact écologique, ou une revue
  green IT d'une application. Détermine si l'analyse porte sur le front, le back
  ou les deux, délègue aux agents spécialisés, puis agrège les résultats en un
  rapport unifié avec score global et plan d'action priorisé.
mode: subagent
model: anthropic/claude-sonnet-4-5
permission:
  edit: deny
---
```

- [ ] **Step 2 : Vérifier le fichier**

Relire `.opencode/agents/ecocode-orchestrator.md` et confirmer :

- Frontmatter OpenCode intact (`mode: subagent`, `model: anthropic/...`, `permission: edit: deny`)
- Corps identique à `agents/ecocode-orchestrator.md`

- [ ] **Step 3 : Commit**

```bash
git add .opencode/agents/ecocode-orchestrator.md
git commit -m "feat(ecocode/back): aligner l'orchestrateur OpenCode avec les modes auto/interactif"
```

---

### Task 4 : Mettre à jour `README.md`

**Files:**

- Modify: `README.md`

- [ ] **Step 1 : Remplacer la section "Modes de rapport"**

La section actuelle (lignes ~39-45) décrit les modes de rapport (fichiers auto + plan sur demande). La remplacer par une section "Modes d'exécution" qui documente les deux modes :

Remplacer :

```markdown
### Modes de rapport

Chaque audit génère :

1. **Fichiers d'audit** (automatiques) : deux fichiers markdown horodatés dans `docs/ecocode/audits/` — un par couche analysée. Destinés aux développeurs de chaque domaine.

2. **Plan d'action** (sur demande) : un fichier dans `docs/ecocode/plans/` avec les corrections priorisées P1→P4, cases à cocher, code avant/après et commandes exactes.
```

Par :

```markdown
### Modes d'exécution

En début d'audit, le plugin demande le mode souhaité :

| Mode           | Comportement                                                                                                 |
| -------------- | ------------------------------------------------------------------------------------------------------------ |
| **auto**       | Enchaîne sans interruption : analyse → fichiers d'audit → plan d'action. Résumé des fichiers créés à la fin. |
| **interactif** | Demande confirmation avant d'écrire les fichiers d'audit, puis avant de générer le plan d'action.            |

Les deux modes génèrent les mêmes fichiers dans `docs/ecocode/audits/` et `docs/ecocode/plans/`.
```

- [ ] **Step 2 : Vérifier le fichier**

Relire `README.md` et confirmer :

- La section "Modes d'exécution" est présente avec le tableau comparatif
- Les autres sections (Prérequis, Skills, Agents, Utilisation, Installation) sont intactes

- [ ] **Step 3 : Commit**

```bash
git add README.md
git commit -m "docs: documenter les modes auto/interactif dans le README"
```

---

### Task 5 : Mettre à jour `CHANGELOG.md`

**Files:**

- Modify: `CHANGELOG.md`

- [ ] **Step 1 : Ajouter l'entrée sous [Unreleased] → Ajouté**

Dans la section `## [Unreleased]` → `### Ajouté`, ajouter une ligne **avant** les entrées existantes :

```markdown
- Deux modes d'exécution : `auto` (audit complet sans interruption avec résumé final) et `interactif` (confirmations avant l'écriture des fichiers et avant le plan d'action)
```

- [ ] **Step 2 : Vérifier le fichier**

Relire `CHANGELOG.md` et confirmer que la nouvelle entrée est en tête de la liste `### Ajouté` et que les entrées précédentes sont intactes.

- [ ] **Step 3 : Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: ajouter les modes auto/interactif dans le changelog"
```

---

## Self-Review

**Spec coverage :**

- ✅ Mode auto : audit enchaîné sans interruption → Tasks 1 + 2 + 3
- ✅ Mode interactif : confirmations à chaque étape d'écriture → Tasks 1 + 2 + 3
- ✅ Question de mode en début d'audit → Étape 0 (SKILL.md) + Step 1 (orchestrateur)
- ✅ Résumé final consolidé en mode auto → Étapes 4-5 SKILL.md + Steps 6-7 orchestrateur
- ✅ Comportement interactif = comportement actuel de l'Étape 5 + nouvelle gate sur l'Étape 4
- ✅ Documentation → Tasks 4 + 5
- ✅ Alignement Claude Code / OpenCode → Tasks 2 + 3

**Placeholder scan :** aucun TBD, aucun "similar to Task N", chaque step contient le contenu exact à écrire.

**Cohérence des termes :**

- Mode nommé `auto` partout (pas "automatique" dans le code)
- Mode nommé `interactif` partout
- "Résumé final" toujours en Étape 5 / Step 7 (pas en Étape 4 / Step 6)
- `ecocode-report-writer` et `ecocode-planner` nommés de façon cohérente
