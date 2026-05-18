#!/usr/bin/env bash
# Fonctions utilitaires pour les tests de skills Claude Code

# Lance Claude Code avec un prompt et capture la sortie
# Usage: run_claude "prompt" [timeout_secondes] [allowed_tools]
run_claude() {
    local prompt="$1"
    local timeout="${2:-60}"
    local allowed_tools="${3:-}"
    local output_file
    output_file=$(mktemp)

    local cmd="claude -p \"$prompt\""
    if [ -n "$allowed_tools" ]; then
        cmd="$cmd --allowed-tools=$allowed_tools"
    fi

    if timeout "$timeout" bash -c "$cmd" > "$output_file" 2>&1; then
        cat "$output_file"
        rm -f "$output_file"
        return 0
    else
        local exit_code=$?
        cat "$output_file" >&2
        rm -f "$output_file"
        return $exit_code
    fi
}

# Vérifie que la sortie contient un pattern
# Usage: assert_contains "sortie" "pattern" "nom du test"
assert_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if echo "$output" | grep -q "$pattern"; then
        echo "  [PASS] $test_name"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Attendu : $pattern"
        echo "  Dans la sortie :"
        echo "$output" | sed 's/^/    /'
        return 1
    fi
}

# Vérifie que la sortie ne contient PAS un pattern
# Usage: assert_not_contains "sortie" "pattern" "nom du test"
assert_not_contains() {
    local output="$1"
    local pattern="$2"
    local test_name="${3:-test}"

    if echo "$output" | grep -q "$pattern"; then
        echo "  [FAIL] $test_name"
        echo "  Ne devrait pas contenir : $pattern"
        echo "  Dans la sortie :"
        echo "$output" | sed 's/^/    /'
        return 1
    else
        echo "  [PASS] $test_name"
        return 0
    fi
}

# Vérifie le nombre d'occurrences d'un pattern
# Usage: assert_count "sortie" "pattern" nb_attendu "nom du test"
assert_count() {
    local output="$1"
    local pattern="$2"
    local expected="$3"
    local test_name="${4:-test}"

    local actual
    actual=$(echo "$output" | grep -c "$pattern" || echo "0")

    if [ "$actual" -eq "$expected" ]; then
        echo "  [PASS] $test_name ($actual occurrences)"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Attendu $expected occurrences de : $pattern"
        echo "  Trouvé $actual occurrences"
        echo "  Dans la sortie :"
        echo "$output" | sed 's/^/    /'
        return 1
    fi
}

# Vérifie que le pattern A apparaît avant le pattern B
# Usage: assert_order "sortie" "pattern_a" "pattern_b" "nom du test"
assert_order() {
    local output="$1"
    local pattern_a="$2"
    local pattern_b="$3"
    local test_name="${4:-test}"

    local line_a
    line_a=$(echo "$output" | grep -n "$pattern_a" | head -1 | cut -d: -f1)
    local line_b
    line_b=$(echo "$output" | grep -n "$pattern_b" | head -1 | cut -d: -f1)

    if [ -z "$line_a" ]; then
        echo "  [FAIL] $test_name : pattern A non trouvé : $pattern_a"
        return 1
    fi

    if [ -z "$line_b" ]; then
        echo "  [FAIL] $test_name : pattern B non trouvé : $pattern_b"
        return 1
    fi

    if [ "$line_a" -lt "$line_b" ]; then
        echo "  [PASS] $test_name (A ligne $line_a, B ligne $line_b)"
        return 0
    else
        echo "  [FAIL] $test_name"
        echo "  Attendu '$pattern_a' avant '$pattern_b'"
        echo "  Trouvé A ligne $line_a, B ligne $line_b"
        return 1
    fi
}

# Crée un répertoire de projet de test temporaire
# Usage: test_project=$(create_test_project)
create_test_project() {
    mktemp -d
}

# Supprime un répertoire de test
# Usage: cleanup_test_project "$test_dir"
cleanup_test_project() {
    local test_dir="$1"
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
    fi
}

export -f run_claude
export -f assert_contains
export -f assert_not_contains
export -f assert_count
export -f assert_order
export -f create_test_project
export -f cleanup_test_project
