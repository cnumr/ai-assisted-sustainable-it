# Ecocode Plugin

Plugin d'audit éco-conception web basé sur les [115 bonnes pratiques Green IT](https://github.com/cnumr/best-practices).
Compatible Claude Code, OpenCode, Cursor, Gemini et Codex.

## Prérequis

- MCP `mcp-greenit` — accès au référentiel Green IT officiel (requis)
- MCP `playwright` — analyse d'URLs en runtime (optionnel)

## Skills

| Skill           | Description                                                                    |
| --------------- | ------------------------------------------------------------------------------ |
| `ecocode`       | Orchestration principale : identifie le périmètre, délègue, produit le rapport |
| `ecocode/front` | Analyse front-end : assets, JS, CSS, HTTP, DOM, cache, build                   |
| `ecocode/back`  | Analyse back-end : BDD, cache serveur, API, workers, infrastructure            |

## Agents

| Agent                    | Rôle                                | Permissions               |
| ------------------------ | ----------------------------------- | ------------------------- |
| `ecocode-orchestrator`   | Coordonne l'audit complet           | Lecture seule             |
| `ecocode-front-analyzer` | Analyse le code client              | Lecture seule             |
| `ecocode-back-analyzer`  | Analyse le code serveur             | Lecture seule             |
| `ecocode-report-writer`  | Écrit les fichiers d'audit          | Écriture sur docs/        |
| `ecocode-planner`        | Génère le plan d'action priorisé    | Écriture sur docs/        |
| `ecocode-fix-suggester`  | Propose et applique les corrections | Écriture sur confirmation |

## Utilisation

```
/ecocode                      # Audit complet du projet courant
/ecocode front                # Analyse front-end uniquement
/ecocode back                 # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)
/ecocode plan                 # Plan d'action depuis le dernier audit (sans re-analyser)
/ecocode fix                  # Correction guidée depuis le dernier audit
/ecocode fix RWEB_042         # Correction ciblée sur une pratique spécifique
```

### Modes d'exécution

En début d'audit, le plugin demande le mode souhaité :

| Mode           | Comportement                                                                                                 |
| -------------- | ------------------------------------------------------------------------------------------------------------ |
| **auto**       | Enchaîne sans interruption : analyse → fichiers d'audit → plan d'action. Résumé des fichiers créés à la fin. |
| **interactif** | Demande confirmation avant d'écrire les fichiers d'audit, puis avant de générer le plan d'action.            |

Les deux modes génèrent les mêmes fichiers dans `docs/ecocode/audits/` et `docs/ecocode/plans/`.

### Mode développement passif

À chaque démarrage de session, le plugin injecte automatiquement un guide compact de 19 règles d'éco-conception. Claude les applique en écrivant du code — sans qu'on ait à appeler `/ecocode`.

Les règles couvrent :

| Couche    | Thèmes                                                                     |
| --------- | -------------------------------------------------------------------------- |
| Front-end | Lazy-loading, imports ciblés, CSS > JS, batch DOM, délégation d'événements |
| Back-end  | Async, cache, batch queries, types DB, TTL données                         |
| Build     | Cache-Control, minification                                                |

Ce mode est actif par défaut. Il est complémentaire aux audits explicites via `/ecocode`.

### Reprise d'audit

Quand des fichiers d'audit existent dans `docs/ecocode/audits/`, le plugin le détecte automatiquement et propose de reprendre depuis le dernier audit plutôt que de relancer l'analyse complète.

| Sous-commande           | Action                                                            |
| ----------------------- | ----------------------------------------------------------------- |
| `/ecocode`              | Détecte les audits existants et propose reprendre ou nouvel audit |
| `/ecocode plan`         | Génère le plan d'action depuis le dernier audit sans re-analyser  |
| `/ecocode fix`          | Liste les problèmes et propose une correction guidée              |
| `/ecocode fix RWEB_XXX` | Correction ciblée sur la pratique identifiée par son code         |

## Installation

### Claude Code

```bash
git clone https://github.com/your-org/ecocode-plugin ~/.claude/plugins/ecocode
ln -s ~/.claude/plugins/ecocode/skills/ecocode ~/.claude/skills/ecocode
ln -s ~/.claude/plugins/ecocode/agents/ecocode-orchestrator.md ~/.claude/agents/ecocode-orchestrator.md
ln -s ~/.claude/plugins/ecocode/agents/ecocode-front-analyzer.md ~/.claude/agents/ecocode-front-analyzer.md
ln -s ~/.claude/plugins/ecocode/agents/ecocode-back-analyzer.md ~/.claude/agents/ecocode-back-analyzer.md
ln -s ~/.claude/plugins/ecocode/agents/ecocode-fix-suggester.md ~/.claude/agents/ecocode-fix-suggester.md
```

### OpenCode

```json
{
  "plugin": ["ecocode@git+https://github.com/your-org/ecocode-plugin.git"]
}
```

Voir [`.opencode/INSTALL.md`](.opencode/INSTALL.md) pour les détails.

### Cursor

Ajouter le dépôt dans les sources de plugins Cursor. Le fichier `.cursor-plugin/plugin.json` est auto-détecté.

### Gemini

Le fichier `gemini-extension.json` et `GEMINI.md` sont auto-détectés par Gemini CLI.

### Codex

Voir [`.codex/INSTALL.md`](.codex/INSTALL.md) pour les détails.
