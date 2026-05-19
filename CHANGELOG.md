# Changelog

## [Unreleased]

### Ajouté

- Deux modes d'exécution : `auto` (audit complet sans interruption avec résumé final) et `interactif` (confirmations avant l'écriture des fichiers et avant le plan d'action)
- Agent `ecocode-report-writer` : écriture automatique des résultats d'audit dans des fichiers markdown horodatés séparés par couche (`docs/ecocode/audits/{timestamp}-audit-front.md`, `docs/ecocode/audits/{timestamp}-audit-back.md`) au lieu de l'affichage terminal
- Agent `ecocode-planner` : génération sur demande d'un plan d'action priorisé P1→P4 dans `docs/ecocode/plans/{timestamp}-plan.md`, avec cases à cocher, code avant/après adapté au framework, et commandes exactes
- Skill `ecocode/report-writer` : format des fichiers d'audit (front et back)
- Skill `ecocode/planner` : format du plan d'action (matrice effort/impact, cases à cocher)
- Rapport light + guide de correction complet interactif : après chaque audit, une question propose un guide détaillé avec code avant/après, liste précise des éléments trouvés et commandes exactes — généré depuis le contexte existant sans relecture de fichiers

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
