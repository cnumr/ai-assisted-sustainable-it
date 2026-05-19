# Tester ia-tools

## Prérequis

- Claude Code installé (`claude --version`)
- Plugin activé en mode dev dans `~/.claude/settings.json` :
  ```json
  {
    "enabledPlugins": {
      "ecocode@ia-tools-dev": true,
      "rgaa@ia-tools-dev": true
    }
  }
  ```
- Symlinks `.claude/` en place (voir `docs/contributing.md`)
- MCP `mcp-greenit` configuré

## Suite de tests automatisés

Le répertoire `tests/claude-code/` contient une suite de tests headless. Voir `tests/claude-code/README.md` pour la documentation complète.

```bash
# Lancer tous les tests rapides
./tests/claude-code/run-skill-tests.sh

# Avec sortie détaillée
./tests/claude-code/run-skill-tests.sh --verbose

# Un test spécifique
./tests/claude-code/run-skill-tests.sh --test test-ecocode-bootstrap.sh
```

## Test de la structure multi-outils

```bash
# Vérifier la structure des manifests et fichiers
./tests/structure/test-multi-tool-structure.sh
```

## Test du bootstrap (SessionStart hook)

```bash
# Exécuter le hook manuellement
CLAUDE_PLUGIN_ROOT="$(pwd)" bash hooks/session-start
```

La sortie doit être un JSON avec `hookSpecificOutput.additionalContext` contenant
le contenu de `skills/ecocode/dev-guide/SKILL.md` enveloppé dans `<EXTREMELY_IMPORTANT>`.

## Test des skills

```bash
# Tester ecocode
claude -p "Lance un audit ecocode sur ce projet" --allowedTools all

# Tester rgaa (stub)
claude -p "Décris le skill rgaa" --allowedTools all
```

Vérifier dans la session ecocode que :

- Le skill `ecocode` est chargé automatiquement via le bootstrap
- L'agent `ecocode-orchestrator` est invoqué
- Les sous-agents `ecocode-front-analyzer` et `ecocode-back-analyzer` sont délégués

## Test du versioning

```bash
./scripts/bump-version.sh --check   # Tous les fichiers doivent être à la même version
./scripts/bump-version.sh --audit   # Aucune occurrence non déclarée
```

## Test OpenCode

```bash
# Vérifier que le plugin ecocode JS se charge sans erreur
node --input-type=module <<'EOF'
import { EcocodePlugin } from './.opencode/plugins/ecocode.js';
const plugin = await EcocodePlugin({ client: null, directory: '.' });
console.log('config hook:', typeof plugin.config);
console.log('transform hook:', typeof plugin['experimental.chat.messages.transform']);
EOF

# Vérifier que le plugin rgaa JS se charge sans erreur
node --input-type=module <<'EOF'
import { RgaaPlugin } from './.opencode/plugins/rgaa.js';
const plugin = await RgaaPlugin({ client: null, directory: '.' });
console.log('config hook:', typeof plugin.config);
EOF
```

## Trouver les sessions de test

Les transcripts Claude Code sont dans `~/.claude/projects/` avec le chemin du
répertoire de travail encodé :

```bash
SESSION_DIR="$HOME/.claude/projects/-Users-$(whoami)-DEV-ia-ia-tools"
ls -lt "$SESSION_DIR"/*.jsonl | head -5
```
