# Tester ai-assisted-sustainable-it

## Tests de structure et de release

```bash
bash tests/structure/test-sustainable-it-structure.sh
bash tests/structure/test-release-metadata.sh
./scripts/bump-version.sh --audit
```

## Tests Claude Code

```bash
./tests/claude-code/run-skill-tests.sh
./tests/claude-code/run-skill-tests.sh --verbose
./tests/claude-code/run-skill-tests.sh --test test-ecocode-bootstrap.sh
```

## Test du bootstrap

```bash
CLAUDE_PLUGIN_ROOT="$(pwd)" bash hooks/session-start
```

La sortie est un JSON contenant les guides `skills/design/SKILL.md` et
`skills/development/SKILL.md`.

## Test OpenCode

```bash
node --input-type=module <<'EOF'
import { EcocodePlugin } from './.opencode/plugins/ecocode.js';
const plugin = await EcocodePlugin({ client: null, directory: '.' });
console.log(typeof plugin.config);
console.log(typeof plugin['experimental.chat.messages.transform']);
EOF
```
