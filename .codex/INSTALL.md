# Installing ai-assisted-sustainable-it for Codex

## Prerequisites

- [Codex CLI](https://github.com/openai/codex) installed
- `mcp-greenit` MCP server configured

## Installation

```bash
git clone https://github.com/hrenaud/ai-assisted-sustainable-it.git ~/.agents/plugins/ai-assisted-sustainable-it
mkdir -p ~/.agents/skills
ln -s ~/.agents/plugins/ai-assisted-sustainable-it/skills/ecocode ~/.agents/skills/ecocode
```

## Usage

```text
/ecocode              # Full Sustainable IT audit
/ecocode front        # Front-end analysis
/ecocode back         # Back-end analysis
```
