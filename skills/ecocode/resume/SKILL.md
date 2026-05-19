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

**Framework détecté** : scanner les sections "Constat" de tous les problèmes détectés pour identifier un framework ou ORM (ex: React, Vue, Angular, Prisma, SQLAlchemy, Rails, Hibernate, Django, Express). Retenir la première mention trouvée, sinon `null`.

Ne pas relire les fichiers source du projet — uniquement les fichiers d'audit.

## Étape 2 — Router selon l'action

### Action `plan`

Déléguer à `ecocode-planner` avec :

- `problems` : liste complète des problèmes extraits (couche, localisation, code exact trouvé, sévérité, RWEB_XXXX) — l'effort sera estimé par `ecocode-planner` lui-même
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
> Front-end : EcoIndex {score}/100 — Grade {grade} — Score d'impact {X}/10 _(si fichier front présent)_
> Back-end : Score d'impact {X}/10 _(si fichier back présent)_
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

N'afficher que les lignes correspondant aux fichiers d'audit effectivement lus.

Attendre la réponse et router vers l'action correspondante.

## Règles impératives

- Ne jamais relancer l'analyse des fichiers source — uniquement lire les fichiers d'audit
- Extraire les données du markdown des fichiers d'audit sans inventer de problèmes non présents
- Si un fichier d'audit est introuvable ou illisible : le signaler et proposer de relancer un audit complet avec `/ecocode`
- Le timestamp du plan généré est identique à celui de l'audit d'origine
- Si les deux fichiers (front et back) existent pour le même timestamp, les lire tous les deux avant de router
