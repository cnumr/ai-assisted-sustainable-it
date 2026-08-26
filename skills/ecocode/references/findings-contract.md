# Contrat de constats

Retourner uniquement ces données à l'orchestrateur :

```yaml
perimetre: front | back | complet | runtime
limites: [mesure ou zone non accessible]
metriques:
  ecoindex: estimation ou mesure runtime, si disponible
  dom_nodes: nombre ou null
  requests: nombre ou null
  size_kb: nombre ou null
constats:
  - rweb: identifiant et intitulé exact retournés par mcp-greenit
    localisation: fichier:ligne, URL ou composant
    preuve: observation ou mesure vérifiable
    impact: réseau, CPU, mémoire, stockage ou infrastructure
    severite: haute | moyenne | faible
    correction: action adaptée au projet
bonnes_pratiques: [observation liée à une fiche MCP]
a_verifier: [hypothèse sans preuve suffisante]
```

Un écart Green IT exige une fiche effectivement retournée par `mcp-greenit`.
Ne jamais inventer un identifiant RWEB. Les alertes de performance ou de qualité
web sans fiche vérifiée restent séparées des constats Green IT.

Pour une analyse statique, qualifier l'EcoIndex d'estimation calculée à partir
des sources. Pour le runtime, conserver les métriques brutes et les limites de
mesure par page.
