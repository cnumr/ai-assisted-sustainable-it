# Installing Ecocode for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed
- `mcp-greenit` MCP server configured (required)
- `playwright` MCP server configured (optional — needed for URL analysis)

## Installation

Add ecocode to the `plugin` array in your `opencode.json`:

```json
{
  "plugin": ["ecocode@git+https://github.com/your-org/ecocode-plugin.git"]
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
```

Or use slash commands:

```
/ecocode              # Audit complet
/ecocode front        # Analyse front-end uniquement
/ecocode back         # Analyse back-end uniquement
```

## Agents

The plugin registers four agents:

| Agent                    | Rôle                                                   |
| ------------------------ | ------------------------------------------------------ |
| `ecocode-orchestrator`   | Coordonne l'audit complet                              |
| `ecocode-front-analyzer` | Analyse le code client (lecture seule)                 |
| `ecocode-back-analyzer`  | Analyse le code serveur (lecture seule)                |
| `ecocode-fix-suggester`  | Propose et applique les corrections (sur confirmation) |

## MCP Configuration

Ensure `mcp-greenit` is configured in your OpenCode MCP settings to access
the Green IT reference database (115 best practices).
