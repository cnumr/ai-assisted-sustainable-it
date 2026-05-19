# Installing ia-tools for Codex

## Prerequisites

- [Codex CLI](https://github.com/openai/codex) installed
- `mcp-greenit` MCP server configured (required for ecocode)
- `mcp-rgaa` MCP server configured (required for rgaa)

## Installation

```bash
# Clone the repo
git clone https://github.com/novagaia/ia-tools ~/.agents/plugins/ia-tools

# Symlink the skills you want
mkdir -p ~/.agents/skills
ln -s ~/.agents/plugins/ia-tools/skills/ecocode ~/.agents/skills/ecocode
ln -s ~/.agents/plugins/ia-tools/skills/rgaa ~/.agents/skills/rgaa
```

## Usage

Skills are auto-discovered from `~/.agents/skills/`. Use them via the `skill` tool
or reference them in your prompts:

```
/ecocode              # Audit éco-conception complet
/ecocode front        # Analyse front-end uniquement
/ecocode back         # Analyse back-end uniquement

/rgaa https://example.com  # Audit accessibilité RGAA d'une page
```

## Agents

Codex uses the shared `AGENTS.md` / `CLAUDE.md` for project-level context.
Agent definitions are in `agents/` and can be referenced by name.

## Updating

```bash
cd ~/.agents/plugins/ia-tools
git pull
```
