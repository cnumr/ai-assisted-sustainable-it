# ai-assisted-sustainable-it

Outil d'audit et de développement éco-conçus pour Claude Code, OpenCode et Codex.

## Prérequis

- MCP `mcp-greenit` requis pour ecocode.
- MCP `playwright` optionnel pour l'analyse d'URLs en runtime.

## Skills

- **`ecocode`** — orchestration des audits éco-conception.
- **`ecocode/front`** — analyse des assets, JS, CSS, HTTP, DOM, cache et build.
- **`ecocode/back`** — analyse BDD, cache serveur, API, workers et infrastructure.

## Agents

| Agent                    | Rôle                                | Permissions               |
| ------------------------ | ----------------------------------- | ------------------------- |
| `ecocode-orchestrator`   | Coordonne l'audit éco-conception    | Lecture seule             |
| `ecocode-front-analyzer` | Analyse le code client              | Lecture seule             |
| `ecocode-back-analyzer`  | Analyse le code serveur             | Lecture seule             |
| `ecocode-report-writer`  | Écrit les fichiers d'audit          | Écriture sur docs/        |
| `ecocode-planner`        | Génère le plan d'action priorisé    | Écriture sur docs/        |
| `ecocode-fix-suggester`  | Propose et applique les corrections | Écriture sur confirmation |

## Utilisation

```text
/ecocode                      # Audit éco-conception complet du projet courant
/ecocode front                # Analyse front-end uniquement
/ecocode back                 # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)
```

## Installation Claude Code

```bash
git clone https://github.com/hrenaud/ai-assisted-sustainable-it.git ~/.claude/plugins/ai-assisted-sustainable-it
ln -s ~/.claude/plugins/ai-assisted-sustainable-it/skills/ecocode ~/.claude/skills/ecocode
```
