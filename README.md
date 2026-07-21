# ai-assisted-sustainable-it

Outil d'audit et d'assistance au développement éco-conçus pour Claude Code,
OpenCode, Cursor, Gemini et Codex. Il applique les [115 bonnes pratiques Green
IT](https://github.com/cnumr/best-practices) lors des audits et pendant le
développement.

## Fonctionnalités

- Audit éco-conception complet du front-end et du back-end.
- Guide de conception et de développement sobre, injecté au démarrage de session.
- Rapports, plans d'action et corrections guidées à partir des audits.

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

- MCP `mcp-greenit` — accès au référentiel Green IT (requis).
- MCP `playwright` — analyse d'URLs en runtime (optionnel).

## Installation

### Claude Code

```bash
/plugin marketplace add hrenaud/ai-assisted-sustainable-it
/plugin install ecocode@ai-assisted-sustainable-it
```

Ou manuellement :

```bash
git clone https://github.com/hrenaud/ai-assisted-sustainable-it.git ~/.claude/plugins/ai-assisted-sustainable-it
ln -s ~/.claude/plugins/ai-assisted-sustainable-it/skills/ecocode ~/.claude/skills/ecocode
ln -s ~/.claude/plugins/ai-assisted-sustainable-it/agents/ecocode-*.md ~/.claude/agents/
```

### OpenCode

```json
{
  "plugin": ["ai-assisted-sustainable-it@git+https://github.com/hrenaud/ai-assisted-sustainable-it.git"]
}
```

Voir [le guide OpenCode](docs/README.opencode.md) pour les détails.

### Codex

```bash
git clone https://github.com/hrenaud/ai-assisted-sustainable-it.git ~/.codex/plugins/ai-assisted-sustainable-it
mkdir -p ~/.codex/skills
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/ecocode ~/.codex/skills/ecocode
```

Redémarrez Codex ou ouvrez une nouvelle tâche après l'installation.

### Cursor et Gemini

Les manifestes `.cursor-plugin` et `gemini-extension.json` sont fournis pour
ces plateformes.

## Migration depuis ia-tools

Cette version ne contient plus les outils d'accessibilité. Ils sont désormais
publiés dans [ai-assisted-a11y](https://github.com/hrenaud/ai-assisted-a11y).
