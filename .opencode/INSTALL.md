# Installing ia-tools for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed
- `mcp-greenit` MCP server configured (required for ecocode)
- `mcp-rgaa` MCP server configured (required for rgaa)
- `playwright` MCP server configured (optional — needed for URL analysis)

## Installation

Add ia-tools to the `plugin` array in your `opencode.json`:

```json
{
  "plugin": ["ia-tools@git+https://github.com/novagaia/ia-tools.git"]
}
```

Restart OpenCode. The plugin installs through OpenCode's plugin manager and
registers all skills automatically.

Verify by asking: "Lance un audit ecocode sur ce projet"

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to load ecocode
use skill tool to load ecocode/front
use skill tool to load ecocode/back
use skill tool to load rgaa
```

Or use slash commands:

```
/ecocode              # Audit éco-conception complet
/ecocode front        # Analyse front-end uniquement
/ecocode back         # Analyse back-end uniquement
/rgaa                 # Audit accessibilité RGAA (en développement)
```

## Agents

The plugin registers the following agents:

| Agent                    | Outil   | Rôle                                                   |
| ------------------------ | ------- | ------------------------------------------------------ |
| `ecocode-orchestrator`   | ecocode | Coordonne l'audit éco-conception                       |
| `ecocode-front-analyzer` | ecocode | Analyse le code client (lecture seule)                 |
| `ecocode-back-analyzer`  | ecocode | Analyse le code serveur (lecture seule)                |
| `ecocode-fix-suggester`  | ecocode | Propose et applique les corrections (sur confirmation) |
| `rgaa-auditor`           | rgaa    | Audit RGAA (stub)                                      |
| `rgaa-reporter`          | rgaa    | Rapport RGAA (stub)                                    |

## MCP Configuration

Ensure `mcp-greenit` is configured in your OpenCode MCP settings to access
the Green IT reference database (115 best practices).
