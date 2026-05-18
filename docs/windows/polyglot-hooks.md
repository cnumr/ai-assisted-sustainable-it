# Hooks cross-platform — technique polyglotte

Les hooks Claude Code doivent fonctionner sur Windows, macOS et Linux. Ce document explique la technique du wrapper polyglotte utilisée dans ce plugin.

## Le problème

Claude Code exécute les hooks via le shell système :

- **Windows** : CMD.exe
- **macOS/Linux** : bash ou sh

Cela crée plusieurs incompatibilités :

1. **Exécution de scripts** : CMD ne peut pas exécuter les fichiers `.sh` directement
2. **Format des chemins** : Windows utilise `\`, Unix utilise `/`
3. **Variables d'environnement** : la syntaxe `$VAR` ne fonctionne pas dans CMD
4. **bash absent du PATH** : même avec Git Bash installé, `bash` n'est pas dans le PATH de CMD

## La solution : wrapper `.cmd` polyglotte

Un fichier polyglotte est syntaxiquement valide dans plusieurs langages simultanément. Notre wrapper est valide à la fois en CMD et en bash :

```cmd
: << 'CMDBLOCK'
@echo off
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_NAME=%~1"
"C:\Program Files\Git\bin\bash.exe" -l -c "cd \"$(cygpath -u \"%SCRIPT_DIR%\")\" && \"./%SCRIPT_NAME%\""
exit /b
CMDBLOCK

# Unix shell runs from here
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
"${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
```

### Fonctionnement

#### Sous Windows (CMD.exe)

1. `: << 'CMDBLOCK'` — CMD interprète `:` comme un label et ignore `<< 'CMDBLOCK'`
2. `@echo off` — désactive l'écho des commandes
3. `bash.exe` est invoqué avec `-l` (login shell) pour obtenir le PATH Unix correct
4. `cygpath -u` convertit le chemin Windows en format Unix
5. `exit /b` — CMD s'arrête ici, le reste du fichier est ignoré

#### Sous Unix (bash/sh)

1. `: << 'CMDBLOCK'` — `:` est un no-op, `<< 'CMDBLOCK'` démarre un heredoc
2. Tout jusqu'à `CMDBLOCK` est consommé par le heredoc (ignoré)
3. Le script Unix s'exécute directement depuis le chemin natif

## Structure des fichiers

```
hooks/
├── hooks.json           # Pointe vers le wrapper .cmd
├── run-hook.cmd         # Wrapper polyglotte (point d'entrée cross-platform)
└── session-start        # Logique du hook (script bash)
```

### hooks.json

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start"
          }
        ]
      }
    ]
  }
}
```

Le chemin doit être entre guillemets car `${CLAUDE_PLUGIN_ROOT}` peut contenir des espaces sur Windows (ex. `C:\Program Files\...`).

## Prérequis

### Windows

- **Git for Windows** doit être installé (fournit `bash.exe` et `cygpath`)
- Chemin par défaut : `C:\Program Files\Git\bin\bash.exe`
- Si Git est installé ailleurs, modifier le wrapper en conséquence

### Unix (macOS/Linux)

- Bash ou sh standard
- Le fichier `.cmd` doit avoir les permissions d'exécution (`chmod +x`)

## Écrire des scripts bash cross-platform

La logique réelle du hook est dans le fichier `session-start`. Pour qu'elle fonctionne via Git Bash sur Windows :

### À faire

- Utiliser les builtins bash purs quand c'est possible
- Utiliser `$(command)` plutôt que les backticks
- Toujours quoter les expansions de variables : `"$VAR"`
- Utiliser `printf` ou des heredocs pour les sorties

### À éviter

- Les commandes externes susceptibles d'être absentes du PATH (`sed`, `awk`, `grep`)
- Si nécessaire, elles sont disponibles dans Git Bash — s'assurer que le PATH est chargé (utiliser `bash -l`)

### Échappement JSON sans sed/awk

Notre hook `session-start` utilise une fonction bash pure pour l'échappement JSON, compatible avec Git Bash sur Windows :

```bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\\\' ;;
            '"')   output+='\\"' ;;
            $'\n') output+='\\n' ;;
            $'\r') output+='\\r' ;;
            $'\t') output+='\\t' ;;
            *)     output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}
```

## Dépannage

### "bash is not recognized"

CMD ne trouve pas bash. Le wrapper utilise le chemin complet `C:\Program Files\Git\bin\bash.exe`. Si Git est installé ailleurs, mettre à jour ce chemin.

### "cygpath: command not found"

Bash ne tourne pas en login shell. Vérifier que le flag `-l` est bien présent.

### Le script s'ouvre dans un éditeur de texte

`hooks.json` pointe directement vers le `.sh`. Pointer vers le wrapper `.cmd` à la place.

### Fonctionne dans le terminal mais pas en hook

Simuler l'environnement du hook pour tester :

```powershell
$env:CLAUDE_PLUGIN_ROOT = "C:\chemin\vers\le\plugin"
cmd /c "C:\chemin\vers\le\plugin\hooks\run-hook.cmd session-start"
```

## Références

- [anthropics/claude-code#9758](https://github.com/anthropics/claude-code/issues/9758) — les scripts .sh s'ouvrent dans un éditeur sur Windows
- [anthropics/claude-code#3417](https://github.com/anthropics/claude-code/issues/3417) — les hooks ne fonctionnent pas sur Windows
