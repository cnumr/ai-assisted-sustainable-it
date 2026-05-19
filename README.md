# Ecocode Plugin

Plugin d'audit éco-conception web basé sur les [115 bonnes pratiques Green IT](https://github.com/cnumr/best-practices).
Compatible Claude Code, OpenCode, Cursor, Gemini et Codex.

## Prérequis

- MCP `mcp-greenit` — accès au référentiel Green IT officiel (requis)
- MCP `playwright` — analyse d'URLs en runtime (optionnel)

## Skills

| Skill           | Description                                                                    |
| --------------- | ------------------------------------------------------------------------------ |
| `ecocode`       | Orchestration principale : identifie le périmètre, délègue, produit le rapport |
| `ecocode/front` | Analyse front-end : assets, JS, CSS, HTTP, DOM, cache, build                   |
| `ecocode/back`  | Analyse back-end : BDD, cache serveur, API, workers, infrastructure            |

## Agents

| Agent                    | Rôle                                | Permissions               |
| ------------------------ | ----------------------------------- | ------------------------- |
| `ecocode-orchestrator`   | Coordonne l'audit complet           | Lecture seule             |
| `ecocode-front-analyzer` | Analyse le code client              | Lecture seule             |
| `ecocode-back-analyzer`  | Analyse le code serveur             | Lecture seule             |
| `ecocode-report-writer`  | Écrit les fichiers d'audit          | Écriture sur docs/        |
| `ecocode-planner`        | Génère le plan d'action priorisé    | Écriture sur docs/        |
| `ecocode-fix-suggester`  | Propose et applique les corrections | Écriture sur confirmation |

## Utilisation

```
/ecocode                      # Audit complet du projet courant
/ecocode front                # Analyse front-end uniquement
/ecocode back                 # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)
```

### Modes d'exécution

En début d'audit, le plugin demande le mode souhaité :

| Mode           | Comportement                                                                                                 |
| -------------- | ------------------------------------------------------------------------------------------------------------ |
| **auto**       | Enchaîne sans interruption : analyse → fichiers d'audit → plan d'action. Résumé des fichiers créés à la fin. |
| **interactif** | Demande confirmation avant d'écrire les fichiers d'audit, puis avant de générer le plan d'action.            |

Les deux modes génèrent les mêmes fichiers dans `docs/ecocode/audits/` et `docs/ecocode/plans/`.

## Installation

### Claude Code

```bash
git clone https://github.com/your-org/ecocode-plugin ~/.claude/plugins/ecocode
ln -s ~/.claude/plugins/ecocode/skills/ecocode ~/.claude/skills/ecocode
ln -s ~/.claude/plugins/ecocode/agents/ecocode-orchestrator.md ~/.claude/agents/ecocode-orchestrator.md
ln -s ~/.claude/plugins/ecocode/agents/ecocode-front-analyzer.md ~/.claude/agents/ecocode-front-analyzer.md
ln -s ~/.claude/plugins/ecocode/agents/ecocode-back-analyzer.md ~/.claude/agents/ecocode-back-analyzer.md
ln -s ~/.claude/plugins/ecocode/agents/ecocode-fix-suggester.md ~/.claude/agents/ecocode-fix-suggester.md
```

### OpenCode

```json
{
  "plugin": ["ecocode@git+https://github.com/your-org/ecocode-plugin.git"]
}
```

Voir [`.opencode/INSTALL.md`](.opencode/INSTALL.md) pour les détails.

### Cursor

Ajouter le dépôt dans les sources de plugins Cursor. Le fichier `.cursor-plugin/plugin.json` est auto-détecté.

### Gemini

Le fichier `gemini-extension.json` et `GEMINI.md` sont auto-détectés par Gemini CLI.

### Codex

Voir [`.codex/INSTALL.md`](.codex/INSTALL.md) pour les détails.
