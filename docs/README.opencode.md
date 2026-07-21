# ia-tools pour OpenCode

Guide complet pour utiliser ia-tools avec [OpenCode.ai](https://opencode.ai).

## Installation

Ajouter ia-tools dans le tableau `plugin` de votre `opencode.json` (global ou au niveau du projet) :

```json
{
  "plugin": ["ia-tools@git+https://github.com/novagaia/ia-tools.git"]
}
```

Redémarrer OpenCode. Le plugin s'installe via le gestionnaire de plugins OpenCode et enregistre tous les skills.

Vérifier l'installation en posant : "Quels skills sont disponibles ?"

OpenCode utilise son propre système d'installation. Si vous utilisez aussi Claude Code, Codex ou un autre outil, installez ia-tools séparément pour chacun.

## Utilisation

### Lancer un audit éco-conception

```
Lance un audit éco-conception sur ce projet.
```

```
Analyse uniquement le front-end de ce projet.
```

```
Analyse l'URL https://example.com selon les bonnes pratiques Green IT.
```

### Lancer un audit accessibilité RGAA

```
Lance un audit RGAA sur ce projet.
```

### Trouver les skills disponibles

Utiliser l'outil `skill` natif d'OpenCode pour lister les skills disponibles :

```
utilise l'outil skill pour lister les skills disponibles
```

### Charger un skill manuellement

```
utilise l'outil skill pour charger ecocode
utilise l'outil skill pour charger rgaa
```

## Mise à jour

OpenCode installe ia-tools via une spec git. Certaines versions d'OpenCode et de Bun peuvent mettre en cache la dépendance git résolue, de sorte qu'un redémarrage ne récupère pas toujours la dernière version. Si les mises à jour n'apparaissent pas, vider le cache de packages d'OpenCode ou réinstaller le plugin.

Pour épingler une version spécifique :

```json
{
  "plugin": ["ia-tools@git+https://github.com/novagaia/ia-tools.git#v1.2.0"]
}
```

## Fonctionnement

Le plugin effectue deux actions :

1. **Injecte le contexte bootstrap** via le hook `experimental.chat.messages.transform`, rendant le skill `ecocode` actif dès le début de chaque conversation.
2. **Enregistre le répertoire des skills** via le hook `config`, permettant à OpenCode de découvrir tous les skills sans symlinks ni configuration manuelle.

### Mapping des outils

Les skills écrits pour Claude Code s'adaptent automatiquement à OpenCode :

| Claude Code              | OpenCode                         |
| ------------------------ | -------------------------------- |
| `Agent` avec sous-agents | Système `@mention` d'OpenCode    |
| `Skill` tool             | Outil `skill` natif              |
| `Read`, `Edit`, `Write`  | Outils fichiers natifs           |
| `mcp__greenit__*`        | MCP greenit (même configuration) |

## Dépannage

### Plugin non chargé

1. Vérifier les logs OpenCode : `opencode run --print-logs "bonjour" 2>&1 | grep -i ia-tools`
2. Vérifier que la ligne plugin dans `opencode.json` est correcte
3. S'assurer d'utiliser une version récente d'OpenCode

### Problèmes d'installation sur Windows

Certaines versions Windows d'OpenCode ont des problèmes avec les specs git. Si OpenCode ne parvient pas à installer le plugin, essayer via npm système :

```powershell
npm install ia-tools@git+https://github.com/novagaia/ia-tools.git --prefix "$HOME\.config\opencode"
```

Puis utiliser le chemin local dans `opencode.json` :

```json
{
  "plugin": ["~/.config/opencode/node_modules/ia-tools"]
}
```

### Skills non trouvés

1. Utiliser l'outil `skill` pour lister les skills disponibles
2. Vérifier que le plugin est bien chargé (voir ci-dessus)
3. Chaque skill nécessite un fichier `SKILL.md` avec un frontmatter YAML valide

### Bootstrap non injecté

1. Vérifier que la version d'OpenCode supporte le hook `experimental.chat.messages.transform`
2. Redémarrer OpenCode après tout changement de configuration

## Aide

- Signaler un problème : https://github.com/novagaia/ia-tools/issues
- Documentation principale : https://github.com/novagaia/ia-tools
- Documentation OpenCode : https://opencode.ai/docs/
