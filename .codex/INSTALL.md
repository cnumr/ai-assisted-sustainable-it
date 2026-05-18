# Installing Ecocode for Codex

## Prerequisites

- [Codex CLI](https://github.com/openai/codex) installed
- `mcp-greenit` MCP server configured (required)

## Installation

```bash
# Clone the plugin
git clone https://github.com/your-org/ecocode-plugin ~/.agents/plugins/ecocode

# Symlink the skill
mkdir -p ~/.agents/skills
ln -s ~/.agents/plugins/ecocode/skills/ecocode ~/.agents/skills/ecocode
```

## Usage

The skill is auto-discovered from `~/.agents/skills/`. Use it via the `skill` tool
or reference it in your prompts:

```
/ecocode              # Audit complet
/ecocode front        # Analyse front-end uniquement
/ecocode back         # Analyse back-end uniquement
```

## Agents

Codex uses the shared `AGENTS.md` / `CLAUDE.md` for project-level context.
Agent definitions are in `agents/` and can be referenced by name.

## Updating

```bash
cd ~/.agents/plugins/ecocode
git pull
```
