# Spec : Repo multi-outils (ecocode + rgaa)

**Date :** 2026-05-19  
**Statut :** Validé

## Contexte

Le repo `ia-tools` héberge actuellement un seul outil (ecocode). L'objectif est de le refactoriser pour accueillir plusieurs outils indépendants (ecocode + rgaa dans un premier temps) tout en permettant à l'utilisateur de choisir lequel installer, via deux canaux natifs :

1. **GitHub URL → assistant IA** (`/plugin marketplace add owner/ia-tools`)
2. **CLI Vercel** (`npx skills add owner/ia-tools`)

## Décisions de design

- **Structure flat avec namespacing par préfixe** : `skills/`, `agents/`, `commands/` sont partagés ; chaque outil préfixe ses fichiers (`ecocode-*`, `rgaa-*`)
- **Pas de `tools.json` custom** : les standards natifs existants suffisent (`marketplace.json` pour Claude Code/Codex, scan auto de `skills/` pour Vercel)
- **Manifestes par plateforme dans des sous-dossiers** : `.claude-plugin/plugins/<outil>/plugin.json`
- **Hooks partagés** : s'appliquent à la session, pas à un outil spécifique

## Structure cible

```
ia-tools/
├── .claude-plugin/
│   ├── marketplace.json              ← liste les 2 plugins
│   └── plugins/
│       ├── ecocode/plugin.json
│       └── rgaa/plugin.json
│
├── .codex-plugin/
│   ├── marketplace.json
│   └── plugins/
│       ├── ecocode/plugin.json
│       └── rgaa/plugin.json
│
├── .cursor-plugin/
│   └── plugins/
│       ├── ecocode/plugin.json
│       └── rgaa/plugin.json
│
├── .opencode/
│   └── plugins/
│       ├── ecocode.js
│       └── rgaa.js
│
├── skills/
│   ├── ecocode/SKILL.md
│   └── rgaa/SKILL.md
│
├── agents/
│   ├── ecocode-orchestrator.md
│   ├── ecocode-front-analyzer.md
│   ├── ecocode-back-analyzer.md
│   ├── ecocode-report-writer.md
│   ├── ecocode-planner.md
│   ├── ecocode-fix-suggester.md
│   ├── rgaa-auditor.md
│   └── rgaa-reporter.md
│
├── commands/
│   ├── ecocode.md
│   └── rgaa.md
│
└── hooks/                            ← partagé
    └── hooks.json
```

## Manifests

### `.claude-plugin/marketplace.json`

```json
{
  "name": "ia-tools",
  "description": "Outils d'audit qualité web : éco-conception et accessibilité",
  "owner": { "name": "Renaud Heluin", "email": "renaud.heluin@novagaia.fr" },
  "plugins": [
    {
      "name": "ecocode",
      "description": "Audit éco-conception web, 115 bonnes pratiques Green IT",
      "source": "./.claude-plugin/plugins/ecocode",
      "category": "development",
      "version": "1.0.0",
      "author": {
        "name": "Renaud Heluin",
        "email": "renaud.heluin@novagaia.fr"
      }
    },
    {
      "name": "rgaa",
      "description": "Audit accessibilité RGAA 4.2.1",
      "source": "./.claude-plugin/plugins/rgaa",
      "category": "development",
      "version": "1.0.0",
      "author": {
        "name": "Renaud Heluin",
        "email": "renaud.heluin@novagaia.fr"
      }
    }
  ]
}
```

### `skills/rgaa/SKILL.md` (frontmatter)

```yaml
---
name: rgaa
description: Conduit un audit accessibilité RGAA 4.2.1 complet. Utiliser quand
  on demande un audit accessibilité, une analyse RGAA, ou une revue a11y.
license: MIT
metadata:
  author: Renaud Heluin
  version: "1.0"
---
```

## Mécanisme de sélection par canal

| Canal            | Commande                                 | Sélection                     |
| ---------------- | ---------------------------------------- | ----------------------------- |
| Claude Code      | `/plugin marketplace add owner/ia-tools` | Natif via `marketplace.json`  |
| Codex            | `/plugin marketplace add owner/ia-tools` | Natif via `marketplace.json`  |
| `npx skills add` | `npx skills add owner/ia-tools`          | Natif, scan auto de `skills/` |
| OpenCode         | Config manuelle                          | README                        |
| Cursor           | Install manuel                           | README                        |

## Migration depuis l'état actuel

### Ce qui se déplace (sans réécriture)

| Avant                        | Après                                        |
| ---------------------------- | -------------------------------------------- |
| `.claude-plugin/plugin.json` | `.claude-plugin/plugins/ecocode/plugin.json` |
| `.codex-plugin/plugin.json`  | `.codex-plugin/plugins/ecocode/plugin.json`  |
| `.cursor-plugin/plugin.json` | `.cursor-plugin/plugins/ecocode/plugin.json` |

### Ce qui reste en place

- `skills/ecocode/SKILL.md`
- `agents/ecocode-*.md`
- `commands/ecocode.md`
- `hooks/`
- `tests/`
- `.opencode/plugins/ecocode.js`

### Ce qui est créé (contenu rgaa — hors scope de la refacto)

- `.claude-plugin/plugins/rgaa/plugin.json`
- `.codex-plugin/plugins/rgaa/plugin.json`
- `skills/rgaa/SKILL.md`
- `agents/rgaa-auditor.md`, `agents/rgaa-reporter.md`
- `commands/rgaa.md`
- `.opencode/plugins/rgaa.js`

### Chemins relatifs à mettre à jour dans les `plugin.json`

Les `plugin.json` utilisent des chemins relatifs à leur propre emplacement. Après déplacement de `.codex-plugin/plugin.json` vers `.codex-plugin/plugins/ecocode/plugin.json`, tous les chemins doivent monter de 2 niveaux supplémentaires :

| Champ          | Avant                          | Après                                 |
| -------------- | ------------------------------ | ------------------------------------- |
| `skills`       | `"./skills/"`                  | `"../../../skills/"`                  |
| `composerIcon` | `"./assets/ecocode-small.svg"` | `"../../../assets/ecocode-small.svg"` |
| `logo`         | `"./assets/app-icon.png"`      | `"../../../assets/app-icon.png"`      |

Même correction à appliquer pour `.claude-plugin/plugins/ecocode/plugin.json` et `.cursor-plugin/plugins/ecocode/plugin.json`.

### Ordre d'exécution

1. Déplacer les `plugin.json` existants dans leurs sous-dossiers
2. Corriger les chemins relatifs dans chaque `plugin.json` déplacé (voir tableau ci-dessus)
3. Mettre à jour `marketplace.json` (champ `source` + entrée rgaa)
4. Créer les stubs rgaa
5. Mettre à jour `CLAUDE.md` et `README.md`

## Hors scope

- Contenu fonctionnel du skill rgaa (agents, logique d'audit) — sujet d'un spec séparé
- Publication npm
- Support Gemini CLI
