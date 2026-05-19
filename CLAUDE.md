# Plugin EcoCode

Plugin d'audit éco-conception web pour Claude Code, OpenCode et Codex.
Basé sur les [115 bonnes pratiques Green IT](https://github.com/cnumr/best-practices).

## Prérequis

Ce plugin requiert le MCP `mcp-greenit` pour accéder au référentiel Green IT officiel.
Le MCP `playwright` est optionnel (nécessaire pour l'analyse d'URLs en runtime).

## Skills

- **`ecocode`** — Orchestration principale : identifie le périmètre, délègue aux sous-skills, produit un rapport light puis propose un guide de correction complet sur demande
- **`ecocode/front`** — Analyse front-end : assets, JS, CSS, HTTP, DOM, cache, build
- **`ecocode/back`** — Analyse back-end : BDD, cache serveur, API, workers, infrastructure

## Agents

| Agent                    | Rôle                                | Permissions               |
| ------------------------ | ----------------------------------- | ------------------------- |
| `ecocode-orchestrator`   | Coordonne l'audit complet           | Lecture seule             |
| `ecocode-front-analyzer` | Analyse le code client              | Lecture seule             |
| `ecocode-back-analyzer`  | Analyse le code serveur             | Lecture seule             |
| `ecocode-fix-suggester`  | Propose et applique les corrections | Écriture sur confirmation |

## Utilisation

```
/ecocode                   # Audit complet du projet courant
/ecocode front             # Analyse front-end uniquement
/ecocode back              # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)
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
