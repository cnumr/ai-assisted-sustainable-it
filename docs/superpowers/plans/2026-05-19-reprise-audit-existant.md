# Reprise d'audit existant — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Permettre de reprendre depuis un audit ecocode existant — générer un plan, corriger un problème ou afficher un résumé — sans relancer l'analyse complète.

**Architecture:** Un nouveau sous-skill `ecocode/resume` gère la lecture des fichiers d'audit existants et le routage vers les actions (plan, fix, summary). Le skill parent `ecocode` et l'orchestrateur reçoivent une étape de détection automatique placée avant le flux normal : si des audits existent dans `docs/ecocode/audits/`, l'utilisateur choisit de reprendre ou de relancer. Les sous-commandes `/ecocode plan`, `/ecocode fix`, `/ecocode fix RWEB_XXX` court-circuitent directement vers `ecocode/resume`.

**Tech Stack:** Markdown (fichiers de skill LLM), YAML frontmatter (agents), Bash (détection de fichiers)

---

## Structure des fichiers

| Fichier                                    | Action   | Responsabilité                                                      |
| ------------------------------------------ | -------- | ------------------------------------------------------------------- |
| `skills/ecocode/resume/SKILL.md`           | Créer    | Lire les fichiers d'audit existants et router vers plan/fix/summary |
| `skills/ecocode/SKILL.md`                  | Modifier | Ajouter Étape −1 (détection) avant Étape 0                          |
| `agents/ecocode-orchestrator.md`           | Modifier | Ajouter étape 0 (détection) avant les étapes actuelles              |
| `.opencode/agents/ecocode-orchestrator.md` | Modifier | Même corps que Claude Code                                          |
| `README.md`                                | Modifier | Documenter les sous-commandes et la reprise                         |
| `CHANGELOG.md`                             | Modifier | Ajouter l'entrée pour cette feature                                 |

---

## Task 1 : Créer `skills/ecocode/resume/SKILL.md`

**Files:**

- Create: `skills/ecocode/resume/SKILL.md`

- [ ] **Step 1 : Créer le fichier**

Créer `skills/ecocode/resume/SKILL.md` avec ce contenu exact :

```markdown
---
name: ecocode/resume
description: Use when resuming from an existing EcoCode audit. Reads existing audit files in docs/ecocode/audits/, extracts problems and scores, then routes to plan generation or fix suggestion without re-running the analysis.
---

# EcoCode Resume — Reprise depuis un audit existant

## Vue d'ensemble

Ce sous-skill lit un ou plusieurs fichiers d'audit existants dans `docs/ecocode/audits/` et permet de continuer le travail sans relancer l'analyse complète. Il est utilisé quand l'utilisateur tape `/ecocode plan`, `/ecocode fix`, ou choisit "reprendre" lors de la détection automatique d'un audit existant.

**REQUIRED PARENT SKILL:** `ecocode` — ce sous-skill est invoqué par l'orchestrateur.

## Données en entrée

- `auditPaths` : liste des fichiers d'audit à lire (ex: `["docs/ecocode/audits/2026-05-19T14-32-audit-front.md"]`)
- `action` : l'action demandée — `plan`, `fix`, `fix RWEB_XXX`, ou `summary` (par défaut)
- `timestamp` : extrait du nom de fichier (ex: `2026-05-19T14-32`)

## Étape 1 — Lire les fichiers d'audit

Lire chaque fichier fourni dans `auditPaths` et en extraire :

**Table des problèmes** (section `## Problèmes détectés`) :

- Pour chaque ligne du tableau : numéro, titre du problème, localisation, sévérité, code RWEB + intitulé

**Détail des problèmes** (section `## Détail par problème`) :

- Pour chaque `### N. [Titre]` : Pratique Green IT, Sévérité, Constat (code exact), Impact, Correction proposée

**Bonnes pratiques respectées** (section `## Bonnes pratiques déjà respectées`) :

- Chaque ligne `- RWEB_XXXX — [intitulé] : [observation]`

**Scores** (header du fichier) :

- EcoIndex (front uniquement) : score, grade
- Score d'impact interne

La couche (front/back) est déduite du nom du fichier : `audit-front` → front-end, `audit-back` → back-end.

Ne pas relire les fichiers source du projet — uniquement les fichiers d'audit.

## Étape 2 — Router selon l'action

### Action `plan`

Déléguer à `ecocode-planner` avec :

- `problems` : liste complète des problèmes extraits (couche, localisation, code exact trouvé, sévérité, RWEB_XXXX, effort estimé)
- `goodPractices` : liste des bonnes pratiques respectées
- `timestamp` : identique aux fichiers d'audit (pour cohérence du nommage)
- `auditPaths` : chemins des fichiers d'audit lus
- `framework` : si mentionné dans les constats de l'audit, sinon `null`

Afficher :

> "Plan d'action écrit dans : `docs/ecocode/plans/{timestamp}-plan.md`"

### Action `fix RWEB_XXX`

1. Trouver dans les données extraites le problème dont le code RWEB correspond.
2. Si introuvable : afficher la liste des codes RWEB présents dans l'audit et demander lequel corriger.
3. Si trouvé : déléguer à `ecocode-fix-suggester` avec le problème complet (localisation, code exact trouvé, correction proposée, RWEB_XXX + intitulé).

### Action `fix` (sans code RWEB)

1. Afficher la liste des problèmes avec numéro, titre, localisation, sévérité et pratique Green IT.
2. Demander :
   > "Quel problème veux-tu corriger ? (numéro ou RWEB_XXX)"
3. Router vers `fix RWEB_XXX` avec le choix reçu.

### Action `summary` (par défaut)

Afficher :

> "Audit du {date} — {nom du projet}
>
> Front-end : EcoIndex {score}/100 — Grade {grade} — Score d'impact {X}/10
> Back-end : Score d'impact {X}/10
>
> Problèmes : {N} au total ({A} haute, {B} moyenne, {C} faible sévérité)
>
> Que veux-tu faire ?
>
> - **plan** — générer le plan d'action priorisé
> - **fix** — choisir un problème à corriger
> - **fix RWEB_XXX** — corriger un problème précis
>
> (plan / fix / fix RWEB_XXX)"

Attendre la réponse et router vers l'action correspondante.

## Règles impératives

- Ne jamais relancer l'analyse des fichiers source — uniquement lire les fichiers d'audit
- Extraire les données du markdown des fichiers d'audit sans inventer de problèmes non présents
- Si un fichier d'audit est introuvable ou illisible : le signaler et proposer de relancer un audit complet avec `/ecocode`
- Le timestamp du plan généré est identique à celui de l'audit d'origine
- Si les deux fichiers (front et back) existent pour le même timestamp, les lire tous les deux avant de router
```

- [ ] **Step 2 : Vérifier le fichier créé**

```bash
ls -la skills/ecocode/resume/SKILL.md
```

Expected : fichier de ~3 KB, pas d'erreur.

- [ ] **Step 3 : Vérifier la structure du frontmatter**

```bash
head -5 skills/ecocode/resume/SKILL.md
```

Expected :

```
---
name: ecocode/resume
description: Use when resuming from an existing EcoCode audit. ...
---
```

- [ ] **Step 4 : Commit**

```bash
git add skills/ecocode/resume/SKILL.md
git commit -m "feat(ecocode): ajouter sous-skill ecocode/resume pour reprise depuis audit existant"
```

---

## Task 2 : Modifier `skills/ecocode/SKILL.md` — ajouter la détection

**Files:**

- Modify: `skills/ecocode/SKILL.md`

Le fichier actuel a cette structure :

- Frontmatter YAML (lignes 1-4)
- `# EcoCode — Skill parent d'orchestration` (ligne 6)
- `## Vue d'ensemble` (ligne 8)
- Graphe `digraph routing` (lignes 16-40)
- `## Étape 0 — Choisir le mode d'exécution` (ligne 42)
- `## Étape 1 — Identifier le périmètre` (ligne 55)
- ...

L'objectif est d'insérer une nouvelle section `## Étape −1` entre le graphe de routage et l'Étape 0 actuelle. L'Étape 0 et toutes les suivantes ne changent pas.

- [ ] **Step 1 : Insérer l'Étape −1 avant l'Étape 0**

Trouver le bloc qui commence par `## Étape 0 — Choisir le mode d'exécution` et insérer avant lui :

````markdown
## Étape −1 — Détecter le mode d'entrée

**Si l'argument est `plan`, `fix`, ou `fix RWEB_XXX` :**

1. Trouver le dernier fichier d'audit :
   ```bash
   ls docs/ecocode/audits/*.md 2>/dev/null | sort -r | head -1
   ```
````

2. Si aucun fichier trouvé : signaler qu'aucun audit n'existe et continuer vers l'Étape 0 pour un nouvel audit.
3. Si un fichier trouvé : extraire le timestamp du nom de fichier (format `YYYY-MM-DDTHH-MM`), trouver tous les fichiers correspondant à ce timestamp, et déléguer à `ecocode/resume` avec :
   - `auditPaths` : tous les fichiers de ce timestamp (ex: `["...audit-front.md", "...audit-back.md"]`)
   - `action` : l'argument reçu (`plan`, `fix`, ou `fix RWEB_XXX`)
   - `timestamp` : le timestamp extrait

   Terminer. Ne pas continuer vers l'Étape 0.

**Si l'argument est vide (appel standard `/ecocode`) :**

1. Vérifier si `docs/ecocode/audits/` contient des fichiers :
   ```bash
   ls docs/ecocode/audits/*.md 2>/dev/null | wc -l
   ```
2. Si des fichiers existent : trouver le plus récent, extraire sa date, et demander :
   > "Audit existant trouvé (du {date formatée lisiblement}). Reprendre depuis cet audit ou lancer un nouvel audit ?
   >
   > - **reprendre** — plan d'action, correction ou résumé sans re-analyser
   > - **nouvel** — relancer l'analyse complète
   >
   > (reprendre/nouvel)"
   - Si **reprendre** : déléguer à `ecocode/resume` avec `action: summary` et les fichiers du timestamp le plus récent. Terminer.
   - Si **nouvel** : continuer vers l'Étape 0.
3. Si aucun fichier : continuer vers l'Étape 0.

````

- [ ] **Step 2 : Vérifier l'ordre des sections**

```bash
grep "^## Étape" skills/ecocode/SKILL.md
````

Expected :

```
## Étape −1 — Détecter le mode d'entrée
## Étape 0 — Choisir le mode d'exécution
## Étape 1 — Identifier le périmètre
## Étape 2 — Charger les bonnes pratiques Green IT
## Étape 3 — Déléguer aux sous-skills
## Étape 4 — Écrire les fichiers d'audit
## Étape 5 — Plan d'action
```

- [ ] **Step 3 : Commit**

```bash
git add skills/ecocode/SKILL.md
git commit -m "feat(ecocode): ajouter détection d'audit existant dans le skill orchestrateur"
```

---

## Task 3 : Modifier `agents/ecocode-orchestrator.md` (Claude Code)

**Files:**

- Modify: `agents/ecocode-orchestrator.md`

Le fichier actuel a une liste numérotée 1-7. L'objectif est d'ajouter une étape 0 avant l'étape 1 actuelle, et de renuméroter l'étape 1 actuelle en "étape 1" (elle reste étape 1, on insère une "étape 0").

- [ ] **Step 1 : Insérer l'étape 0 avant l'étape 1 actuelle**

La liste commence actuellement par :

```
Quand tu reçois une demande d'audit :

1. **Choisis le mode d'exécution** en posant la question :
```

Remplacer par :

```
Quand tu reçois une demande d'audit :

0. **Détecte le mode d'entrée** avant toute autre action :

   **Si la demande contient `plan`, `fix`, ou `fix RWEB_XXX` :**
   - Exécuter : `ls docs/ecocode/audits/*.md 2>/dev/null | sort -r | head -1`
   - Si aucun fichier trouvé : informer qu'aucun audit n'existe et passer à l'étape 1.
   - Si un fichier trouvé : extraire le timestamp (format `YYYY-MM-DDTHH-MM`), trouver tous les fichiers de ce timestamp, déléguer à `ecocode/resume` avec `auditPaths`, `action`, et `timestamp`. Terminer — ne pas continuer aux étapes suivantes.

   **Si la demande est un audit standard (pas d'argument `plan`/`fix`) :**
   - Exécuter : `ls docs/ecocode/audits/*.md 2>/dev/null | wc -l`
   - Si des fichiers existent : trouver le plus récent, extraire sa date, et demander :
     > "Audit existant trouvé (du {date}). Reprendre depuis cet audit ou lancer un nouvel audit ? (reprendre/nouvel)"
     - Si **reprendre** : déléguer à `ecocode/resume` avec `action: summary` et les fichiers du timestamp le plus récent. Terminer.
     - Si **nouvel** : continuer à l'étape 1.
   - Si aucun fichier : continuer à l'étape 1.

1. **Choisis le mode d'exécution** en posant la question :
```

- [ ] **Step 2 : Vérifier la numérotation des étapes**

```bash
grep "^\([0-9]\+\)\.\|^[0-9]\+\. \*\*" agents/ecocode-orchestrator.md | head -10
```

Expected : étapes 0 à 7 présentes.

- [ ] **Step 3 : Commit**

```bash
git add agents/ecocode-orchestrator.md
git commit -m "feat(ecocode): ajouter détection d'audit existant dans l'orchestrateur Claude Code"
```

---

## Task 4 : Modifier `.opencode/agents/ecocode-orchestrator.md` (OpenCode)

**Files:**

- Modify: `.opencode/agents/ecocode-orchestrator.md`

Le corps de ce fichier doit être identique à celui de `agents/ecocode-orchestrator.md` (Task 3). Seul le frontmatter diffère — le conserver tel quel :

```yaml
---
description: >
  Orchestrateur principal pour les audits d'éco-conception. ...
mode: subagent
model: anthropic/claude-sonnet-4-5
permission:
  edit: deny
---
```

- [ ] **Step 1 : Insérer la même étape 0 que dans Task 3**

Appliquer exactement la même modification de corps que Task 3 Step 1 sur `.opencode/agents/ecocode-orchestrator.md`.

Le frontmatter OpenCode (lignes 1-10) ne change pas.

- [ ] **Step 2 : Vérifier que le frontmatter OpenCode est intact**

```bash
head -10 .opencode/agents/ecocode-orchestrator.md
```

Expected :

```
---
description: >
  Orchestrateur principal pour les audits d'éco-conception. ...
mode: subagent
model: anthropic/claude-sonnet-4-5
permission:
  edit: deny
---
```

- [ ] **Step 3 : Vérifier la présence de l'étape 0 dans le corps**

```bash
grep "Détecte le mode d'entrée" .opencode/agents/ecocode-orchestrator.md
```

Expected : une ligne correspondante.

- [ ] **Step 4 : Commit**

```bash
git add .opencode/agents/ecocode-orchestrator.md
git commit -m "feat(ecocode): aligner l'orchestrateur OpenCode avec la détection d'audit existant"
```

---

## Task 5 : Mettre à jour `README.md` et `CHANGELOG.md`

**Files:**

- Modify: `README.md`
- Modify: `CHANGELOG.md`

### README.md

La section `## Utilisation` contient actuellement :

```markdown

```

/ecocode # Audit complet du projet courant
/ecocode front # Analyse front-end uniquement
/ecocode back # Analyse back-end uniquement
/ecocode https://example.com # Analyse d'une URL (requiert playwright)

```

```

- [ ] **Step 1 : Ajouter les sous-commandes de reprise dans le bloc de code**

Remplacer ce bloc par :

```markdown

```

/ecocode # Audit complet du projet courant
/ecocode front # Analyse front-end uniquement
/ecocode back # Analyse back-end uniquement
/ecocode https://example.com # Analyse d'une URL (requiert playwright)
/ecocode plan # Plan d'action depuis le dernier audit (sans re-analyser)
/ecocode fix # Correction guidée depuis le dernier audit
/ecocode fix RWEB_042 # Correction ciblée sur une pratique spécifique

```

```

- [ ] **Step 2 : Ajouter une section "Reprise d'audit" après la section "Modes d'exécution"**

La section "Modes d'exécution" se termine par :

```
Les deux modes génèrent les mêmes fichiers dans `docs/ecocode/audits/` et `docs/ecocode/plans/`.
```

Ajouter après cette ligne :

```markdown
### Reprise d'audit

Si des fichiers d'audit existent dans `docs/ecocode/audits/`, `/ecocode` propose automatiquement de reprendre depuis le dernier audit plutôt que de relancer l'analyse complète.

Les sous-commandes `plan`, `fix` et `fix RWEB_XXX` reprennent directement depuis le dernier audit sans question :

| Sous-commande           | Comportement                                                |
| ----------------------- | ----------------------------------------------------------- |
| `/ecocode plan`         | Génère le plan d'action P1→P4 depuis le dernier audit       |
| `/ecocode fix`          | Liste les problèmes du dernier audit et guide la correction |
| `/ecocode fix RWEB_042` | Corrige directement le problème RWEB_042 du dernier audit   |
```

### CHANGELOG.md

- [ ] **Step 3 : Ajouter l'entrée dans CHANGELOG.md**

La section `## [Unreleased] → ### Ajouté` commence actuellement par :

```
- Deux modes d'exécution : `auto` ...
```

Ajouter une nouvelle ligne avant celle-ci :

```markdown
- Reprise d'audit existant : `/ecocode plan`, `/ecocode fix`, `/ecocode fix RWEB_XXX` reprennent depuis le dernier audit sans re-analyser ; détection automatique à chaque appel `/ecocode` quand des audits existent dans `docs/ecocode/audits/`
- Sous-skill `ecocode/resume` : lecture des fichiers d'audit markdown, extraction des problèmes et des scores, routage vers `ecocode-planner` ou `ecocode-fix-suggester`
```

- [ ] **Step 4 : Commit**

```bash
git add README.md CHANGELOG.md
git commit -m "docs: documenter la reprise d'audit existant dans le README et le changelog"
```
