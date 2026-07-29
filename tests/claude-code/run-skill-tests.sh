#!/usr/bin/env bash
# Runner de tests pour les skills EcoCode
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"
source "$SCRIPT_DIR/test-helpers.sh"

echo "========================================"
echo " EcoCode — Suite de tests"
echo "========================================"
echo ""
echo "Dépôt : $(cd ../.. && pwd)"
echo "Date   : $(date)"
echo "Claude : $(claude --version 2>/dev/null || echo 'non trouvé')"
echo ""

if ! command -v claude &> /dev/null; then
    echo "ERREUR : Claude Code CLI introuvable"
    echo "Installer Claude Code : https://code.claude.com"
    exit 1
fi

VERBOSE=false
SPECIFIC_TEST=""
TIMEOUT=300
RUN_INTEGRATION=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --test|-t)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --integration|-i)
            RUN_INTEGRATION=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options :"
            echo "  --verbose, -v        Afficher la sortie complète"
            echo "  --test, -t NOM       Exécuter uniquement le test spécifié"
            echo "  --timeout SECONDES   Timeout par test (défaut : 300)"
            echo "  --integration, -i    Exécuter les tests d'intégration (lents)"
            echo "  --help, -h           Afficher cette aide"
            exit 0
            ;;
        *)
            echo "Option inconnue : $1"
            echo "Utiliser --help pour l'aide"
            exit 1
            ;;
    esac
done

# Tests rapides (lancés par défaut)
tests=(
    "test-timeout-helper.sh"
    "test-ecocode-bootstrap.sh"
    "test-ecocode-skill.sh"
)

# Tests d'intégration (lents)
integration_tests=()

if [ "$RUN_INTEGRATION" = true ]; then
    tests+=("${integration_tests[@]}")
fi

if [ -n "$SPECIFIC_TEST" ]; then
    tests=("$SPECIFIC_TEST")
fi

passed=0
failed=0
skipped=0

for test in "${tests[@]}"; do
    echo "----------------------------------------"
    echo "Test : $test"
    echo "----------------------------------------"

    test_path="$SCRIPT_DIR/$test"

    if [ ! -f "$test_path" ]; then
        echo "  [SKIP] Fichier introuvable : $test"
        skipped=$((skipped + 1))
        continue
    fi

    if [ ! -x "$test_path" ]; then
        chmod +x "$test_path"
    fi

    start_time=$(date +%s)

    if [ "$VERBOSE" = true ]; then
        if run_with_timeout "$TIMEOUT" bash "$test_path"; then
            end_time=$(date +%s)
            echo ""
            echo "  [PASS] $test ($((end_time - start_time))s)"
            passed=$((passed + 1))
        else
            exit_code=$?
            end_time=$(date +%s)
            echo ""
            if is_timeout_exit "$exit_code"; then
                echo "  [FAIL] $test (timeout après ${TIMEOUT}s)"
            else
                echo "  [FAIL] $test ($((end_time - start_time))s)"
            fi
            failed=$((failed + 1))
        fi
    else
        if output=$(run_with_timeout "$TIMEOUT" bash "$test_path" 2>&1); then
            end_time=$(date +%s)
            echo "  [PASS] ($((end_time - start_time))s)"
            passed=$((passed + 1))
        else
            exit_code=$?
            end_time=$(date +%s)
            if is_timeout_exit "$exit_code"; then
                echo "  [FAIL] (timeout après ${TIMEOUT}s)"
            else
                echo "  [FAIL] ($((end_time - start_time))s)"
            fi
            echo ""
            echo "  Sortie :"
            echo "$output" | sed 's/^/    /'
            failed=$((failed + 1))
        fi
    fi

    echo ""
done

echo "========================================"
echo " Résultats"
echo "========================================"
echo ""
echo "  Passés  : $passed"
echo "  Échoués : $failed"
echo "  Ignorés : $skipped"
echo ""

if [ $failed -gt 0 ]; then
    echo "STATUT : ÉCHEC"
    exit 1
else
    echo "STATUT : OK"
    exit 0
fi
