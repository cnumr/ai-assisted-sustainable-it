# Installing ai-assisted-sustainable-it for Codex

## Prerequisites

- [Codex CLI](https://github.com/openai/codex) installed
- `mcp-greenit` MCP server configured

## Installation

```bash
git clone https://github.com/cnumr/ai-assisted-sustainable-it.git ~/.codex/plugins/ai-assisted-sustainable-it
mkdir -p ~/.codex/skills
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/audits ~/.codex/skills/audits
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/design ~/.codex/skills/design
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/development ~/.codex/skills/development
```

## Usage

```text
/ecocode              # Full Sustainable IT audit
/ecocode front        # Front-end analysis
/ecocode back         # Back-end analysis
```
