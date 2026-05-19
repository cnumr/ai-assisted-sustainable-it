---
name: ecocode-planner
description: Use when generating a prioritized action plan from EcoCode audit results. Writes a markdown file with checkboxes, P1→P4 priorities, before/after code, and exact commands.
---

# EcoCode Planner — Génération du plan d'action

## Vue d'ensemble

Ce sous-skill génère un plan d'action priorisé à partir des résultats d'audit. Il reçoit les données agrégées de l'orchestrateur et produit un fichier markdown structuré avec des cases à cocher.

**REQUIRED PARENT SKILL:** `ecocode` — ce sous-skill est délégué par l'orchestrateur.

## Données reçues de l'orchestrateur

L'agent reçoit les données suivantes :

- `projectName` : nom du projet
- `timestamp` : horodatage identique aux fichiers d'audit (format `YYYY-MM-DDTHH-MM`)
- `auditPaths` : chemins des fichiers d'audit déjà écrits (pour la référence dans le header)
- `problems` : liste complète des problèmes détectés, par couche, avec pour chacun : localisation exacte, code trouvé, sévérité, RWEB_XXXX, effort estimé
- `goodPractices` : liste des bonnes pratiques déjà respectées
- `framework` : framework/ORM détecté dans le projet (ex: Prisma, SQLAlchemy, React, Rails)

## Fichier produit

`docs/ecocode/plans/{timestamp}-plan.md`

Le timestamp est identique à celui des fichiers d'audit pour garantir la cohérence entre rapport et plan.

## Matrice de priorité

| Effort \ Impact | Fort | Moyen | Faible |
| --------------- | ---- | ----- | ------ |
| Faible          | P1   | P2    | P3     |
| Moyen           | P2   | P3    | P4     |
| Fort            | P3   | P4    | —      |

**Estimation de l'effort :**

- Faible = changement d'une ligne ou d'une config, ajout d'un index
- Moyen = refactoring localisé dans 1-3 fichiers
- Fort = changement d'architecture, migration, refactoring multi-fichiers

## Étapes d'exécution

1. Créer le dossier `docs/ecocode/plans/` s'il n'existe pas : `mkdir -p docs/ecocode/plans`
2. Trier les problèmes par priorité P1→P4 selon la matrice effort/impact
3. Pour chaque problème, rédiger une section avec case à cocher, code avant/après, et commandes
4. Écrire le fichier `docs/ecocode/plans/{timestamp}-plan.md`
5. Retourner le chemin du fichier créé à l'orchestrateur

## Format du fichier de plan

````markdown
# Plan d'action Éco-conception — [Nom du projet]

**Date :** YYYY-MM-DD HH:MM
**Basé sur :**

- `docs/ecocode/audits/{timestamp}-audit-front.md`
- `docs/ecocode/audits/{timestamp}-audit-back.md`
  **Problèmes :** X au total (A haute, B moyenne, C faible sévérité)

---

## P1 — À faire maintenant (fort impact, faible effort)

### - [ ] [Titre du problème]

**Pratique :** RWEB_XXXX — [intitulé officiel]
**Couche :** Front-end / Back-end
**Localisation :** `chemin/fichier.ext:ligne`

**Avant :**

```[langage]
[code exact trouvé dans le projet]
```
````

**Après :**

```[langage]
[code corrigé adapté au framework/ORM du projet]
```

**Commandes :**

```bash
[commandes exactes si applicable, ex: CREATE INDEX, npm install, etc.]
```

---

## P2 — À planifier (fort impact, effort modéré)

### - [ ] [Titre du problème]

[même structure]

---

## P3 — Si opportunité (impact modéré)

### - [ ] [Titre du problème]

[même structure]

---

## P4 — Backlog (impact faible ou effort fort)

### - [ ] [Titre du problème]

[même structure]

---

## Références Green IT

| RWEB      | Intitulé            | Priorité |
| --------- | ------------------- | -------- |
| RWEB_XXXX | [intitulé officiel] | P1       |

```

## Règles impératives

- Utiliser uniquement les données reçues de l'orchestrateur — ne pas relire les fichiers source
- Le code "Avant" doit être le code exact trouvé dans le projet (tel que collecté pendant l'analyse)
- Le code "Après" doit être adapté au framework/ORM réel détecté (`framework` reçu de l'orchestrateur)
- Chaque problème a exactement une case à cocher `- [ ]`
- Si un problème n'a pas de code associé (problème d'architecture, d'hébergement), remplacer les blocs code par une liste d'étapes textuelles
- Omettre une section entière P1/P2/P3/P4 si elle est vide plutôt que de la laisser vide
- Toujours inclure la section "Références Green IT" en fin de fichier
- Le timestamp du plan est identique à celui des fichiers d'audit (transmis par l'orchestrateur)
```
