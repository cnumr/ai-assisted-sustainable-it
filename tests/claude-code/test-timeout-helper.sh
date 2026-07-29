#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

if PATH="/usr/bin:/bin" run_with_timeout 5 bash -c 'exit 0'; then
  echo "  [PASS] Exécute une commande sans timeout GNU"
else
  echo "  [FAIL] La commande rapide doit réussir sans timeout GNU"
  exit 1
fi

set +e
PATH="/usr/bin:/bin" run_with_timeout 1 bash -c 'sleep 2'
status=$?
set -e

if is_timeout_exit "$status"; then
  echo "  [PASS] Interrompt une commande lente sans timeout GNU"
else
  echo "  [FAIL] Code de sortie de timeout attendu, obtenu : $status"
  exit 1
fi
