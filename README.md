# ia-tools

Suite d'outils qualité web pour Claude Code, OpenCode, Cursor, Gemini et Codex — audit ponctuel **et** application continue des bonnes pratiques pendant le développement.

- **Éco-conception web** : audit + application automatique des [115 bonnes pratiques Green IT](https://github.com/cnumr/best-practices) pendant que le code s'écrit
- **Accessibilité** : audit RGAA 4.2.1

## Outils disponibles

| Outil     | Description                                                        | Statut |
| --------- | ------------------------------------------------------------------ | ------ |
| `ecocode` | Audit + application continue en dev, 115 bonnes pratiques Green IT | Stable |
| `rgaa`    | Audit accessibilité RGAA 4.2.1                                     | Beta   |

## Mode conception et développement passif

`ecocode` ne se limite pas à l'audit sur demande. À chaque démarrage de session, il injecte automatiquement un guide compact de règles d'éco-conception. Claude les applique quand il conçoit, écrit ou modifie une solution — sans qu'on ait à appeler `/ecocode`.

Les règles couvrent :

| Couche    | Thèmes                                                                     |
| --------- | -------------------------------------------------------------------------- |
| Conception | Besoin minimal, parcours, données, compatibilité, dépendances             |
| Front-end | Lazy-loading, imports ciblés, CSS > JS, batch DOM, délégation d'événements |
| Back-end  | Async, cache, batch queries, types DB, TTL données                         |
| Build     | Cache-Control, minification                                                |

Ce mode est actif par défaut et complémentaire aux audits explicites via `/ecocode`.

## Prérequis

- MCP `mcp-greenit` — accès au référentiel Green IT officiel (requis pour ecocode)
- MCP `mcp-rgaa` — accès au référentiel RGAA 4.2.1 (requis pour rgaa)
- MCP `playwright` — analyse d'URLs en runtime (optionnel)

## Skills

| Skill           | Description                                                                     |
| --------------- | ------------------------------------------------------------------------------- |
| `ecocode`       | Orchestration principale : identifie le périmètre, délègue, produit le rapport  |
| `ecocode/front` | Analyse front-end : assets, JS, CSS, HTTP, DOM, cache, build                    |
| `ecocode/back`  | Analyse back-end : BDD, cache serveur, API, workers, infrastructure             |
| `rgaa`          | Audit accessibilité RGAA 4.2.1 : analyse par page, rapport + checklist manuelle |

## Agents

| Agent                    | Outil   | Rôle                                 | Permissions               |
| ------------------------ | ------- | ------------------------------------ | ------------------------- |
| `ecocode-orchestrator`   | ecocode | Coordonne l'audit complet            | Lecture seule             |
| `ecocode-front-analyzer` | ecocode | Analyse le code client               | Lecture seule             |
| `ecocode-back-analyzer`  | ecocode | Analyse le code serveur              | Lecture seule             |
| `ecocode-report-writer`  | ecocode | Écrit les fichiers d'audit           | Écriture sur docs/        |
| `ecocode-planner`        | ecocode | Génère le plan d'action priorisé     | Écriture sur docs/        |
| `ecocode-fix-suggester`  | ecocode | Propose et applique les corrections  | Écriture sur confirmation |
| `rgaa-orchestrator`      | rgaa    | Coordonne l'audit RGAA               | Lecture seule             |
| `rgaa-page-analyzer`     | rgaa    | Analyse une page (statuts C/NC/NA/⚠) | Lecture seule             |
| `rgaa-reporter`          | rgaa    | Écrit le rapport d'audit horodaté    | Écriture sur docs/        |
| `rgaa-checklist`         | rgaa    | Génère la checklist manuelle         | Écriture sur docs/        |

## Utilisation

```
/ecocode                      # Audit complet du projet courant
/ecocode front                # Analyse front-end uniquement
/ecocode back                 # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)
/ecocode plan                 # Plan d'action depuis le dernier audit (sans re-analyser)
/ecocode fix                  # Correction guidée depuis le dernier audit
/ecocode fix RWEB_042         # Correction ciblée sur une pratique spécifique

/rgaa https://example.com                           # Audit RGAA d'une page
/rgaa https://example.com https://example.com/page  # Échantillon multi-pages
```

### Modes d'exécution

En début d'audit, le plugin demande le mode souhaité :

| Mode           | Comportement                                                                                                 |
| -------------- | ------------------------------------------------------------------------------------------------------------ |
| **auto**       | Enchaîne sans interruption : analyse → fichiers d'audit → plan d'action. Résumé des fichiers créés à la fin. |
| **interactif** | Demande confirmation avant d'écrire les fichiers d'audit, puis avant de générer le plan d'action.            |

Les deux modes génèrent les mêmes fichiers dans `docs/ecocode/audits/` et `docs/ecocode/plans/`.

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
# Installe les outils via le marketplace Claude Code
/plugin marketplace add <owner>/ia-tools
```

Ou manuellement :

```bash
git clone https://github.com/novagaia/ia-tools ~/.claude/plugins/ia-tools
ln -s ~/.claude/plugins/ia-tools/skills/ecocode ~/.claude/skills/ecocode
ln -s ~/.claude/plugins/ia-tools/agents/ecocode-*.md ~/.claude/agents/
```

### CLI

```bash
npx skills add <owner>/ia-tools
# La CLI liste les outils disponibles et demande lequel installer
```

### OpenCode

```json
{
  "plugins": ["ia-tools@git+https://github.com/novagaia/ia-tools.git"]
}
```

Voir [`.opencode/INSTALL.md`](.opencode/INSTALL.md) pour les détails.

### Cursor, Gemini, Codex

Les fichiers de configuration auto-détectés (`.cursor-plugin/plugin.json`, `gemini-extension.json`, `.codex/INSTALL.md`) définissent l'intégration avec chaque plateforme.
