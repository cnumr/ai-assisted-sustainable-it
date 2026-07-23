# Scission des outils d’audit assistés par IA — conception

## Objectif

Séparer le monorepo `ia-tools`, publié en version `v1.2.0`, en deux dépôts autonomes dont l’IA assiste respectivement l’éco-conception et l’accessibilité :

- `ai-assisted-sustainable-it` pour les pratiques d’éco-conception et de Green IT ;
- `ai-assisted-a11y` pour les audits et guides d’accessibilité.

## Décisions validées

- La release `v1.2.0` du monorepo est la dernière release commune ; elle reste disponible avec son tag et ses notes de version.
- Le dépôt actuel est renommé `ai-assisted-sustainable-it`.
- Le dépôt `ai-assisted-a11y` est créé neuf : il reçoit l’état des fichiers RGAA de `v1.2.0`, dans un premier commit de migration, sans conserver l’historique Git du monorepo.
- Les noms des dépôts placent l’IA comme moyen d’assistance, et non comme objet des audits.

## Périmètres des dépôts

### `ai-assisted-sustainable-it`

Conserve exclusivement le périmètre éco-conception :

- `skills/ecocode/` et les agents, commandes et plugins `ecocode` associés ;
- les hooks et le guide de développement éco-conçu ;
- les tests Ecocode ;
- une documentation, des manifests et des installations ne référant plus que ce plugin.

Le premier changement après la scission est une version majeure `2.0.0`, car l’installation multi-outils et le plugin RGAA disparaissent.

### `ai-assisted-a11y`

Contient exclusivement le périmètre accessibilité :

- `skills/rgaa/`, les agents, commandes et plugins `rgaa` associés ;
- les tests et la documentation RGAA ;
- des manifests et installations ne déclarant qu’un plugin d’accessibilité.

Le nouveau dépôt démarre en `1.0.0`. Son premier commit est daté de la migration et mentionne que son contenu provient de `ia-tools@v1.2.0`.

## Migration

1. Créer les deux configurations monoutil à partir de l’état `v1.2.0` : l’une dans le dépôt existant, l’autre dans un nouveau répertoire Git indépendant.
2. Renommer le dépôt GitHub existant en `ai-assisted-sustainable-it`, puis mettre à jour son URL distante locale et toutes les références Markdown, manifests et commandes d’installation.
3. Créer le dépôt GitHub `ai-assisted-a11y`, y publier son commit initial, puis mettre à jour ses références Markdown, manifests et commandes d’installation.
4. Vérifier dans chaque dépôt : structure, cohérence des manifests et des versions, audit de version et absence de référence fonctionnelle à l’autre outil.

Les anciennes URL GitHub sont conservées par redirection après renommage. Les documents doivent néanmoins employer les nouvelles URL afin de ne pas dépendre de ces redirections.

## Hors périmètre

- Changer le nom des commandes `/ecocode` ou `/rgaa`.
- Ajouter de nouvelles fonctionnalités d’audit.
- Réécrire l’historique du monorepo ou transférer son historique vers `ai-assisted-a11y`.
- Modifier les versions antérieures ou le tag `v1.2.0`.

## Critères d’acceptation

- `ai-assisted-sustainable-it` ne contient aucune configuration, installation ou test fonctionnel RGAA.
- `ai-assisted-a11y` ne contient aucune configuration, installation ou test fonctionnel Ecocode.
- Chaque dépôt expose un seul plugin dans ses marketplaces Claude Code et Codex.
- Les métadonnées de version et les instructions Markdown référencent le nom et l’URL de leur propre dépôt.
- Les tests structurels et de version propres à chaque dépôt passent.
