# Installing ai-assisted-sustainable-it for Codex

## Prerequisites

- Codex CLI installed
- `mcp-greenit` MCP server configured
- `playwright` MCP server configured for `/ecocode frontend` runtime audits (required)

## Installation

```bash
git clone https://github.com/cnumr/ai-assisted-sustainable-it.git ~/.codex/plugins/ai-assisted-sustainable-it
mkdir -p ~/.codex/skills ~/.codex/agents
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/audits ~/.codex/skills/audits
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/design ~/.codex/skills/design
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/development ~/.codex/skills/development
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/.codex/agents/*.toml ~/.codex/agents/
```

## Commands

```text
/ecocode                      # Full Sustainable IT audit
/ecocode front                # Front-end analysis
/ecocode frontend https://example.com
/ecocode frontend parcours.json
/ecocode frontend init
/ecocode back                 # Back-end analysis
```
