# Installing ai-assisted-sustainable-it for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed
- `mcp-greenit` MCP server configured
- `playwright` MCP server configured for `/ecocode frontend` runtime audits (required)

## Installation

Add the plugin to `opencode.json`:

```json
{
  "plugin": ["ai-assisted-sustainable-it@git+https://github.com/cnumr/ai-assisted-sustainable-it.git"]
}
```

## Usage

```text
use skill tool to load audits
use skill tool to load audits/front
use skill tool to load audits/back

/ecocode              # Full Sustainable IT audit
/ecocode front        # Front-end analysis
/ecocode frontend     # Runtime front-end journey audit (requires playwright)
/ecocode back         # Back-end analysis
```
