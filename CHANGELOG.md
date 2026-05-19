# Changelog

## [Unreleased]

### Ajouté

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
