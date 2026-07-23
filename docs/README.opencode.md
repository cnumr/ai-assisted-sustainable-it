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
Analyse l'URL https://example.com selon les bonnes pratiques Green IT.
```

Le plugin charge le bootstrap ecocode et enregistre les skills automatiquement.

## Mise à jour

Pour épingler la version 2.0.0 :

```json
{
  "plugin": ["ai-assisted-sustainable-it@git+https://github.com/cnumr/ai-assisted-sustainable-it.git#v2.0.0"]
}
```

## Aide

- Signaler un problème : https://github.com/cnumr/ai-assisted-sustainable-it/issues
- Documentation : https://github.com/cnumr/ai-assisted-sustainable-it
