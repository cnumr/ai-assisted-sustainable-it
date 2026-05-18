#!/usr/bin/env bash
# Test du bootstrap SessionStart — vérifie que le hook injecte le skill correctement
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== Test : bootstrap SessionStart ==="

output=$(CLAUDE_PLUGIN_ROOT="$REPO_ROOT" bash "$REPO_ROOT/hooks/session-start" 2>&1)

if echo "$output" | python3 -c "import sys,json; d=json.load(sys.stdin); assert 'hookSpecificOutput' in d" 2>/dev/null; then
    echo "  [PASS] JSON valide avec hookSpecificOutput"
else
    echo "  [FAIL] Sortie JSON invalide ou champ manquant"
    echo "  Sortie :"
    echo "$output" | sed 's/^/    /'
    exit 1
fi

if echo "$output" | python3 -c "import sys,json; d=json.load(sys.stdin); ctx=d['hookSpecificOutput']['additionalContext']; assert 'EXTREMELY_IMPORTANT' in ctx" 2>/dev/null; then
    echo "  [PASS] additionalContext contient EXTREMELY_IMPORTANT"
else
    echo "  [FAIL] additionalContext manquant ou sans EXTREMELY_IMPORTANT"
    echo "  Sortie :"
    echo "$output" | sed 's/^/    /'
    exit 1
fi

if echo "$output" | python3 -c "import sys,json; d=json.load(sys.stdin); ctx=d['hookSpecificOutput']['additionalContext']; assert 'ecocode' in ctx.lower()" 2>/dev/null; then
    echo "  [PASS] Contenu du skill présent dans le bootstrap"
else
    echo "  [FAIL] Contenu du skill absent du bootstrap"
    exit 1
fi

echo "=== Tous les tests passés ==="
