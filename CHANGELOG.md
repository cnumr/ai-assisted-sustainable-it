# Changelog

## [Unreleased]

### Modifié

- Documente le routage d'audit commun à Claude Code, OpenCode et Codex, avec
  exécution parallèle des analyses front-end et back-end pour `/ecocode`.
- Laisse Codex sélectionner les modèles des agents afin d'éviter les versions
  figées.

## 2.0.0 — 2026-07-23

### Changements incompatibles

- Le dépôt devient `ai-assisted-sustainable-it` et ne distribue plus que l'outil d'éco-conception `ecocode`.
- Les outils d'accessibilité sont désormais disponibles dans [ai-assisted-a11y](https://github.com/hrenaud/ai-assisted-a11y).

### Modifié

- Réorganise les skills en `design`, `development` et `audits`.
- Déplace les spécifications et plans Superpowers dans `.superpowers/`.
- Aligne les guides d'installation et les métadonnées des plugins sur `cnumr`.

## 1.2.0 — 2026-07-21

### Ajouté

- Étend le guide proactif `ecocode/dev-guide` à la conception sobre des solutions.

### Corrigé

- Aligne le test de structure RGAA sur l'agent `rgaa-page-analyzer`.
- Clarifie que `ecocode` lance les audits sur demande, tandis que `ecocode/dev-guide` applique les règles de codage de manière proactive.

## 1.1.0 — 2026-07-01

### Ajouté

- Skill RGAA 4.2.1 complet : flow multi-pages, statuts C/NC/NA/⚠, taux de conformité (fourchette bas/haut), rapport horodaté + checklist manuelle
- Agents RGAA : `rgaa-orchestrator` (coordination), `rgaa-page-analyzer` (analyse par page via MCP + Playwright), `rgaa-reporter` (rapport markdown), `rgaa-checklist` (checklist manuelle des tests ⚠)
- Commande `/rgaa` avec support multi-URLs et détection du type d'audit (rapide par défaut)
- Prérequis MCP `mcp-rgaa` documenté dans README, CLAUDE.md et fichiers d'installation

- Mode développement passif : guide compact de 19 règles Green IT (RWEB_0007 à RWEB_0106) injecté automatiquement à chaque session via le hook `SessionStart` — Claude applique les bonnes pratiques d'éco-conception en écrivant du code sans appel explicite à `/ecocode`
- Reprise d'audit existant : `/ecocode plan`, `/ecocode fix`, `/ecocode fix RWEB_XXX` reprennent depuis le dernier audit sans re-analyser ; détection automatique à chaque appel `/ecocode` quand des audits existent dans `docs/ecocode/audits/`
- Sous-skill `ecocode/resume` : lecture des fichiers d'audit markdown, extraction des problèmes et des scores, routage vers `ecocode-planner` ou `ecocode-fix-suggester`
- Deux modes d'exécution : `auto` (audit complet sans interruption avec résumé final) et `interactif` (confirmations avant l'écriture des fichiers et avant le plan d'action)
- Agent `ecocode-report-writer` : écriture automatique des résultats d'audit dans des fichiers markdown horodatés séparés par couche (`docs/ecocode/audits/{timestamp}-audit-front.md`, `docs/ecocode/audits/{timestamp}-audit-back.md`) au lieu de l'affichage terminal
- Agent `ecocode-planner` : génération sur demande d'un plan d'action priorisé P1→P4 dans `docs/ecocode/plans/{timestamp}-plan.md`, avec cases à cocher, code avant/après adapté au framework, et commandes exactes
- Skill `ecocode/report-writer` : format des fichiers d'audit (front et back)
- Skill `ecocode/planner` : format du plan d'action (matrice effort/impact, cases à cocher)
- Rapport light + guide de correction complet interactif : après chaque audit, une question propose un guide détaillé avec code avant/après, liste précise des éléments trouvés et commandes exactes — généré depuis le contexte existant sans relecture de fichiers

### Corrigé

- Adaptation des noms d'outils MCP renommés : préfixe `greenit_` ajouté aux fonctions `mcp-greenit`, correction de `rgaa_chercher_fiche` → `rgaa_chercher` dans le skill `rgaa`

## 1.0.0 — 2026-05-18

### Ajouté

- Skills `ecocode`, `ecocode/front`, `ecocode/back` couvrant les 115 bonnes pratiques Green IT
- Agents `ecocode-orchestrator`, `ecocode-front-analyzer`, `ecocode-back-analyzer`, `ecocode-fix-suggester`
- Support multi-plateforme : Claude Code, OpenCode, Cursor, Gemini, Codex
- Hook `SessionStart` — injection du bootstrap ecocode en début de session
- Plugin OpenCode avec `config` hook et `experimental.chat.messages.transform`
- Gestion de l'authentification Playwright : détection auto, 2FA (TOTP, SMS, push), cas WebAuthn non automatisables
- Script `scripts/bump-version.sh` pour la synchronisation des versions
- Documentation développeur : `docs/contributing.md`, `docs/releasing.md`, `docs/testing.md`
