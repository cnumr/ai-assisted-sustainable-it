# Installing ai-assisted-sustainable-it for Codex

## Prerequisites

- Codex CLI installed
- `mcp-greenit` MCP server configured
- `playwright` MCP server configured for URL analysis (optional)

## Installation

```bash
git clone https://github.com/cnumr/ai-assisted-sustainable-it.git ~/.codex/plugins/ai-assisted-sustainable-it
mkdir -p ~/.codex/skills
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/audits ~/.codex/skills/audits
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/design ~/.codex/skills/design
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/development ~/.codex/skills/development
```

## Commands

```text
/ecocode                      # Full Sustainable IT audit
/ecocode front                # Front-end analysis
/ecocode back                 # Back-end analysis
```
