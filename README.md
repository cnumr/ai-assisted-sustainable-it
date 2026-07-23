# ai-assisted-sustainable-it

Des skills pour créer et implémenter des produits numériques éco-conçus, ainsi
que pour auditer et améliorer des produits existants, avec Claude Code,
OpenCode, Cursor, Gemini et Codex. Ils s'appuient sur les [115 bonnes pratiques
Green IT](https://github.com/cnumr/best-practices).

## Fonctionnalités

- Skills de conception et d'implémentation sobre, injectés au démarrage de
  session.
- Skills d'audit éco-conception complet du front-end et du back-end.
- Rapports, plans d'action et corrections guidées pour améliorer les produits
  audités.

## Utilisation

```text
/ecocode                      # Audit complet du projet courant
/ecocode front                # Analyse front-end uniquement
/ecocode back                 # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)
/ecocode plan                 # Plan d'action depuis le dernier audit
/ecocode fix                  # Correction guidée depuis le dernier audit
```

## Prérequis

- MCP [`mcp-greenit`](https://mcp-115-bp.greenit.eco/) — accès au référentiel
  Green IT (requis).
- MCP `playwright` — analyse d'URLs en runtime (optionnel).

## Installation

### Claude Code

```bash
/plugin marketplace add hrenaud/ai-assisted-sustainable-it
/plugin install ecocode@ai-assisted-sustainable-it
```

Ou manuellement :

```bash
git clone https://github.com/cnumr/ai-assisted-sustainable-it.git ~/.claude/plugins/ai-assisted-sustainable-it
ln -s ~/.claude/plugins/ai-assisted-sustainable-it/skills/audits ~/.claude/skills/audits
ln -s ~/.claude/plugins/ai-assisted-sustainable-it/agents/ecocode-*.md ~/.claude/agents/
```

### OpenCode

```json
{
  "plugin": ["ai-assisted-sustainable-it@git+https://github.com/cnumr/ai-assisted-sustainable-it.git"]
}
```

Voir [le guide OpenCode](docs/README.opencode.md) pour les détails.

### Codex

```bash
git clone https://github.com/cnumr/ai-assisted-sustainable-it.git ~/.codex/plugins/ai-assisted-sustainable-it
mkdir -p ~/.codex/skills
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/audits ~/.codex/skills/audits
```

Redémarrez Codex ou ouvrez une nouvelle tâche après l'installation.

### Cursor et Gemini

Les manifestes `.cursor-plugin` et `gemini-extension.json` sont fournis pour
ces plateformes.
