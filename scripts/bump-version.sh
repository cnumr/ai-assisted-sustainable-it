#!/usr/bin/env bash
#
# bump-version.sh — synchronise le numéro de version dans tous les manifests.
#
# Usage:
#   bump-version.sh <nouvelle-version>   Bumpe tous les fichiers déclarés
#   bump-version.sh --check              Affiche les versions actuelles (détecte les dérives)
#   bump-version.sh --audit              Check + grep du repo pour les occurrences oubliées
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/.version-bump.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "error: .version-bump.json introuvable à $CONFIG" >&2
  exit 1
fi

# --- helpers ---

read_json_field() {
  local file="$1" field="$2"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./' | sed 's/\.\././g')
  jq -r "$jq_path" "$file"
}

write_json_field() {
  local file="$1" field="$2" value="$3"
  local jq_path
  jq_path=$(echo "$field" | sed -E 's/\.([0-9]+)/[\1]/g' | sed 's/^/./' | sed 's/\.\././g')
  local tmp="${file}.tmp"
  jq "$jq_path = \"$value\"" "$file" > "$tmp" && mv "$tmp" "$file"
}

declared_files() {
  jq -r '.files[] | "\(.path)\t\(.field)"' "$CONFIG"
}

audit_excludes() {
  jq -r '.audit.exclude[]' "$CONFIG" 2>/dev/null
}

# --- commandes ---

cmd_check() {
  local has_drift=0
  local versions=()

  echo "Vérification des versions :"
  echo ""

  while IFS=$'\t' read -r path field; do
    local fullpath="$REPO_ROOT/$path"
    if [[ ! -f "$fullpath" ]]; then
      printf "  %-45s  MANQUANT\n" "$path ($field)"
      has_drift=1
      continue
    fi
    local ver
    ver=$(read_json_field "$fullpath" "$field")
    printf "  %-45s  %s\n" "$path ($field)" "$ver"
    versions+=("$ver")
  done < <(declared_files)

  echo ""

  local unique
  unique=$(printf '%s\n' "${versions[@]}" | sort -u | wc -l | tr -d ' ')
  if [[ "$unique" -gt 1 ]]; then
    echo "DÉRIVE DÉTECTÉE — les versions ne sont pas synchronisées :"
    printf '%s\n' "${versions[@]}" | sort | uniq -c | sort -rn | while read -r count ver; do
      echo "  $ver ($count fichiers)"
    done
    has_drift=1
  else
    echo "Tous les fichiers sont synchronisés à ${versions[0]}"
  fi

  return $has_drift
}

cmd_audit() {
  cmd_check || true
  echo ""

  local current_version
  current_version=$(
    while IFS=$'\t' read -r path field; do
      local fullpath="$REPO_ROOT/$path"
      [[ -f "$fullpath" ]] && read_json_field "$fullpath" "$field"
    done < <(declared_files) | sort | uniq -c | sort -rn | head -1 | awk '{print $2}'
  )

  if [[ -z "$current_version" ]]; then
    echo "error: impossible de déterminer la version courante" >&2
    return 1
  fi

  echo "Audit : recherche de '$current_version' dans le repo..."
  echo ""

  local -a exclude_args=()
  while IFS= read -r pattern; do
    exclude_args+=("--exclude=$pattern" "--exclude-dir=$pattern")
  done < <(audit_excludes)
  exclude_args+=("--exclude-dir=.git" "--exclude-dir=node_modules" "--binary-files=without-match")

  local -a declared_paths=()
  while IFS=$'\t' read -r path _field; do
    declared_paths+=("$path")
  done < <(declared_files)

  local found_undeclared=0
  while IFS= read -r match; do
    local match_file
    match_file=$(echo "$match" | cut -d: -f1)
    local rel_path="${match_file#$REPO_ROOT/}"

    local is_declared=0
    for dp in "${declared_paths[@]}"; do
      if [[ "$rel_path" == "$dp" ]]; then
        is_declared=1
        break
      fi
    done

    if [[ "$is_declared" -eq 0 ]]; then
      if [[ "$found_undeclared" -eq 0 ]]; then
        echo "Fichiers NON DÉCLARÉS contenant '$current_version' :"
        found_undeclared=1
      fi
      echo "  $match"
    fi
  done < <(grep -rn "${exclude_args[@]}" -F "$current_version" "$REPO_ROOT" 2>/dev/null || true)

  if [[ "$found_undeclared" -eq 0 ]]; then
    echo "Aucun fichier non déclaré ne contient la chaîne de version. Tout est bon."
  else
    echo ""
    echo "Vérifiez ces fichiers — s'ils doivent être bumpés, ajoutez-les à .version-bump.json"
  fi
}

cmd_bump() {
  local new_version="$1"

  if ! echo "$new_version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
    echo "error: '$new_version' n'est pas un numéro de version valide (attendu X.Y.Z)" >&2
    exit 1
  fi

  echo "Bump de tous les fichiers déclarés vers $new_version..."
  echo ""

  while IFS=$'\t' read -r path field; do
    local fullpath="$REPO_ROOT/$path"
    if [[ ! -f "$fullpath" ]]; then
      echo "  SKIP (manquant) : $path"
      continue
    fi
    local old_ver
    old_ver=$(read_json_field "$fullpath" "$field")
    write_json_field "$fullpath" "$field" "$new_version"
    printf "  %-45s  %s -> %s\n" "$path ($field)" "$old_ver" "$new_version"
  done < <(declared_files)

  echo ""
  echo "Terminé. Audit pour détecter les fichiers oubliés..."
  echo ""
  cmd_audit
}

# --- main ---

case "${1:-}" in
  --check)
    cmd_check
    ;;
  --audit)
    cmd_audit
    ;;
  --help|-h|"")
    echo "Usage: bump-version.sh <nouvelle-version> | --check | --audit"
    echo ""
    echo "  <nouvelle-version>  Bumpe tous les fichiers déclarés"
    echo "  --check             Affiche les versions actuelles, détecte les dérives"
    echo "  --audit             Check + scan du repo pour les occurrences non déclarées"
    exit 0
    ;;
  --*)
    echo "error: flag inconnu '$1'" >&2
    exit 1
    ;;
  *)
    cmd_bump "$1"
    ;;
esac
