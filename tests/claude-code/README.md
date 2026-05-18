# Tests Claude Code — EcoCode

Tests automatisés pour les skills EcoCode, utilisant Claude Code CLI en mode headless.

## Prérequis

- Claude Code CLI installé et dans le PATH (`claude --version`)
- Plugin EcoCode installé localement (voir `docs/contributing.md`)
- `python3` disponible (pour les assertions JSON du test bootstrap)

## Lancer les tests

```bash
# Tous les tests rapides
./run-skill-tests.sh

# Avec sortie détaillée
./run-skill-tests.sh --verbose

# Un test spécifique
./run-skill-tests.sh --test test-ecocode-bootstrap.sh

# Timeout personnalisé (défaut : 5 minutes)
./run-skill-tests.sh --timeout 120
```

## Tests disponibles

### Tests rapides (lancés par défaut)

#### `test-ecocode-bootstrap.sh`

Vérifie que le hook `SessionStart` fonctionne correctement (~5 secondes) :

- Sortie JSON valide
- Présence du champ `hookSpecificOutput.additionalContext`
- Contenu du skill `ecocode` présent dans le bootstrap

#### `test-ecocode-skill.sh`

Vérifie que Claude peut décrire le skill ecocode (~1 minute) :

- Mentionne le contexte Green IT
- Mentionne les domaines d'analyse (front/back)
- Mentionne le système d'agents

## Ajouter un test

1. Créer `test-<nom>.sh` dans ce répertoire
2. Sourcer `test-helpers.sh` en début de fichier
3. Utiliser `run_claude` et les fonctions `assert_*`
4. Ajouter le nom du fichier dans le tableau `tests` de `run-skill-tests.sh`
5. Rendre le fichier exécutable : `chmod +x test-<nom>.sh`

### Exemple minimal

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Test : mon skill ==="

output=$(run_claude "Décris le skill ecocode/front" 60)

assert_contains "$output" "front-end" "Mentionne l'analyse front-end"

echo "=== Tous les tests passés ==="
```

## CI/CD

```bash
# Avec timeout explicite pour les environnements CI
./run-skill-tests.sh --timeout 600

# Code de sortie : 0 = succès, non-zéro = échec
```
