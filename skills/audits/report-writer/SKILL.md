---
name: ecocode-report-writer
description: Use when writing EcoCode audit results to markdown files. Formats static front-end, runtime front-end and back-end audit data into separate timestamped files in docs/ecocode/audits/.
---

# EcoCode Report Writer — Écriture des fichiers d'audit

## Vue d'ensemble

Ce sous-skill écrit les résultats d'audit éco-conception dans des fichiers markdown séparés par périmètre. Il reçoit les données de l'orchestrateur et produit les fichiers horodatés concernés.

**REQUIRED PARENT SKILL:** `audits` — ce sous-skill est délégué par l'orchestrateur.

## Fichiers produits

| Fichier                                               | Contenu                          |
| ----------------------------------------------------- | -------------------------------- |
| `docs/ecocode/audits/YYYY-MM-DDTHH-MM-audit-front.md` | Résultats de l'analyse front-end |
| `docs/ecocode/audits/YYYY-MM-DDTHH-MM-audit-frontend.md` | Audit runtime front-end des parcours |
| `docs/ecocode/audits/YYYY-MM-DDTHH-MM-audit-back.md`  | Résultats de l'analyse back-end  |

Le préfixe `YYYY-MM-DDTHH-MM` est calculé à partir de la date/heure courante (ex: `2026-05-19T14-32`).

## Données reçues de l'orchestrateur

L'agent reçoit les données suivantes :

- `projectName` : nom du projet (extrait du package.json, README ou dossier courant)
- `timestamp` : horodatage pour les noms de fichiers, format `YYYY-MM-DDTHH-MM` (ex: `2026-05-19T14-32`)
- `frontData` : résultats complets de l'analyse front-end (si effectuée)
- `frontendData` : résultat JSON strict de `ecocode-frontend-analyzer` (si `/ecocode frontend` a été effectué)
- `backData` : résultats complets de l'analyse back-end (si effectuée)
- `ecoIndex` : score EcoIndex officiel (score 0-100, grade A-G, CO2, eau) — front uniquement
- `impactScore` : score d'impact interne pré-calculé (1-10) selon la formule du skill parent

## Étapes d'exécution

1. Créer le dossier `docs/ecocode/audits/` s'il n'existe pas : `mkdir -p docs/ecocode/audits`
2. Utiliser le `timestamp` reçu pour construire les noms de fichiers : `${timestamp}-audit-front.md`, `${timestamp}-audit-frontend.md` et `${timestamp}-audit-back.md`
   - Le format du timestamp est déjà `YYYY-MM-DDTHH-MM` (ex: `2026-05-19T14-32`)
   - Exemple : `2026-05-19T14-32-audit-front.md`
3. Pour la **date affichée dans le header** du fichier, utiliser le format `date +"%Y-%m-%d %H:%M"` (ex: `2026-05-19 14:32`)
4. Écrire le fichier front si des données front sont disponibles
5. Écrire le fichier runtime si `frontendData` est disponible
6. Écrire le fichier back si des données back sont disponibles
7. Retourner les chemins absolus des fichiers écrits à l'orchestrateur

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

## Format du fichier d'audit runtime front-end

Écrire un seul fichier `YYYY-MM-DDTHH-MM-audit-frontend.md` à partir de
`frontendData`. Ne jamais mélanger ces résultats avec `audit-front.md`, qui
reste le rapport de l'audit statique.

Interpréter les champs optionnels selon le schéma strict de
`audits/frontend` : `capture` est `null` ou un chemin relatif PNG ;
`code_observe` et `correction` sont `null` ou des strings. Refuser un autre
type au lieu de le convertir ou de l’inventer.

```markdown
# Audit runtime front-end — [Nom du projet]

**Date :** YYYY-MM-DD HH:MM

## Parcours exécutés

| Parcours | Statut | Pages mesurées | Erreurs |
| -------- | ------ | -------------- | ------- |
| ...      | terminé / erreur | ... | ... |

## Sommaire des scores

| Parcours | Point d’audit | URL finale | EcoIndex | GES | Eau |
| -------- | ------------- | ---------- | -------- | --- | --- |
| ...      | ...           | ...        | ...      | ... | ... |

## [Nom du parcours]

### [Nom du point d’audit]

- **URL finale :** ...
- **Métriques :** DOM : ..., requêtes : ..., transfert : ... KB
- **EcoIndex :** .../100 — grade ...
- **GES :** ...
- **Eau :** ...

### Écarts GreenIT

Pour chaque écart non dédupliqué : identifiant et intitulé MCP exacts,
sévérité, observation, preuve, extrait observé et correction disponible.
Pour une occurrence dédupliquée : indiquer seulement sa référence stable et sa
première occurrence.

### Performance

Alertes runtime mesurées sans fiche GreenIT vérifiée.

### Développement web

Erreurs de console, HTML, API ou qualité de code observées sans fiche GreenIT
vérifiée.

## Erreurs d’exécution et limites

Lister les erreurs par parcours et les limites globales, sans inventer de
mesure absente. Ajouter les captures uniquement lorsqu’elles sont des preuves
utiles et jamais si elles affichent une authentification ou une donnée sensible.
```

## Règles impératives

- Ne jamais relire les fichiers source du projet — utiliser uniquement les données reçues de l'orchestrateur
- Toujours créer `docs/ecocode/audits/` avant d'écrire (idempotent)
- Si une couche n'a pas été analysée (ex: audit front uniquement), ne pas créer le fichier correspondant
- Si `frontendData` est disponible, créer uniquement `audit-frontend.md` pour le runtime ; ne pas créer `audit-front.md` sans `frontData`
- Retourner les chemins exacts des fichiers créés pour que l'orchestrateur les affiche à l'utilisateur
