#!/usr/bin/env bash
# Test du skill ecocode — vérifie que le skill est accessible et décrit correctement son comportement
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

echo "=== Test : skill ecocode ==="

output=$(run_claude "/ecocode front : lance un audit et décris brièvement les agents utilisés." 60)

assert_contains "$output" -i "éco\|eco\|green\|vert" "Mentionne le contexte Green IT"
assert_contains "$output" -i "front\|back\|analyse\|audit" "Mentionne les domaines d'analyse"
assert_contains "$output" -i "ecocode-orchestrator\|orchestrat" "Route /ecocode vers l'orchestrateur"

echo "=== Tous les tests passés ==="
