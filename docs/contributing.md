# Guide du contributeur — ia-tools

## Architecture

```
ia-tools/
├── skills/
│   ├── ecocode/            # Skills éco-conception (Claude Code, Cursor, Codex, Gemini)
│   │   ├── SKILL.md        # Orchestrateur principal
│   │   ├── front/SKILL.md  # Analyse front-end
│   │   └── back/SKILL.md   # Analyse back-end
│   └── rgaa/               # Skills accessibilité RGAA
│       └── SKILL.md        # Skill principal
├── agents/                 # Agents Claude Code (modèles courts : sonnet, haiku)
├── commands/               # Slash commands
├── hooks/                  # SessionStart bootstrap
├── .opencode/
│   ├── agents/             # Agents OpenCode (modèles complets : anthropic/claude-*)
│   └── plugins/            # Plugins OpenCode (ecocode.js, rgaa.js)
├── .claude-plugin/         # Manifests Claude Code / marketplace
├── .cursor-plugin/         # Manifests Cursor
├── .codex-plugin/          # Manifests Codex / marketplace
├── .codex/                 # Instructions d'installation Codex
├── docs/                   # Documentation développeur
└── scripts/                # Scripts de maintenance
```

## Ajouter un skill

1. Créer `skills/<outil>/<nom>/SKILL.md` avec le frontmatter requis :
   ```yaml
   ---
   name: <outil>-<nom>
   description: Use when...
   ---
   ```
2. Référencer le sous-skill dans `skills/<outil>/SKILL.md` (tableau de délégation)
3. Si le skill a besoin d'un agent dédié, voir "Ajouter un agent" ci-dessous

## Ajouter un agent

Les agents existent en deux versions incompatibles (noms de modèles différents) :

| Plateforme                   | Répertoire          | Format modèle                 |
| ---------------------------- | ------------------- | ----------------------------- |
| Claude Code / Cursor / Codex | `agents/`           | `sonnet`, `haiku`             |
| OpenCode                     | `.opencode/agents/` | `anthropic/claude-sonnet-4-5` |

**Ne jamais symlier entre ces deux répertoires** — les formats sont incompatibles.

Frontmatter minimal pour `agents/` :

```yaml
---
name: <outil>-<nom>
model: haiku
tools: [Read, Bash]
---
```

Frontmatter minimal pour `.opencode/agents/` :

```yaml
---
name: <outil>-<nom>
model: anthropic/claude-haiku-4-5
mode: subagent
permission:
  edit: deny
---
```

### Permissions agents

| Agent                    | Peut écrire des fichiers ?        |
| ------------------------ | --------------------------------- |
| `ecocode-orchestrator`   | Non                               |
| `ecocode-front-analyzer` | Non                               |
| `ecocode-back-analyzer`  | Non                               |
| `ecocode-fix-suggester`  | Oui, sur confirmation explicite   |
| `rgaa-orchestrator`      | Non                               |
| `rgaa-page-analyzer`     | Non                               |
| `rgaa-reporter`          | Oui, dans `docs/rgaa/audits/`     |
| `rgaa-checklist`         | Oui, dans `docs/rgaa/checklists/` |

## Modifier les hooks

Le hook `hooks/session-start` injecte le contenu de `skills/ecocode/dev-guide/SKILL.md` au démarrage de session. Si le skill racine évolue, le bootstrap suit automatiquement — pas besoin de modifier le hook.

Le hook supporte trois plateformes via détection de variables d'environnement :

- `CURSOR_PLUGIN_ROOT` → Cursor (`additional_context`)
- `CLAUDE_PLUGIN_ROOT` → Claude Code (`hookSpecificOutput.additionalContext`)
- Sinon → OpenCode / Copilot CLI (`additionalContext`)

## Symlinks de développement local

Les symlinks `.claude/` sont gitignorés. Pour les recréer après un clone :

```bash
mkdir -p .claude/skills .claude/agents
ln -s ../../skills/ecocode .claude/skills/ecocode
ln -s ../../skills/rgaa .claude/skills/rgaa
ln -s ../../agents/ecocode-orchestrator.md .claude/agents/ecocode-orchestrator.md
ln -s ../../agents/ecocode-front-analyzer.md .claude/agents/ecocode-front-analyzer.md
ln -s ../../agents/ecocode-back-analyzer.md .claude/agents/ecocode-back-analyzer.md
ln -s ../../agents/ecocode-fix-suggester.md .claude/agents/ecocode-fix-suggester.md
ln -s ../../agents/rgaa-orchestrator.md .claude/agents/rgaa-orchestrator.md
ln -s ../../agents/rgaa-page-analyzer.md .claude/agents/rgaa-page-analyzer.md
ln -s ../../agents/rgaa-reporter.md .claude/agents/rgaa-reporter.md
ln -s ../../agents/rgaa-checklist.md .claude/agents/rgaa-checklist.md
```

## Conventions de commit

Format semantic commit :

```
feat: description courte
fix(front): description courte
docs: description courte
refactor(back): description courte
```

Scopes disponibles : `ecocode`, `rgaa`, `front`, `back`, `agents`, `hooks`, `opencode`, `docs`
