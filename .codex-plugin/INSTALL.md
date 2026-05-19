# Installing ia-tools for Codex

## Prerequisites

- Codex CLI installed
- `mcp-greenit` MCP server configured (required for ecocode)
- `mcp-rgaa` MCP server configured (required for rgaa)
- `playwright` MCP server configured (optional — needed for URL analysis)

## Installation

Copy the `.codex-plugin` directory to your Codex config:

```bash
mkdir -p ~/.codex/plugins
cp -r ~/.claude/plugins/ia-tools/.codex-plugin ~/.codex/plugins/ia-tools
```

Or clone directly:

```bash
git clone https://github.com/novagaia/ia-tools ~/.codex/plugins/ia-tools
```

## Usage

The plugin registers skills and tools via `plugin.json` in `.codex-plugin/plugins/`.

### Commands

```
/ecocode                      # Audit éco-conception complet
/ecocode front                # Analyse front-end uniquement
/ecocode back                 # Analyse back-end uniquement
/rgaa https://example.com     # Audit accessibilité RGAA
```

## MCP Configuration

Ensure `mcp-greenit` and `mcp-rgaa` are configured in your Codex MCP settings.
