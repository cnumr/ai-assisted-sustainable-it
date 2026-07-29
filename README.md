# ai-assisted-sustainable-it

Des skills pour créer et implémenter des produits numériques éco-conçus, ainsi
que pour auditer et améliorer des produits existants, avec Claude Code,
OpenCode, Cursor, Gemini et Codex. Ils s'appuient sur les [115 bonnes pratiques
Green IT](https://github.com/cnumr/best-practices).

## Fonctionnalités

- Skills de conception et d'implémentation sobre, injectés au démarrage de
  session.
- Skills d'audit éco-conception complet du front-end et du back-end.
- Rapports, plans d'action et corrections guidées pour améliorer les produits
  audités.
- Routage commun Claude Code, OpenCode et Codex : `/ecocode` déclenche
  `ecocode-orchestrator`, qui lance les analyseurs front et back en parallèle
  pour un audit complet.

Les guides `design` et `development` se déclenchent automatiquement au début
d'une session. Les audits restent explicites : lancez `/ecocode` pour
déclencher l'orchestrateur.

Dans Codex, chaque profil conserve son niveau de raisonnement et laisse Codex
choisir un modèle disponible adapté à sa tâche.

## Utilisation

```text
/ecocode                      # Audit complet du projet courant
/ecocode front                # Analyse front-end uniquement
/ecocode frontend             # Audit runtime des parcours front-end (requiert playwright)
/ecocode frontend https://example.com
/ecocode frontend parcours.json
/ecocode frontend init        # Crée un scénario JSON sans l'exécuter
/ecocode back                 # Analyse back-end uniquement
/ecocode https://example.com  # Analyse d'une URL (requiert playwright)
/ecocode plan                 # Plan d'action depuis le dernier audit
/ecocode fix                  # Correction guidée depuis le dernier audit
```

### Parcours front-end runtime

Passez une ou plusieurs URL HTTP(S), ou un fichier JSON strict :

```text
/ecocode frontend https://example.com https://example.com/catalogue
/ecocode frontend parcours.json
```

Exemple minimal de `parcours.json` :

```json
{
  "parcours": [
    {
      "nom": "decouverte",
      "etapes": [
        {
          "action": "goto",
          "url": "https://example.com/",
          "audit": true
        }
      ]
    }
  ]
}
```

`/ecocode frontend init` crée ce fichier pas à pas, demande confirmation avant
son écriture et ne lance aucune navigation. Les scénarios interactifs demandent
une confirmation explicite avant toute action susceptible de modifier l’état
distant.

## Prérequis

- MCP [`mcp-greenit`](https://mcp-115-bp.greenit.eco/) — accès au référentiel
  Green IT (requis).
- MCP `playwright` — requis pour `/ecocode frontend` et l'analyse d'URLs en runtime.

## Installation

### Claude Code

```bash
/plugin marketplace add cnumr/ai-assisted-sustainable-it
/plugin install ecocode@ai-assisted-sustainable-it
```

Ou manuellement :

```bash
git clone https://github.com/cnumr/ai-assisted-sustainable-it.git ~/.claude/plugins/ai-assisted-sustainable-it
ln -s ~/.claude/plugins/ai-assisted-sustainable-it/skills/audits ~/.claude/skills/audits
ln -s ~/.claude/plugins/ai-assisted-sustainable-it/agents/ecocode-*.md ~/.claude/agents/
```

### OpenCode

```json
{
  "plugin": ["ai-assisted-sustainable-it@git+https://github.com/cnumr/ai-assisted-sustainable-it.git"]
}
```

Voir [le guide OpenCode](docs/README.opencode.md) pour les détails.

### Codex

```bash
git clone https://github.com/cnumr/ai-assisted-sustainable-it.git ~/.codex/plugins/ai-assisted-sustainable-it
mkdir -p ~/.codex/skills ~/.codex/agents
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/audits ~/.codex/skills/audits
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/design ~/.codex/skills/design
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/skills/development ~/.codex/skills/development
ln -s ~/.codex/plugins/ai-assisted-sustainable-it/.codex/agents/*.toml ~/.codex/agents/
```

Les liens dans `~/.codex/agents/` rendent les profils spécialisés découvrables
hors du dépôt cloné. Redémarrez Codex ou ouvrez une nouvelle tâche après
l'installation, puis utilisez `/ecocode frontend init`, une URL HTTP(S) ou un
fichier JSON comme dans les exemples ci-dessus.

### Cursor et Gemini

Les manifestes `.cursor-plugin` et `gemini-extension.json` sont fournis pour
ces plateformes.
