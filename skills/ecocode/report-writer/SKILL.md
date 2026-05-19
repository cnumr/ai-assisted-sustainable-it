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
