#!/usr/bin/env bash
# Test du skill ecocode — vérifie que le skill est accessible et décrit correctement son comportement
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Test : skill ecocode ==="

output=$(run_claude "/ecocode front : explique uniquement, sans lancer d'audit ni modifier de fichier, comment cette commande est routée." 60 "Read")

assert_contains "$output" -i "éco\|eco\|green\|vert" "Mentionne le contexte Green IT"
assert_contains "$output" -i "front\|back\|analyse\|audit" "Mentionne les domaines d'analyse"
assert_contains "$output" "ecocode-orchestrator" "Route /ecocode vers ecocode-orchestrator"

echo "=== Tous les tests passés ==="
