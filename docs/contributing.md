# Guide du contributeur — ai-assisted-sustainable-it

## Architecture

```text
ai-assisted-sustainable-it/
├── skills/ecocode/          # Skill et sous-skills éco-conception
├── agents/                  # Agents Claude Code, Cursor et Codex
├── commands/ecocode.md      # Slash command
├── hooks/                   # Bootstrap SessionStart
├── .opencode/               # Agents, commande et plugin OpenCode
├── .claude-plugin/          # Marketplace Claude Code
├── .cursor-plugin/          # Manifest Cursor
├── .codex-plugin/           # Marketplace Codex
├── docs/                    # Documentation développeur
└── scripts/                 # Maintenance des versions
```

## Ajouter un sous-skill ou un agent

1. Créer le fichier dans `skills/ecocode/` ou `agents/`.
2. Le référencer dans `skills/ecocode/SKILL.md` lorsque nécessaire.
3. Ajouter les tests de structure ou de comportement correspondants.

Les agents OpenCode sont dans `.opencode/agents/` : leurs noms de modèles et
leur frontmatter diffèrent de ceux dans `agents/`.

## Symlinks de développement local

```bash
mkdir -p .claude/skills .claude/agents
ln -s ../../skills/ecocode .claude/skills/ecocode
ln -s ../../agents/ecocode-orchestrator.md .claude/agents/ecocode-orchestrator.md
ln -s ../../agents/ecocode-front-analyzer.md .claude/agents/ecocode-front-analyzer.md
ln -s ../../agents/ecocode-back-analyzer.md .claude/agents/ecocode-back-analyzer.md
ln -s ../../agents/ecocode-fix-suggester.md .claude/agents/ecocode-fix-suggester.md
```

## Conventions de commit

Utiliser les commits conventionnels, par exemple `feat: add audit rule` ou
`fix(ecocode): correct cache guidance`.
