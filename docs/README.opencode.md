# ai-assisted-sustainable-it pour OpenCode

## Installation

Ajouter le plugin dans `opencode.json` :

```json
{
  "plugin": ["ai-assisted-sustainable-it@git+https://github.com/cnumr/ai-assisted-sustainable-it.git"]
}
```

Redémarrer OpenCode, puis demander un audit éco-conception.

## Utilisation

```text
Lance un audit éco-conception sur ce projet.
Analyse uniquement le front-end de ce projet.
Analyse les parcours front-end runtime avec `/ecocode frontend` (MCP `playwright` requis).
Analyse l'URL https://example.com selon les bonnes pratiques Green IT.
```

Le plugin charge le bootstrap ecocode et enregistre les skills automatiquement.

## Mise à jour

Pour épingler une version précise :

```json
{
  "plugin": ["ai-assisted-sustainable-it@git+https://github.com/cnumr/ai-assisted-sustainable-it.git#v2.3.1"]
}
```

## Aide

- Signaler un problème : https://github.com/cnumr/ai-assisted-sustainable-it/issues
- Documentation : https://github.com/cnumr/ai-assisted-sustainable-it
