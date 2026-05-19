# Rapport Fichiers + Plan d'Action EcoCode — Plan d'Implémentation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remplacer l'affichage terminal du rapport d'audit EcoCode par l'écriture de fichiers markdown séparés (front/back dans `docs/ecocode/audits/`), et ajouter un agent planificateur qui génère un plan d'action priorisé dans `docs/ecocode/plans/`.

**Architecture:** Deux nouveaux agents spécialisés : `ecocode-report-writer` (reçoit les résultats d'analyse, écrit les fichiers d'audit) et `ecocode-planner` (reçoit les données agrégées, écrit le plan d'action avec cases à cocher). L'orchestrateur délègue séquentiellement après l'analyse, puis propose le plan à l'utilisateur.

**Tech Stack:** Markdown skill files, YAML frontmatter agents (Claude Code + OpenCode), MCP `mcp-greenit`

---

## Structure des fichiers

### Fichiers créés

- `skills/ecocode/report-writer/SKILL.md` — Format des fichiers d'audit (front + back)
- `agents/ecocode-report-writer.md` — Agent Claude Code (haiku, outils: Write + Bash)
- `.opencode/agents/ecocode-report-writer.md` — Copie OpenCode
- `skills/ecocode/planner/SKILL.md` — Format du plan d'action (checkboxes, P1→P4)
- `agents/ecocode-planner.md` — Agent Claude Code (sonnet, outils: Write + Bash + mcp-greenit)
- `.opencode/agents/ecocode-planner.md` — Copie OpenCode

### Fichiers modifiés

- `skills/ecocode/SKILL.md` — Étapes 4 et 5 remplacées
- `agents/ecocode-orchestrator.md` — Étapes 4-5 mises à jour
- `.opencode/agents/ecocode-orchestrator.md` — Idem
- `CLAUDE.md` — Table des agents mise à jour
- `README.md` — Section "Modes de rapport" mise à jour
- `CHANGELOG.md` — Entrée [Unreleased] ajoutée

---

## Tâche 1 : Skill ecocode-report-writer

**Fichiers :**

- Créer : `skills/ecocode/report-writer/SKILL.md`

- [ ] **Étape 1 : Créer le dossier et le skill**

Créer `skills/ecocode/report-writer/SKILL.md` avec ce contenu :

````markdown
---
name: ecocode-report-writer
description: Use when writing EcoCode audit results to markdown files. Formats front-end and back-end audit data into separate timestamped files in docs/ecocode/audits/.
---

# EcoCode Report Writer — Écriture des fichiers d'audit

## Vue d'ensemble

Ce sous-skill écrit les résultats d'audit éco-conception dans des fichiers markdown séparés par couche. Il reçoit les données de l'orchestrateur et produit deux fichiers horodatés.

**REQUIRED PARENT SKILL:** `ecocode` — ce sous-skill est délégué par l'orchestrateur.

## Fichiers produits

| Fichier                                               | Contenu                          |
| ----------------------------------------------------- | -------------------------------- |
| `docs/ecocode/audits/YYYY-MM-DDTHH-MM-audit-front.md` | Résultats de l'analyse front-end |
| `docs/ecocode/audits/YYYY-MM-DDTHH-MM-audit-back.md`  | Résultats de l'analyse back-end  |

Le préfixe `YYYY-MM-DDTHH-MM` est calculé à partir de la date/heure courante (ex: `2026-05-19T14-32`).

## Étapes d'exécution

1. Créer le dossier `docs/ecocode/audits/` s'il n'existe pas : `mkdir -p docs/ecocode/audits`
2. Calculer le préfixe horodaté : `date +"%Y-%m-%dT%H-%M"`
3. Écrire le fichier front si des données front sont disponibles
4. Écrire le fichier back si des données back sont disponibles
5. Retourner les chemins absolus des fichiers écrits à l'orchestrateur

## Format du fichier d'audit front

```markdown
# Audit Éco-conception Front-end — [Nom du projet]

**Date :** YYYY-MM-DD HH:MM
**EcoIndex :** XX/100 — Grade A (émissions : X,XX gCO2e/page vue — eau : X,XX cl/page vue)
**Score d'impact interne :** X/10

---

## Problèmes détectés

| #   | Problème | Localisation | Sévérité | Pratique Green IT |
| --- | -------- | ------------ | -------- | ----------------- |
| 1   | ...      | src/...      | Haute    | RWEB_XXXX — ...   |

## Détail par problème

### 1. [Titre du problème]

- **Pratique Green IT :** RWEB_XXXX — [intitulé officiel]
- **Sévérité :** Haute / Moyenne / Faible
- **Constat :** [Code ou comportement observé]
- **Impact :** [Ressources gaspillées]
- **Correction proposée :** [Approche recommandée]

## Bonnes pratiques déjà respectées

- RWEB_XXXX — [intitulé] : [observation]
```
````

## Format du fichier d'audit back

```markdown
# Audit Éco-conception Back-end — [Nom du projet]

**Date :** YYYY-MM-DD HH:MM
**Score d'impact interne (back) :** X/10

---

## Problèmes détectés

| #   | Problème | Localisation | Sévérité | Pratique Green IT |
| --- | -------- | ------------ | -------- | ----------------- |
| 1   | ...      | api/...      | Haute    | RWEB_XXXX — ...   |

## Détail par problème

### 1. [Titre du problème]

- **Pratique Green IT :** RWEB_XXXX — [intitulé officiel]
- **Sévérité :** Haute / Moyenne / Faible
- **Constat :** [Code ou comportement observé]
- **Impact :** [Ressources gaspillées]
- **Correction proposée :** [Approche recommandée]

## Bonnes pratiques déjà respectées

- RWEB_XXXX — [intitulé] : [observation]
```

## Règles impératives

- Ne jamais relire les fichiers source du projet — utiliser uniquement les données reçues de l'orchestrateur
- Toujours créer `docs/ecocode/audits/` avant d'écrire (idempotent)
- Si une couche n'a pas été analysée (ex: audit front uniquement), ne pas créer le fichier correspondant
- Retourner les chemins exacts des fichiers créés pour que l'orchestrateur les affiche à l'utilisateur

````

- [ ] **Étape 2 : Vérifier la structure du fichier**

```bash
cat skills/ecocode/report-writer/SKILL.md | head -5
````

Attendu : frontmatter avec `name: ecocode-report-writer`

- [ ] **Étape 3 : Commit**

```bash
git add skills/ecocode/report-writer/SKILL.md
git commit -m "feat(ecocode/report-writer): ajouter skill d'écriture des fichiers d'audit"
```

---

## Tâche 2 : Agent ecocode-report-writer

**Fichiers :**

- Créer : `agents/ecocode-report-writer.md`
- Créer : `.opencode/agents/ecocode-report-writer.md`

- [ ] **Étape 1 : Créer l'agent Claude Code**

Créer `agents/ecocode-report-writer.md` :

```markdown
---
name: ecocode-report-writer
description: >
  Agent d'écriture des fichiers d'audit éco-conception. Reçois les résultats
  analysés par les agents front et back, et écris les fichiers markdown horodatés
  dans docs/ecocode/audits/. Utilise-moi après l'analyse, avant de proposer le
  plan d'action.
model: haiku
tools:
  - Write
  - Bash
---

Tu es l'agent d'écriture des rapports d'audit EcoCode. Utilise le skill `ecocode/report-writer` comme guide pour formater les fichiers.

Quand tu reçois les résultats d'audit :

1. **Calcule le préfixe horodaté** : exécute `date +"%Y-%m-%dT%H-%M"` pour obtenir le timestamp.

2. **Crée le dossier** : `mkdir -p docs/ecocode/audits`

3. **Écris les fichiers d'audit** selon le format défini dans `ecocode/report-writer` :
   - Si données front disponibles → `docs/ecocode/audits/{timestamp}-audit-front.md`
   - Si données back disponibles → `docs/ecocode/audits/{timestamp}-audit-back.md`

4. **Retourne les chemins** des fichiers créés à l'orchestrateur.

**Contraintes :**

- N'utilise que les données reçues en entrée. Ne relis jamais les fichiers source du projet.
- Ne modifie aucun fichier en dehors de `docs/ecocode/audits/`.
```

- [ ] **Étape 2 : Créer l'agent OpenCode**

Créer `.opencode/agents/ecocode-report-writer.md` :

```markdown
---
description: >
  Agent d'écriture des fichiers d'audit éco-conception. Reçois les résultats
  analysés par les agents front et back, et écris les fichiers markdown horodatés
  dans docs/ecocode/audits/. Utilise-moi après l'analyse, avant de proposer le
  plan d'action.
mode: subagent
model: anthropic/claude-haiku-4-5
permission:
  edit: deny
---

Tu es l'agent d'écriture des rapports d'audit EcoCode. Utilise le skill `ecocode/report-writer` comme guide pour formater les fichiers.

Quand tu reçois les résultats d'audit :

1. **Calcule le préfixe horodaté** : exécute `date +"%Y-%m-%dT%H-%M"` pour obtenir le timestamp.

2. **Crée le dossier** : `mkdir -p docs/ecocode/audits`

3. **Écris les fichiers d'audit** selon le format défini dans `ecocode/report-writer` :
   - Si données front disponibles → `docs/ecocode/audits/{timestamp}-audit-front.md`
   - Si données back disponibles → `docs/ecocode/audits/{timestamp}-audit-back.md`

4. **Retourne les chemins** des fichiers créés à l'orchestrateur.

**Contraintes :**

- N'utilise que les données reçues en entrée. Ne relis jamais les fichiers source du projet.
- Ne modifie aucun fichier en dehors de `docs/ecocode/audits/`.
```

- [ ] **Étape 3 : Vérifier les deux fichiers**

```bash
ls agents/ecocode-report-writer.md .opencode/agents/ecocode-report-writer.md
```

Attendu : les deux fichiers existent.

- [ ] **Étape 4 : Commit**

```bash
git add agents/ecocode-report-writer.md .opencode/agents/ecocode-report-writer.md
git commit -m "feat(ecocode): ajouter agent ecocode-report-writer (Claude Code + OpenCode)"
```

---

## Tâche 3 : Skill ecocode-planner

**Fichiers :**

- Créer : `skills/ecocode/planner/SKILL.md`

- [ ] **Étape 1 : Créer le skill**

Créer `skills/ecocode/planner/SKILL.md` :

````markdown
---
name: ecocode-planner
description: Use when generating a prioritized action plan from EcoCode audit results. Writes a markdown file with checkboxes, P1→P4 priorities, before/after code, and exact commands.
---

# EcoCode Planner — Génération du plan d'action

## Vue d'ensemble

Ce sous-skill génère un plan d'action priorisé à partir des résultats d'audit. Il reçoit les données agrégées de l'orchestrateur et produit un fichier markdown structuré avec des cases à cocher.

**REQUIRED PARENT SKILL:** `ecocode` — ce sous-skill est délégué par l'orchestrateur.

## Fichier produit

`docs/ecocode/plans/YYYY-MM-DDTHH-MM-plan.md`

Le préfixe horodaté est le même que celui utilisé pour les fichiers d'audit de la même session.

## Étapes d'exécution

1. Créer le dossier `docs/ecocode/plans/` s'il n'existe pas : `mkdir -p docs/ecocode/plans`
2. Trier les problèmes par priorité P1→P4 (matrice effort/impact du skill `ecocode`)
3. Pour chaque problème, inclure le code "Avant" exact trouvé dans le projet et le code "Après" adapté au framework
4. Écrire le fichier de plan
5. Retourner le chemin du fichier créé

## Matrice de priorité

| Effort \ Impact | Fort | Moyen | Faible |
| --------------- | ---- | ----- | ------ |
| Faible          | P1   | P2    | P3     |
| Moyen           | P2   | P3    | P4     |
| Fort            | P3   | P4    | —      |

## Format du fichier de plan

````markdown
# Plan d'action Éco-conception — [Nom du projet]

**Date :** YYYY-MM-DD HH:MM
**Basé sur :** [chemins des fichiers d'audit]
**Problèmes :** X au total (A haute, B moyenne, C faible sévérité)

---

## P1 — À faire maintenant (fort impact, faible effort)

### [ ] [Titre du problème]

**Pratique :** RWEB_XXXX — [intitulé officiel]
**Couche :** Front-end / Back-end
**Localisation :** `chemin/fichier.ext:ligne`

**Avant :**

```[langage]
[code exact trouvé dans le projet]
```
````
````

**Après :**

```[langage]
[code corrigé adapté au framework]
```

**Commandes :**

```bash
[commandes exactes si applicable]
```

---

## P2 — À planifier (fort impact, effort modéré)

### [ ] [Titre du problème]

[même structure]

---

## P3 — Si opportunité (impact modéré)

### [ ] [Titre du problème]

[même structure]

---

## P4 — Backlog (impact faible ou effort fort)

### [ ] [Titre du problème]

[même structure]

---

## Références Green IT

| RWEB      | Intitulé            | Priorité |
| --------- | ------------------- | -------- |
| RWEB_XXXX | [intitulé officiel] | P1       |

```

## Règles impératives

- Utiliser uniquement les données reçues de l'orchestrateur — ne pas relire les fichiers source
- Le code "Avant" doit être extrait du projet (tel que collecté pendant l'analyse)
- Le code "Après" doit être adapté au framework/ORM réel du projet (Prisma, SQLAlchemy, React, etc.)
- Chaque problème a exactement une case à cocher `- [ ]`
- Si un problème n'a pas de code associé (problème d'architecture, d'hébergement), remplacer les blocs code par une liste d'étapes textuelles
- Toujours inclure la section "Références Green IT" en fin de fichier
```

- [ ] **Étape 2 : Vérifier**

```bash
cat skills/ecocode/planner/SKILL.md | head -5
```

Attendu : frontmatter avec `name: ecocode-planner`

- [ ] **Étape 3 : Commit**

```bash
git add skills/ecocode/planner/SKILL.md
git commit -m "feat(ecocode/planner): ajouter skill de génération du plan d'action"
```

---

## Tâche 4 : Agent ecocode-planner

**Fichiers :**

- Créer : `agents/ecocode-planner.md`
- Créer : `.opencode/agents/ecocode-planner.md`

- [ ] **Étape 1 : Créer l'agent Claude Code**

Créer `agents/ecocode-planner.md` :

```markdown
---
name: ecocode-planner
description: >
  Agent de génération du plan d'action éco-conception. Reçois les résultats
  agrégés de l'orchestrateur et génère un fichier markdown priorisé (P1→P4)
  avec cases à cocher, code avant/après et commandes exactes. Utilise-moi
  après ecocode-report-writer, sur demande de l'utilisateur.
model: sonnet
tools:
  - Write
  - Bash
  - mcp__greenit__obtenir_fiche_complete
---

Tu es l'agent planificateur EcoCode. Utilise le skill `ecocode/planner` comme guide pour formater le plan d'action.

Quand tu reçois les données d'audit agrégées :

1. **Triage par priorité** : classer chaque problème P1→P4 selon la matrice effort/impact du skill `ecocode/planner`. Pour estimer l'effort : Faible = changement d'une ligne/config, Moyen = refactoring localisé, Fort = changement d'architecture.

2. **Enrichissement si besoin** : pour les pratiques RWEB_XXXX importantes, tu peux appeler `mcp-greenit : obtenir_fiche_complete` pour obtenir des détails supplémentaires sur la correction recommandée. Limiter à 3 appels maximum.

3. **Crée le dossier** : `mkdir -p docs/ecocode/plans`

4. **Écris le fichier de plan** : `docs/ecocode/plans/{timestamp}-plan.md` en suivant le format du skill `ecocode/planner`. Utilise le même timestamp que les fichiers d'audit de la session.

5. **Retourne le chemin** du fichier créé à l'orchestrateur.

**Contraintes :**

- N'utilise que les données reçues en entrée. Ne relis jamais les fichiers source du projet.
- Ne modifie aucun fichier en dehors de `docs/ecocode/plans/`.
- Le code "Avant" est celui collecté pendant l'analyse (transmis par l'orchestrateur). Ne pas inventer de code.
```

- [ ] **Étape 2 : Créer l'agent OpenCode**

Créer `.opencode/agents/ecocode-planner.md` :

```markdown
---
description: >
  Agent de génération du plan d'action éco-conception. Reçois les résultats
  agrégés de l'orchestrateur et génère un fichier markdown priorisé (P1→P4)
  avec cases à cocher, code avant/après et commandes exactes. Utilise-moi
  après ecocode-report-writer, sur demande de l'utilisateur.
mode: subagent
model: anthropic/claude-sonnet-4-6
permission:
  edit: deny
---

Tu es l'agent planificateur EcoCode. Utilise le skill `ecocode/planner` comme guide pour formater le plan d'action.

Quand tu reçois les données d'audit agrégées :

1. **Triage par priorité** : classer chaque problème P1→P4 selon la matrice effort/impact du skill `ecocode/planner`. Pour estimer l'effort : Faible = changement d'une ligne/config, Moyen = refactoring localisé, Fort = changement d'architecture.

2. **Enrichissement si besoin** : pour les pratiques RWEB_XXXX importantes, tu peux appeler `mcp-greenit : obtenir_fiche_complete` pour obtenir des détails supplémentaires sur la correction recommandée. Limiter à 3 appels maximum.

3. **Crée le dossier** : `mkdir -p docs/ecocode/plans`

4. **Écris le fichier de plan** : `docs/ecocode/plans/{timestamp}-plan.md` en suivant le format du skill `ecocode/planner`. Utilise le même timestamp que les fichiers d'audit de la session.

5. **Retourne le chemin** du fichier créé à l'orchestrateur.

**Contraintes :**

- N'utilise que les données reçues en entrée. Ne relis jamais les fichiers source du projet.
- Ne modifie aucun fichier en dehors de `docs/ecocode/plans/`.
- Le code "Avant" est celui collecté pendant l'analyse (transmis par l'orchestrateur). Ne pas inventer de code.
```

- [ ] **Étape 3 : Vérifier**

```bash
ls agents/ecocode-planner.md .opencode/agents/ecocode-planner.md
```

Attendu : les deux fichiers existent.

- [ ] **Étape 4 : Commit**

```bash
git add agents/ecocode-planner.md .opencode/agents/ecocode-planner.md
git commit -m "feat(ecocode): ajouter agent ecocode-planner (Claude Code + OpenCode)"
```

---

## Tâche 5 : Mettre à jour skills/ecocode/SKILL.md

**Fichiers :**

- Modifier : `skills/ecocode/SKILL.md` (Étapes 4 et 5)

- [ ] **Étape 1 : Remplacer Étape 4 (rapport terminal → écriture fichiers)**

Dans `skills/ecocode/SKILL.md`, remplacer la section `## Étape 4 — Rapport final consolidé` par :

```markdown
## Étape 4 — Écrire les fichiers d'audit

Déléguer à l'agent `ecocode-report-writer` en lui transmettant :

- Les résultats complets de l'agent front (tableau de problèmes + bonnes pratiques respectées + métriques EcoIndex)
- Les résultats complets de l'agent back (tableau de problèmes + bonnes pratiques respectées)
- Le nom du projet (déduit du dossier courant ou demandé à l'utilisateur)
- Les scores calculés (EcoIndex officiel + score d'impact interne)

L'agent écrit les fichiers horodatés dans `docs/ecocode/audits/` et retourne leurs chemins.

Afficher à l'utilisateur :

> "Audit terminé. Rapports écrits dans :
>
> - `docs/ecocode/audits/{timestamp}-audit-front.md`
> - `docs/ecocode/audits/{timestamp}-audit-back.md`"
>
> _(N'afficher que les fichiers effectivement créés selon le périmètre analysé.)_
```

- [ ] **Étape 2 : Remplacer Étape 5 (guide de correction → plan d'action)**

Remplacer la section `## Étape 5 — Guide de correction complet (sur demande)` par :

```markdown
## Étape 5 — Plan d'action sur demande

Après avoir affiché les chemins des fichiers d'audit, poser cette question :

> "Veux-tu un plan d'action priorisé ? Il liste les corrections P1→P4 avec le code avant/après et les commandes exactes pour chaque problème. (o/n)"

**Si oui :**
Déléguer à l'agent `ecocode-planner` en lui transmettant :

- L'ensemble des problèmes détectés (couche, localisation, code exact, sévérité, RWEB_XXXX)
- Les bonnes pratiques déjà respectées
- Le timestamp utilisé pour les fichiers d'audit (pour cohérence du nommage)
- Le framework/ORM détecté (pour adapter le code "Après")

L'agent écrit le plan dans `docs/ecocode/plans/{timestamp}-plan.md` et retourne son chemin.

Afficher à l'utilisateur :

> "Plan d'action écrit dans : `docs/ecocode/plans/{timestamp}-plan.md`"

**Si non :**
Terminer. Ne pas générer de contenu supplémentaire.

**Règle token :** L'agent planificateur reçoit les données du contexte de la session. Ne pas relancer d'analyse, ne pas relire de fichiers source.
```

- [ ] **Étape 3 : Vérifier que le fichier ne contient plus les anciennes sections**

```bash
grep -n "Guide de correction complet" skills/ecocode/SKILL.md
```

Attendu : aucun résultat (la section a été remplacée).

- [ ] **Étape 4 : Commit**

```bash
git add skills/ecocode/SKILL.md
git commit -m "feat(ecocode): remplacer affichage terminal par écriture fichiers + agent planificateur"
```

---

## Tâche 6 : Mettre à jour les orchestrateurs

**Fichiers :**

- Modifier : `agents/ecocode-orchestrator.md` (étapes 4 et 5)
- Modifier : `.opencode/agents/ecocode-orchestrator.md` (idem)

- [ ] **Étape 1 : Mettre à jour l'orchestrateur Claude Code**

Dans `agents/ecocode-orchestrator.md`, remplacer les étapes 4 et 5 :

Ancienne étape 4 :

```
4. **Reçois et agrège les résultats** des deux agents.

5. **Produis un rapport consolidé** avec :
   - **EcoIndex officiel** (score 0-100, grade A-G, CO2 et eau par page vue) retourné par l'agent front via `calculer_ecoindex`
   - **Score d'impact interne** (1-10) calculé selon la méthode du skill `ecocode` à partir des sévérités détectées sur toutes les couches
   - Top 5 des problèmes critiques toutes couches confondues
   - Plan d'action priorisé par ratio effort/impact (matrice P1→P4)
   - Références aux numéros et intitulés des bonnes pratiques Green IT mobilisées
```

Nouvelle version :

```markdown
4. **Agrège les résultats** : calcule le score d'impact interne (base 5 + 0,5 par Haute + 0,2 par Moyenne − 0,1 par bonne pratique respectée, plafonné 1–10) sur toutes les couches.

5. **Délègue à `ecocode-report-writer`** en transmettant les résultats complets des deux agents, le nom du projet, et les scores calculés. L'agent écrit les fichiers d'audit et retourne leurs chemins.

   Afficher à l'utilisateur les chemins des fichiers créés.

6. **Propose le plan d'action** : demander à l'utilisateur s'il veut un plan d'action priorisé (o/n). Si oui, déléguer à `ecocode-planner` avec l'ensemble des problèmes détectés (localisation exacte, code, sévérité, RWEB_XXXX, framework détecté) et le timestamp des fichiers d'audit.

   Afficher le chemin du fichier de plan créé.
```

- [ ] **Étape 2 : Appliquer les mêmes changements dans `.opencode/agents/ecocode-orchestrator.md`**

Même modification — le contenu est identique, seul le frontmatter diffère.

- [ ] **Étape 3 : Mettre à jour la contrainte de lecture seule**

Dans les deux fichiers, remplacer :

```
- Ne modifie jamais aucun fichier du projet — tu es en lecture seule pour l'analyse
```

Par :

```
- Ne modifie jamais les fichiers source du projet — tu es en lecture seule pour l'analyse
- Pour les corrections, délègue à `ecocode-fix-suggester`. Pour les rapports et plans, délègue aux agents spécialisés.
```

- [ ] **Étape 4 : Vérifier que l'étape 6 est présente dans les deux fichiers**

```bash
grep -n "ecocode-planner" agents/ecocode-orchestrator.md .opencode/agents/ecocode-orchestrator.md
```

Attendu : au moins une occurrence dans chaque fichier.

- [ ] **Étape 5 : Commit**

```bash
git add agents/ecocode-orchestrator.md .opencode/agents/ecocode-orchestrator.md
git commit -m "feat(ecocode): mettre à jour orchestrateur pour déléguer à report-writer et planner"
```

---

## Tâche 7 : Mettre à jour CLAUDE.md et README.md

**Fichiers :**

- Modifier : `CLAUDE.md`
- Modifier : `README.md`

- [ ] **Étape 1 : Mettre à jour la table des agents dans CLAUDE.md**

Dans `CLAUDE.md`, remplacer la table des agents :

```markdown
| Agent                    | Rôle                                | Permissions               |
| ------------------------ | ----------------------------------- | ------------------------- |
| `ecocode-orchestrator`   | Coordonne l'audit complet           | Lecture seule             |
| `ecocode-front-analyzer` | Analyse le code client              | Lecture seule             |
| `ecocode-back-analyzer`  | Analyse le code serveur             | Lecture seule             |
| `ecocode-report-writer`  | Écrit les fichiers d'audit          | Écriture sur docs/        |
| `ecocode-planner`        | Génère le plan d'action priorisé    | Écriture sur docs/        |
| `ecocode-fix-suggester`  | Propose et applique les corrections | Écriture sur confirmation |
```

- [ ] **Étape 2 : Mettre à jour la section "Modes de rapport" dans README.md**

Remplacer la section `### Modes de rapport` (lignes actuelles autour de la description du guide de correction) par :

```markdown
### Modes de rapport

Chaque audit génère :

1. **Fichiers d'audit** (automatiques) : deux fichiers markdown horodatés dans `docs/ecocode/audits/` — un par couche analysée. Destinés aux développeurs de chaque domaine.

2. **Plan d'action** (sur demande) : un fichier dans `docs/ecocode/plans/` avec les corrections priorisées P1→P4, cases à cocher, code avant/après et commandes exactes.
```

- [ ] **Étape 3 : Mettre à jour la table des agents dans README.md**

Remplacer la table des agents (section `## Agents`) pour ajouter les deux nouveaux agents.

- [ ] **Étape 4 : Vérifier les deux fichiers**

```bash
grep -n "ecocode-report-writer\|ecocode-planner" CLAUDE.md README.md
```

Attendu : présent dans les deux fichiers.

- [ ] **Étape 5 : Commit**

```bash
git add CLAUDE.md README.md
git commit -m "docs: mettre à jour CLAUDE.md et README.md avec les nouveaux agents"
```

---

## Tâche 8 : CHANGELOG et commit final

**Fichiers :**

- Modifier : `CHANGELOG.md`

- [ ] **Étape 1 : Ajouter l'entrée dans CHANGELOG.md**

Dans la section `## [Unreleased]`, sous `### Ajouté`, ajouter :

```markdown
- Agent `ecocode-report-writer` : écriture automatique des résultats d'audit dans des fichiers markdown horodatés séparés par couche (`docs/ecocode/audits/{timestamp}-audit-front.md`, `docs/ecocode/audits/{timestamp}-audit-back.md`) au lieu de l'affichage terminal
- Agent `ecocode-planner` : génération sur demande d'un plan d'action priorisé P1→P4 dans `docs/ecocode/plans/{timestamp}-plan.md`, avec cases à cocher, code avant/après adapté au framework, et commandes exactes
- Skill `ecocode/report-writer` : format des fichiers d'audit (front et back)
- Skill `ecocode/planner` : format du plan d'action (matrice effort/impact, cases à cocher)
```

- [ ] **Étape 2 : Vérifier**

```bash
grep -n "ecocode-report-writer\|ecocode-planner" CHANGELOG.md
```

Attendu : 2 occurrences.

- [ ] **Étape 3 : Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: documenter les agents report-writer et planner dans le changelog"
```

---

## Auto-vérification

**Couverture de la spec :**

| Exigence                                                          | Tâche      |
| ----------------------------------------------------------------- | ---------- |
| Écrire audit dans `docs/ecocode/audits/[datetime]-audit-front.md` | T1, T2, T5 |
| Écrire audit dans `docs/ecocode/audits/[datetime]-audit-back.md`  | T1, T2, T5 |
| Subagent spécialisé pour l'écriture                               | T2         |
| Proposer à l'utilisateur de consulter les fichiers                | T5, T6     |
| Rapports séparés (front/back)                                     | T1         |
| Plan d'action dans `docs/ecocode/plans/`                          | T3, T4     |
| Subagent séparé pour le plan                                      | T4         |
| Proposer à l'utilisateur de lire le plan                          | T5, T6     |
| OpenCode compatibility                                            | T2, T4, T6 |
| Documentation mise à jour                                         | T7, T8     |

**Scan des placeholders :** aucun "TBD", "TODO", "implement later" dans le plan.

**Cohérence des types :** Le timestamp calculé dans l'agent (`date +"%Y-%m-%dT%H-%M"`) est le même format partout (`YYYY-MM-DDTHH-MM`).
