---
name: ecocode-report-writer
description: Use when writing EcoCode audit results to markdown files. Formats front-end and back-end audit data into separate timestamped files in docs/ecocode/audits/.
---

# EcoCode Report Writer — Écriture des fichiers d'audit

## Vue d'ensemble

Ce sous-skill écrit les résultats d'audit éco-conception dans des fichiers markdown séparés par couche. Il reçoit les données de l'orchestrateur et produit deux fichiers horodatés.

**REQUIRED PARENT SKILL:** `audits` — ce sous-skill est délégué par l'orchestrateur.

## Fichiers produits

| Fichier                                               | Contenu                          |
| ----------------------------------------------------- | -------------------------------- |
| `docs/ecocode/audits/YYYY-MM-DDTHH-MM-audit-front.md` | Résultats de l'analyse front-end |
| `docs/ecocode/audits/YYYY-MM-DDTHH-MM-audit-back.md`  | Résultats de l'analyse back-end  |

Le préfixe `YYYY-MM-DDTHH-MM` est calculé à partir de la date/heure courante (ex: `2026-05-19T14-32`).

## Données reçues de l'orchestrateur

L'agent reçoit les données suivantes :

- `projectName` : nom du projet (extrait du package.json, README ou dossier courant)
- `timestamp` : horodatage pour les noms de fichiers, format `YYYY-MM-DDTHH-MM` (ex: `2026-05-19T14-32`)
- `frontData` : résultats complets de l'analyse front-end (si effectuée)
- `backData` : résultats complets de l'analyse back-end (si effectuée)
- `ecoIndex` : score EcoIndex officiel (score 0-100, grade A-G, CO2, eau) — front uniquement
- `impactScore` : score d'impact interne pré-calculé (1-10) selon la formule du skill parent

## Étapes d'exécution

1. Créer le dossier `docs/ecocode/audits/` s'il n'existe pas : `mkdir -p docs/ecocode/audits`
2. Utiliser le `timestamp` reçu pour construire les noms de fichiers : `${timestamp}-audit-front.md` et `${timestamp}-audit-back.md`
   - Le format du timestamp est déjà `YYYY-MM-DDTHH-MM` (ex: `2026-05-19T14-32`)
   - Exemple : `2026-05-19T14-32-audit-front.md`
3. Pour la **date affichée dans le header** du fichier, utiliser le format `date +"%Y-%m-%d %H:%M"` (ex: `2026-05-19 14:32`)
4. Écrire le fichier front si des données front sont disponibles
5. Écrire le fichier back si des données back sont disponibles
6. Retourner les chemins absolus des fichiers écrits à l'orchestrateur

## Format du fichier d'audit front

```markdown
# Audit Éco-conception Front-end — [Nom du projet]

**Date :** YYYY-MM-DD HH:MM
**EcoIndex :** XX/100 — Grade A (émissions : X,XX gCO2e/page vue — eau : X,XX cl/page vue)
**Score d'impact interne :** X/10

> Note : Le score d'impact interne est reçu pré-calculé de l'orchestrateur. L'agent report-writer l'insère directement dans le template.

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

> Note : L'EcoIndex officiel (DOM, HTTP, taille) s'applique uniquement au front-end. Le fichier d'audit back ne contient donc pas de score EcoIndex.

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
