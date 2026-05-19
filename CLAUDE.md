# Plugin EcoCode

Plugin d'audit éco-conception web pour Claude Code, OpenCode et Codex.
Basé sur les [115 bonnes pratiques Green IT](https://github.com/cnumr/best-practices).

## Prérequis

Ce plugin requiert le MCP `mcp-greenit` pour accéder au référentiel Green IT officiel.
Le MCP `playwright` est optionnel (nécessaire pour l'analyse d'URLs en runtime).

## Skills

- **`ecocode`** — Orchestration principale éco-conception : identifie le périmètre, délègue aux sous-skills, écrit les fichiers d'audit
- **`ecocode/front`** — Analyse front-end : assets, JS, CSS, HTTP, DOM, cache, build
- **`ecocode/back`** — Analyse back-end : BDD, cache serveur, API, workers, infrastructure
- **`rgaa`** — Audit accessibilité RGAA 4.2.1 (stub — en développement)

## Agents

| Agent                    | Outil   | Rôle                                | Permissions               |
| ------------------------ | ------- | ----------------------------------- | ------------------------- |
| `ecocode-orchestrator`   | ecocode | Coordonne l'audit éco-conception    | Lecture seule             |
| `ecocode-front-analyzer` | ecocode | Analyse le code client              | Lecture seule             |
| `ecocode-back-analyzer`  | ecocode | Analyse le code serveur             | Lecture seule             |
| `ecocode-report-writer`  | ecocode | Écrit les fichiers d'audit          | Écriture sur docs/        |
| `ecocode-planner`        | ecocode | Génère le plan d'action priorisé    | Écriture sur docs/        |
| `ecocode-fix-suggester`  | ecocode | Propose et applique les corrections | Écriture sur confirmation |
| `rgaa-auditor`           | rgaa    | Audit RGAA (stub)                   | Lecture seule             |
| `rgaa-reporter`          | rgaa    | Rapport RGAA (stub)                 | Lecture seule             |

## Utilisation

```
/ecocode                      # Audit éco-conception complet du projet courant
/ecocode front                # Analyse front-end uniquement
/ecocode back                 # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)

/rgaa                         # Audit accessibilité RGAA (en développement)
```

## Installation Claude Code

```bash
# Cloner le plugin
git clone https://github.com/your-org/ecocode-plugin ~/.claude/plugins/ecocode

# Créer le symlink
ln -s ~/.claude/plugins/ecocode/skills/ecocode ~/.claude/skills/ecocode
```

## Installation OpenCode

Ajouter dans la config OpenCode :

```json
{
  "plugins": ["path/to/ecocode-plugin"]
}
```
