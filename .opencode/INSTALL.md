# Installing ai-assisted-sustainable-it for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed
- `mcp-greenit` MCP server configured
- `playwright` MCP server configured for URL analysis (optional)

## Installation

Add the plugin to `opencode.json`:

```json
{
  "plugin": ["ai-assisted-sustainable-it@git+https://github.com/hrenaud/ai-assisted-sustainable-it.git"]
}
```

## Usage

```text
use skill tool to load ecocode
use skill tool to load ecocode/front
use skill tool to load ecocode/back

/ecocode              # Full Sustainable IT audit
/ecocode front        # Front-end analysis
/ecocode back         # Back-end analysis
```
