# ia-tools

Outils d'audit qualité web pour Claude Code, OpenCode et Codex.
Inclut éco-conception (ecocode) et accessibilité RGAA (rgaa).

## Prérequis

- MCP `mcp-greenit` requis pour l'outil ecocode
- MCP `rgaa` requis pour l'outil rgaa
- MCP `playwright` optionnel (nécessaire pour l'analyse d'URLs en runtime)

## Skills

- **`ecocode`** — Orchestration principale éco-conception : identifie le périmètre, délègue aux sous-skills, écrit les fichiers d'audit
- **`ecocode/front`** — Analyse front-end : assets, JS, CSS, HTTP, DOM, cache, build
- **`ecocode/back`** — Analyse back-end : BDD, cache serveur, API, workers, infrastructure
- **`rgaa`** — Audit accessibilité RGAA 4.2.1

## Agents

| Agent                    | Outil   | Rôle                                | Permissions               |
| ------------------------ | ------- | ----------------------------------- | ------------------------- |
| `ecocode-orchestrator`   | ecocode | Coordonne l'audit éco-conception    | Lecture seule             |
| `ecocode-front-analyzer` | ecocode | Analyse le code client              | Lecture seule             |
| `ecocode-back-analyzer`  | ecocode | Analyse le code serveur             | Lecture seule             |
| `ecocode-report-writer`  | ecocode | Écrit les fichiers d'audit          | Écriture sur docs/        |
| `ecocode-planner`        | ecocode | Génère le plan d'action priorisé    | Écriture sur docs/        |
| `ecocode-fix-suggester`  | ecocode | Propose et applique les corrections | Écriture sur confirmation |
| `rgaa-orchestrator`      | rgaa    | Coordonne l'audit RGAA              | Lecture seule             |
| `rgaa-page-analyzer`     | rgaa    | Analyse une page (par URL)          | Lecture seule             |
| `rgaa-reporter`          | rgaa    | Écrit le rapport d'audit            | Écriture sur docs/        |
| `rgaa-checklist`         | rgaa    | Génère la checklist manuelle        | Écriture sur docs/        |

## Utilisation

```
/ecocode                      # Audit éco-conception complet du projet courant
/ecocode front                # Analyse front-end uniquement
/ecocode back                 # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)

/rgaa https://example.com     # Audit accessibilité RGAA d'une page
```

## Installation Claude Code

```bash
# Cloner le repo
git clone https://github.com/novagaia/ia-tools ~/.claude/plugins/ia-tools

# Créer les symlinks pour les outils voulus
ln -s ~/.claude/plugins/ia-tools/skills/ecocode ~/.claude/skills/ecocode
ln -s ~/.claude/plugins/ia-tools/skills/rgaa ~/.claude/skills/rgaa
```

## Installation OpenCode

Ajouter dans la config OpenCode :

```json
{
  "plugins": ["path/to/ia-tools"]
}
```
