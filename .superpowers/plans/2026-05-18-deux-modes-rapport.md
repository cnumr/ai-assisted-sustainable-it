# Deux modes de rapport EcoCode — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ajouter deux modes de rapport aux skills EcoCode : un rapport light (actuel) suivi d'une question interactive proposant un guide de correction complet avec code avant/après, liste précise des éléments trouvés et commandes exactes.

**Architecture:** Une seule passe d'analyse collecte les données précises en contexte. Le rapport light est généré en premier. Une question interactive propose le guide détaillé, produit depuis le contexte déjà chargé sans relire les fichiers (économie de tokens).

**Tech Stack:** Markdown (skills), aucune dépendance nouvelle.

---

## Fichiers modifiés

| Fichier                         | Rôle du changement                                         |
| ------------------------------- | ---------------------------------------------------------- |
| `skills/ecocode/front/SKILL.md` | + instruction "collecte précise" + format guide détaillé   |
| `skills/ecocode/back/SKILL.md`  | + instruction "collecte précise" + format guide détaillé   |
| `skills/ecocode/SKILL.md`       | + question interactive + instruction guide depuis contexte |

---

## Task 1 : Collecte précise dans le skill front

**Fichiers :**

- Modify: `skills/ecocode/front/SKILL.md` (après la section `## Vue d'ensemble`, avant `## Sources d'analyse`)

- [ ] **Step 1 : Insérer la section "Collecte précise"**

Après la ligne `**REQUIRED PARENT SKILL:** \`ecocode\` — ce sous-skill est délégué par le skill parent.` (ligne 12), insérer :

```markdown
## Collecte précise (obligatoire pendant l'analyse)

Pendant toute l'analyse, pour chaque problème détecté, noter immédiatement dans le contexte :

- **Chemins exacts** : `src/components/Hero/hero.png`, `public/assets/logo.png`
- **Valeurs mesurées** : taille en KB, nombre de nœuds DOM, URLs de scripts tiers
- **Extrait de code** : la ligne ou le bloc précis qui pose problème
- **Contexte d'usage** : dimensions d'affichage, fréquence d'appel, etc.

Ces données ne sont pas affichées dans le rapport light mais servent à générer le guide de correction complet si l'utilisateur le demande — sans relire les fichiers.
```

- [ ] **Step 2 : Vérifier l'insertion**

Lire `skills/ecocode/front/SKILL.md` lignes 1-30 et confirmer que la section "Collecte précise" est présente après le bloc REQUIRED PARENT SKILL.

- [ ] **Step 3 : Commit**

```bash
git add skills/ecocode/front/SKILL.md
git commit -m "feat(ecocode/front): ajouter instruction de collecte précise pendant l'analyse"
```

---

## Task 2 : Format du guide détaillé dans le skill front

**Fichiers :**

- Modify: `skills/ecocode/front/SKILL.md` (à la fin du fichier, après `## Erreurs fréquentes`)

- [ ] **Step 1 : Ajouter la section "Format du guide de correction complet"**

À la fin de `skills/ecocode/front/SKILL.md`, ajouter :

````markdown
## Format du guide de correction complet

> Généré uniquement si l'utilisateur le demande, depuis les données collectées. Ne pas relire les fichiers.

Pour chaque problème du rapport light, produire une section dans cet ordre :

````markdown
### Problème N — [Titre du problème]

**Pratique :** RWEB_XXXX — [intitulé officiel de la fiche Green IT]
**Sévérité :** Haute / Moyenne / Faible

**Éléments trouvés dans ton code :**

- `chemin/exact/fichier.ext` ([taille] KB) — [contexte : affiché en Xpx, chargé sur chaque page, etc.]
- `chemin/exact/autre-fichier.ext` ([taille] KB) — [contexte]

**Impact estimé :** [chiffre concret, ex: -74% bande passante, -2 requêtes bloquantes]

**Avant :**

```[langage]
[extrait exact du code trouvé dans le projet, avec le chemin en commentaire]
```
````

**Après :**

```[langage]
[code corrigé, adapté au projet analysé — pas un exemple générique]
```

**Étapes :**

1. [Action précise sur les fichiers listés ci-dessus]
   ```bash
   [commande exacte si applicable, avec les vrais noms de fichiers]
   ```
2. [Étape suivante]
3. [Vérification : comment confirmer que le problème est résolu]

**Outils recommandés :**

- `[nom-outil]` — [description en une ligne] : `[commande d'installation]`

```

**Règles impératives :**
- Les fichiers listés sont ceux réellement trouvés pendant l'analyse, jamais des exemples génériques
- Le code "Avant" est extrait du projet, le code "Après" est adapté à sa stack (React, Vue, Vite, etc.)
- Les commandes incluent les vrais noms de fichiers collectés pendant l'analyse
- Si plusieurs fichiers ont le même problème, les lister tous explicitement
```
````

- [ ] **Step 2 : Vérifier l'insertion**

Lire la fin de `skills/ecocode/front/SKILL.md` et confirmer que la section "Format du guide de correction complet" est présente avec le bon format imbriqué.

- [ ] **Step 3 : Commit**

```bash
git add skills/ecocode/front/SKILL.md
git commit -m "feat(ecocode/front): ajouter format du guide de correction complet"
```

---

## Task 3 : Collecte précise dans le skill back

**Fichiers :**

- Modify: `skills/ecocode/back/SKILL.md` (après `**REQUIRED PARENT SKILL:**`, avant `## Axes d'analyse`)

- [ ] **Step 1 : Insérer la section "Collecte précise"**

Après la ligne `**REQUIRED PARENT SKILL:** \`ecocode\` — ce sous-skill est délégué par le skill parent.` (ligne 12), insérer :

```markdown
## Collecte précise (obligatoire pendant l'analyse)

Pendant toute l'analyse, pour chaque problème détecté, noter immédiatement dans le contexte :

- **Localisation exacte** : `orders/controller.py:45`, `api/products.js:23-31`
- **Pattern problématique** : le code ou la requête exacte qui pose problème
- **Valeurs mesurées** : nombre de requêtes dans une boucle, taille du payload, absence de TTL
- **Contexte** : taille estimée de la table, fréquence d'appel, données chaudes ou froides

Ces données ne sont pas affichées dans le rapport light mais servent à générer le guide de correction complet si l'utilisateur le demande — sans relire les fichiers.
```

- [ ] **Step 2 : Vérifier l'insertion**

Lire `skills/ecocode/back/SKILL.md` lignes 1-30 et confirmer que la section "Collecte précise" est présente.

- [ ] **Step 3 : Commit**

```bash
git add skills/ecocode/back/SKILL.md
git commit -m "feat(ecocode/back): ajouter instruction de collecte précise pendant l'analyse"
```

---

## Task 4 : Format du guide détaillé dans le skill back

**Fichiers :**

- Modify: `skills/ecocode/back/SKILL.md` (à la fin du fichier, après `## Erreurs fréquentes`)

- [ ] **Step 1 : Ajouter la section "Format du guide de correction complet"**

À la fin de `skills/ecocode/back/SKILL.md`, ajouter :

````markdown
## Format du guide de correction complet

> Généré uniquement si l'utilisateur le demande, depuis les données collectées. Ne pas relire les fichiers.

Pour chaque problème du rapport light, produire une section dans cet ordre :

````markdown
### Problème N — [Titre du problème]

**Pratique :** RWEB_XXXX — [intitulé officiel de la fiche Green IT]
**Sévérité :** Haute / Moyenne / Faible

**Éléments trouvés dans ton code :**

- `chemin/exact/fichier.py:45` — [description du pattern trouvé]
- `chemin/exact/autre.js:23` — [idem]

**Impact estimé :** [ex: N requêtes BDD par page vue au lieu de 1, +X ms latence]

**Avant :**

```[langage]
[code exact trouvé dans le projet, avec le chemin en commentaire]
```
````

**Après :**

```[langage]
[code corrigé, adapté au framework/ORM utilisé dans le projet]
```

**Étapes :**

1. [Action précise sur les fichiers et lignes listés]
   ```bash
   [commande exacte si applicable]
   ```
2. [Étape suivante]
3. [Vérification : requête EXPLAIN, log de requêtes, test de perf]

**Outils recommandés :**

- `[nom-outil]` — [description en une ligne] : `[commande d'installation ou de config]`

```

**Règles impératives :**
- Les fichiers et numéros de ligne sont ceux réellement trouvés, jamais des exemples génériques
- Le code "Avant" est extrait du projet, le code "Après" est adapté à son ORM/framework (Prisma, SQLAlchemy, ActiveRecord, etc.)
- Si plusieurs occurrences du même problème existent, les lister toutes
```
````

- [ ] **Step 2 : Vérifier l'insertion**

Lire la fin de `skills/ecocode/back/SKILL.md` et confirmer que la section est présente.

- [ ] **Step 3 : Commit**

```bash
git add skills/ecocode/back/SKILL.md
git commit -m "feat(ecocode/back): ajouter format du guide de correction complet"
```

---

## Task 5 : Question interactive dans l'orchestrateur

**Fichiers :**

- Modify: `skills/ecocode/SKILL.md` (après `## Étape 4 — Rapport final consolidé`)

- [ ] **Step 1 : Ajouter l'Étape 5 après l'Étape 4**

Après le bloc de format du rapport (qui se termine par ` ``` ` fermant le bloc markdown du rapport), insérer :

````markdown
## Étape 5 — Guide de correction complet (sur demande)

Après avoir affiché le rapport light complet, poser cette question à l'utilisateur :

> "Veux-tu le guide de correction complet ? Il liste les éléments précis trouvés dans ton code, avec des exemples avant/après et les commandes exactes pour chaque problème. (o/n)"

**Si oui :**
Générer le guide détaillé depuis les données collectées pendant l'analyse, sans relire les fichiers. Produire une section "Problème N" pour chaque problème du rapport light, en utilisant le format défini dans les sections "Format du guide de correction complet" des sous-skills `ecocode/front` et `ecocode/back`.

Structure du guide complet :

```markdown
# Guide de correction — [Nom du projet]

## Front-end

### Problème 1 — [Titre]

[section détaillée format ecocode/front]

### Problème 2 — [Titre]

[section détaillée format ecocode/front]

## Back-end

### Problème 1 — [Titre]

[section détaillée format ecocode/back]
```
````

**Si non :**
Terminer. Ne pas générer de contenu supplémentaire.

**Règle token :** Le guide est produit depuis le contexte de la session en cours. Ne pas relancer d'analyse, ne pas relire de fichiers, ne pas rappeler de MCPs.

````

- [ ] **Step 2 : Vérifier l'insertion**

Lire `skills/ecocode/SKILL.md` et confirmer que l'Étape 5 est présente après l'Étape 4, avec la question interactive et les deux branches (oui/non).

- [ ] **Step 3 : Commit**

```bash
git add skills/ecocode/SKILL.md
git commit -m "feat(ecocode): ajouter question interactive et guide de correction complet"
````

---

## Task 6 : Mettre à jour la documentation

**Fichiers :**

- Modify: `README.md` (section utilisation)
- Modify: `CLAUDE.md` (section Skills)
- Modify: `CHANGELOG.md`

- [ ] **Step 1 : Mettre à jour README.md**

Dans la section d'utilisation du README, après la description des commandes existantes, ajouter :

```markdown
### Modes de rapport

Chaque audit génère d'abord un **rapport light** (tableau des problèmes + analyse par sévérité). À la fin, une question propose un **guide de correction complet** :

- Liste précise des éléments trouvés dans le code
- Exemples avant/après adaptés au projet
- Commandes exactes et outils recommandés
- Aucune recherche complémentaire nécessaire
```

- [ ] **Step 2 : Mettre à jour CLAUDE.md**

Dans la section `## Skills`, enrichir la description du skill `ecocode` :

```markdown
- **`ecocode`** — Orchestration principale : identifie le périmètre, délègue aux sous-skills, produit un rapport light puis propose un guide de correction complet sur demande
```

- [ ] **Step 3 : Mettre à jour CHANGELOG.md**

Ajouter en tête du CHANGELOG :

```markdown
## [Unreleased]

### Added

- Rapport light + guide de correction complet interactif : après chaque audit, une question propose un guide détaillé avec code avant/après, liste précise des éléments trouvés et commandes exactes — généré depuis le contexte existant sans relecture de fichiers
```

- [ ] **Step 4 : Commit**

```bash
git add README.md CLAUDE.md CHANGELOG.md
git commit -m "docs: documenter les deux modes de rapport ecocode"
```
