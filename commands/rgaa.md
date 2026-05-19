# /rgaa

Lance un audit d'accessibilité RGAA 4.2.1 sur une ou plusieurs URLs.

## Usage

```
/rgaa https://example.com                           # Audit d'une page
/rgaa https://example.com https://example.com/page  # Échantillon multi-pages
```

## Ce que fait la commande

1. Vérifie si un audit précédent existe dans `docs/rgaa/audits/`
2. Collecte les paramètres (URLs, type d'audit, Playwright)
3. Analyse chaque page via `rgaa-page-analyzer` (parallélisable)
4. Agrège les résultats avec la règle NC global
5. Calcule les taux de conformité (fourchette bas/haut)
6. Écrit le rapport dans `docs/rgaa/audits/`
7. Génère la checklist manuelle dans `docs/rgaa/checklists/` (si critères ⚠)

## Types d'audit disponibles

Voir `rgaa_types_audit()` — par défaut : **rapide** (25 critères clés).

## Prérequis

- MCP `mcp-rgaa` requis
- MCP `playwright` recommandé (contrastes, zoom, navigation clavier)
